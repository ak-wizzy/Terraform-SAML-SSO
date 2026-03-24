terraform {
  required_providers {
    azuread = { source = "hashicorp/azuread" }
  }
}

#############################
# 1) App registration (App)
#############################
# Note: identifier_uris must follow Entra restrictions (e.g., api://<appId> or a verified domain)
# https://learn.microsoft.com/en-us/entra/identity-platform/identifier-uri-restrictions
resource "azuread_application" "saml" {
  display_name    = var.app_display_name
  identifier_uris = var.identifier_uris

  web {
    redirect_uris = var.reply_urls
    homepage_url  = var.sign_on_url
    logout_url    = var.logout_url
  }
}

########################################
# 2) Enterprise App (Service Principal)
########################################
resource "azuread_service_principal" "saml_sp" {
  client_id = azuread_application.saml.client_id

  # Make this a SAML app
  preferred_single_sign_on_mode = "saml"

  # Helpful tags – marks this as a custom SAML Enterprise App in the UI
  feature_tags {
    custom_single_sign_on = true
    enterprise            = true
  }

  # Optional: set RelayState for SP-initiated flows
  saml_single_sign_on {
    relay_state = var.relay_state
  }

  # Optional: set a launch URL (visible in MyApps)
  login_url = var.sign_on_url

  notification_email_addresses = var.notification_email_addresses
}


############################################################
# 3) Create/rotate IdP token-signing certificate for SAML
############################################################
# Azure AD (Entra ID) uses this certificate to SIGN SAML tokens it issues.
# This is NOT the same as SP credentials; use the dedicated token_signing resource.
resource "azuread_service_principal_token_signing_certificate" "saml" {
  count                = var.create_token_signing_cert ? 1 : 0
  service_principal_id = azuread_service_principal.saml_sp.id

  # Optional cosmetics:
  display_name = "CN=${replace(var.app_display_name, " ", "-")}"
  # Example of pinning the end date (RFC3339). Omit to use defaults.
  # end_date     = "2030-12-31T23:59:59Z"
}

########################################
# 4) Assign users/groups to the app
########################################
resource "azuread_app_role_assignment" "assignments" {
  for_each = toset(var.assigned_object_ids)

  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.saml_sp.id
  # Built-in default "User" app role for enterprise apps
  app_role_id         = "00000000-0000-0000-0000-000000000000"
}

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