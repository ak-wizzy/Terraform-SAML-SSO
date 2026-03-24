output "application_id" {
  description = "Application (client) ID"
  value       = azuread_application.saml.client_id
}

output "application_object_id" {
  description = "Object ID of the application"
  value       = azuread_application.saml.object_id
}

output "service_principal_id" {
  description = "Object ID of the service principal (Enterprise App)"
  value       = azuread_service_principal.saml_sp.id
}

output "saml_metadata_url" {
  description = "Federation metadata URL for the Enterprise App"
  value       = azuread_service_principal.saml_sp.saml_metadata_url
}