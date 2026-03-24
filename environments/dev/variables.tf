variable "app_display_name"        { type = string }
variable "identifier_uris"         { type = list(string) }
variable "reply_urls"              { type = list(string) }
variable "sign_on_url"             { type = string }
variable "logout_url"              { type = string }
variable "relay_state"             { type = string }
variable "assigned_object_ids"     { type = list(string) }
variable "generate_sp_certificate" { type = bool }
variable "certificate_base64"      { type = string }
variable "custom_claims" {
  type = list(object({
    Source   = string
    ID       = string
    JsonType = string
  }))
}
variable "tenant_id" {
  type        = string
  description = "Azure AD Tenant ID used for provider authentication."
}

variable "notification_email_addresses" {
  type        = list(string)
  description = "Email addresses to notify when the SAML token-signing certificate is nearing expiration."
  default     = []
}