terraform {
  required_providers {
    azuread = { source = "hashicorp/azuread" }
    time    = { source = "hashicorp/time" }
    null    = { source = "hashicorp/null" }
  }
}

data "azuread_application_template" "saml_toolkit" {
  display_name = var.saml_template_display_name
}

resource "azuread_application_from_template" "saml" {
  display_name = var.app_display_name
  template_id  = data.azuread_application_template.saml_toolkit.template_id
}

resource "time_sleep" "wait_for_objects" {
  depends_on      = [azuread_application_from_template.saml]
  create_duration = "30s"
}

data "azuread_service_principal" "saml_sp" {
  display_name = var.app_display_name
  depends_on   = [time_sleep.wait_for_objects]
}

data "azuread_application" "saml_app" {
  display_name = var.app_display_name
  depends_on   = [time_sleep.wait_for_objects]
}

resource "null_resource" "enable_saml_sso" {
  triggers = {
    service_principal_object_id = data.azuread_service_principal.saml_sp.object_id
    preferred_sso_mode          = "saml"
    relay_state                 = var.relay_state != null ? var.relay_state : ""
    sign_on_url                 = var.sign_on_url
    notification_emails         = sha1(jsonencode(var.notification_email_addresses))
  }

  depends_on = [data.azuread_service_principal.saml_sp]

  provisioner "local-exec" {
    # interpreter = ["/bin/bash", "-c"] (use with Unix bash)
    interpreter = ["C:/Program Files/Git/bin/bash.exe", "-c"]

    command = <<EOT
set -euo pipefail

SP_OBJECT_ID="${data.azuread_service_principal.saml_sp.object_id}"
BODY=$(cat <<JSON
{
  "preferredSingleSignOnMode": "saml",
  "loginUrl": "${var.sign_on_url}",
  "notificationEmailAddresses": ${jsonencode(var.notification_email_addresses)},
  "samlSingleSignOnSettings": {
    "relayState": "${var.relay_state}"
  }
}
JSON
)

success=0
for i in {1..10}; do
  if az rest \
    --method PATCH \
    --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$SP_OBJECT_ID" \
    --headers "Content-Type=application/json" \
    --body "$BODY"; then
    success=1
    break
  fi

  echo "Attempt $i to enable SAML SSO failed. Retrying in 15s..."
  sleep 15
done

[ "$success" -eq 1 ] || { echo "Failed to enable SAML SSO mode on service principal"; exit 1; }
EOT
  }
}

resource "null_resource" "configure_saml_app" {
  triggers = {
    application_object_id = data.azuread_application.saml_app.object_id
    saml_entity_id        = var.saml_entity_id
    reply_urls_hash       = sha1(jsonencode(var.reply_urls))
    sign_on_url           = var.sign_on_url
    logout_url            = var.logout_url
  }

  depends_on = [
    null_resource.enable_saml_sso,
    data.azuread_application.saml_app
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
set -euo pipefail

APP_OBJECT_ID="${data.azuread_application.saml_app.object_id}"
BODY=$(cat <<JSON
{
  "identifierUris": ["${var.saml_entity_id}"],
  "web": {
    "redirectUris": ${jsonencode(var.reply_urls)},
    "homePageUrl": "${var.sign_on_url}",
    "logoutUrl": "${var.logout_url}"
  }
}
JSON
)

success=0
for i in {1..10}; do
  if az rest \
    --method PATCH \
    --uri "https://graph.microsoft.com/v1.0/applications/$APP_OBJECT_ID" \
    --headers "Content-Type=application/json" \
    --body "$BODY"; then
    success=1
    break
  fi

  echo "Attempt $i to configure SAML app failed. Retrying in 15s..."
  sleep 15
done

[ "$success" -eq 1 ] || { echo "Failed to configure SAML application"; exit 1; }
EOT
  }
}

resource "azuread_service_principal_token_signing_certificate" "saml" {
  count                = var.create_token_signing_cert ? 1 : 0
  service_principal_id = data.azuread_service_principal.saml_sp.id

  display_name = "CN=${replace(var.app_display_name, " ", "-")}"

  depends_on = [null_resource.configure_saml_app]
}

resource "azuread_app_role_assignment" "assignments" {
  for_each = toset(var.assigned_object_ids)

  principal_object_id = each.value
  resource_object_id  = data.azuread_service_principal.saml_sp.id
  app_role_id         = "00000000-0000-0000-0000-000000000000"

  depends_on = [null_resource.configure_saml_app]
}

resource "azuread_claims_mapping_policy" "this" {
  count        = var.claims_mapping_policy_definition_json != null ? 1 : 0
  display_name = "${var.app_display_name}-claims"
  definition   = [var.claims_mapping_policy_definition_json]
}

resource "azuread_service_principal_claims_mapping_policy_assignment" "this" {
  count                    = var.claims_mapping_policy_definition_json != null ? 1 : 0
  service_principal_id     = data.azuread_service_principal.saml_sp.id
  claims_mapping_policy_id = azuread_claims_mapping_policy.this[0].id

  depends_on = [null_resource.configure_saml_app]
}