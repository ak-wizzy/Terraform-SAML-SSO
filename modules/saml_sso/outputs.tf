output "service_principal_id" {
  description = "Terraform ID of the service principal"
  value       = data.azuread_service_principal.saml_sp.id
}

output "service_principal_object_id" {
  description = "Object ID of the service principal"
  value       = data.azuread_service_principal.saml_sp.object_id
}

output "service_principal_client_id" {
  description = "Client ID / App ID used by the service principal"
  value       = data.azuread_service_principal.saml_sp.client_id
}