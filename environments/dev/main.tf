module "saml_sso" {
  source = "../../modules/saml_sso"

  providers = {
    azuread = azuread
    #tls     = tls
  }

  app_display_name         = var.app_display_name
  identifier_uris          = var.identifier_uris
  reply_urls               = var.reply_urls
  sign_on_url              = var.sign_on_url
  logout_url               = var.logout_url
  relay_state              = var.relay_state
  assigned_object_ids      = var.assigned_object_ids
  notification_email_addresses = var.notification_email_addresses
  #generate_sp_certificate  = var.generate_sp_certificate
  #certificate_base64       = var.certificate_base64
  #custom_claims            = var.custom_claims
}

