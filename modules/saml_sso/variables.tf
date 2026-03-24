variable "app_display_name" {
  type        = string
  description = "Display name for the application/enterprise app"
}

variable "reply_urls" {
  type        = list(string)
  description = "SAML Reply URLs (Assertion Consumer Service URLs)"
}

variable "identifier_uris" {
  type        = list(string)
  description = "SAML Identifier (Entity ID) values; must follow Entra rules (e.g., api://<appId> or a verified domain)"
}

variable "logout_url" {
  type        = string
  description = "SAML Logout URL (optional)"
  default     = null
}

variable "sign_on_url" {
  type        = string
  description = "Launch/Sign-on URL (optional)"
  default     = null
}

variable "relay_state" {
  type        = string
  description = "RelayState for SP-initiated SSO (optional)"
  default     = null
}

variable "assigned_object_ids" {
  type        = list(string)
  description = "Object IDs (users/groups) to assign to the Enterprise App"
  default     = []
}

variable "create_token_signing_cert" {
  type        = bool
  description = "Whether to generate a SAML IdP token-signing cert for the SP"
  default     = true
}

variable "claims_mapping_policy_definition_json" {
  type        = string
  description = "JSON string for a Claims Mapping Policy definition (use jsonencode(...) when calling)."
  default     = null
}

variable "notification_email_addresses" {
  type        = list(string)
  description = "Email addresses to notify when the SAML token-signing certificate is nearing expiration."
  default     = []
}