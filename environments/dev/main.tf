module "saml_sso" {
  source = "../../modules/saml_sso"

  app_display_name = var.app_display_name
  saml_entity_id   = var.saml_entity_id

  reply_urls  = var.reply_urls
  sign_on_url = var.sign_on_url
  logout_url  = var.logout_url

  relay_state                  = var.relay_state
  notification_email_addresses = var.notification_email_addresses

  create_token_signing_cert = var.create_token_signing_cert

  claims_mapping_policy_definition_json = var.claims_mapping_policy_definition_json

  saml_template_display_name = var.saml_template_display_name

  assigned_object_ids = var.assigned_object_ids
}