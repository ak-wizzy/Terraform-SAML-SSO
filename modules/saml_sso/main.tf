terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    msgraph = {
      source  = "microsoft/msgraph"
      version = "~> 0.2"
    }
  }
}

locals {
  saml_entity_id = var.saml_entity_id
}

########################################
# 1) App Registration
########################################
resource "azuread_application" "saml" {
  display_name    = var.app_display_name
  identifier_uris = [local.saml_entity_id]

  web {
    redirect_uris = var.reply_urls
    homepage_url  = var.sign_on_url
    logout_url    = var.logout_url
  }
}

########################################
# 2) Service Principal (Enterprise App)
########################################
resource "azuread_service_principal" "saml_sp" {
  client_id = azuread_application.saml.client_id

  preferred_single_sign_on_mode = "saml"

  feature_tags {
    custom_single_sign_on = true
    enterprise            = true
  }

  login_url = var.sign_on_url
}

########################################
# 3) Enable SAML SSO via Graph
########################################
resource "msgraph_update_resource" "enable_saml_sso" {
  url = "servicePrincipals/${azuread_service_principal.saml_sp.object_id}"

  body = {
    preferredSingleSignOnMode  = "saml"
    loginUrl                   = var.sign_on_url
    notificationEmailAddresses = var.notification_email_addresses
  }
}

########################################
# 4) Relay State (optional)
########################################
resource "msgraph_update_resource" "relay_state" {
  count = var.relay_state != null && var.relay_state != "" ? 1 : 0

  url = "servicePrincipals/${azuread_service_principal.saml_sp.object_id}"

  body = {
    samlSingleSignOnSettings = {
      relayState = var.relay_state
    }
  }
}

########################################
# 5) Token Signing Certificate
########################################
resource "azuread_service_principal_token_signing_certificate" "saml" {
  count                = var.create_token_signing_cert ? 1 : 0
  service_principal_id = azuread_service_principal.saml_sp.id

  display_name = "CN=${replace(var.app_display_name, " ", "-")}"
}

########################################
# 6) Assign Users / Groups
########################################
resource "azuread_app_role_assignment" "assignments" {
  for_each = toset(var.assigned_object_ids)

  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.saml_sp.id
  app_role_id         = "00000000-0000-0000-0000-000000000000"
}

########################################
# 7) Claims Mapping (optional)
########################################
resource "azuread_claims_mapping_policy" "this" {
  count        = var.claims_mapping_policy_definition_json != null ? 1 : 0
  display_name = "${var.app_display_name}-claims"
  definition   = [var.claims_mapping_policy_definition_json]
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "this" {
  count                    = var.claims_mapping_policy_definition_json != null ? 1 : 0
  service_principal_id     = azuread_service_principal.saml_sp.id
  claims_mapping_policy_id = azuread_claims_mapping_policy.this[0].id
}