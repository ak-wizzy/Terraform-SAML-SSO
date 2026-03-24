/**
 * OUTPUTS FOR SAML SSO MODULE
 */

output "application_id" {
  description = "The Client/Application ID of the SAML application."
  value       = azuread_application.saml_sso.client_id
}

output "service_principal_id" {
  description = "The Service Principal ID of the created Enterprise Application."
  value       = azuread_service_principal.saml_sso_sp.id
}

output "object_id" {
  description = "The Object ID of the AzureAD Application object."
  value       = azuread_application.saml_sso.object_id
}

# Only if generating certificates
output "generated_certificate_pem" {
  description = "The generated X.509 SP signing certificate."
  value       = var.generate_sp_certificate ? tls_self_signed_cert.saml[0].cert_pem : null
}

output "generated_private_key_pem" {
  description = "The generated private key for the SP certificate."
  sensitive   = true
  value       = var.generate_sp_certificate ? tls_private_key.saml[0].private_key_pem : null
}