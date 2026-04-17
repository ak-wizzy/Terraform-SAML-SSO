output "application_id" {
  description = "Application (client) ID"
  value       = azuread_application.saml.client_id
}

output "application_object_id" {
  description = "Application object ID"
  value       = azuread_application.saml.object_id
}

output "service_principal_id" {
  description = "Service principal object ID"
  value       = azuread_service_principal.saml_sp.id
}

output "service_principal_object_id" {
  description = "Service principal object ID (explicit)"
  value       = azuread_service_principal.saml_sp.object_id
}