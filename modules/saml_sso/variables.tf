variable "app_display_name" {
  description = "Display name of the SAML enterprise application"
  type        = string
}

variable "saml_template_display_name" {
  description = "Display name of the Entra application template to instantiate"
  type        = string
  default     = "Microsoft Entra SAML Toolkit"
}

variable "saml_entity_id" {
  description = "SAML Entity ID / Identifier URI"
  type        = string
}

variable "reply_urls" {
  description = "SAML reply URLs / ACS endpoints"
  type        = list(string)
}

variable "sign_on_url" {
  description = "Application sign-on URL"
  type        = string
}

variable "logout_url" {
  description = "Application logout URL"
  type        = string
}

variable "relay_state" {
  description = "Optional relay state for SAML SSO"
  type        = string
  default     = null
}

variable "notification_email_addresses" {
  description = "Notification email addresses for the enterprise application"
  type        = list(string)
  default     = []
}

variable "assigned_object_ids" {
  description = "Users or groups to assign to the enterprise app"
  type        = list(string)
  default     = []
}

variable "create_token_signing_cert" {
  description = "Whether to create a token signing certificate"
  type        = bool
  default     = false
}

variable "claims_mapping_policy_definition_json" {
  description = "Optional claims mapping policy JSON"
  type        = string
  default     = null
}