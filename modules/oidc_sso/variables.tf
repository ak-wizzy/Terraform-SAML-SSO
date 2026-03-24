/**
 * VARIABLES FOR SAML SSO MODULE
 * Supports:
 * - Entity ID, ACS URL, Sign-on + Logout URL
 * - RelayState, Logo URL
 * - Custom Claims
 * - Auto-generated SP Certificates
 * - Uploading external certificates
 * - User/Group Assignments
 */

variable "app_display_name" {
  type        = string
  description = "The display name of the SAML Enterprise Application."
}

variable "identifier_uris" {
  type        = list(string)
  description = "The SAML Identifier / Entity ID URIs for the application."
}

variable "reply_urls" {
  type        = list(string)
  description = "SAML Reply URLs (ACS endpoints)."
}

variable "sign_on_url" {
  type        = string
  description = "Optional SAML Sign-on URL (IdP-initiated or SP-initiated entry point)."
  default     = null
}

variable "logout_url" {
  type        = string
  description = "Optional SAML Logout URL (SLO endpoint)."
  default     = null
}

variable "relay_state" {
  type        = string
  description = "Optional SAML RelayState for redirecting users after authentication."
  default     = null
}

variable "logo_url" {
  type        = string
  description = "Optional application logo URL."
  default     = null
}

variable "assigned_object_ids" {
  type        = list(string)
  description = "List of Entra ID User or Group Object IDs to assign to the application."
  default     = []
}

variable "generate_sp_certificate" {
  type        = bool
  description = "Generate a new SP signing certificate automatically."
  default     = false
}

variable "certificate_base64" {
  type        = string
  description = "Optional Base64-encoded certificate to upload instead of generating one."
  default     = ""
}

variable "custom_claims" {
  type = list(object({
    Source   = string
    ID       = string
    JsonType = string
  }))
  description = "Custom SAML claims to include via Claims Mapping Policy."
  default     = []
}