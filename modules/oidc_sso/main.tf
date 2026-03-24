terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
    }
    azapi = {
      source = "azure/azapi"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}

# -------------------------------
# 1. CERTIFICATE GENERATION
# -------------------------------

resource "tls_private_key" "saml" {
  count     = var.generate_sp_certificate ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "saml" {
  count                 = var.generate_sp_certificate ? 1 : 0
  private_key_pem       = tls_private_key.saml[0].private_key_pem
  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]

  subject {
    common_name = var.app_display_name
  }
}

# -------------------------------
# 2. APPLICATION REGISTRATION
# -------------------------------

resource "azuread_application" "saml_sso" {
  display_name = var.app_display_name

  web {
    redirect_uris = var.reply_urls
    homepage_url  = var.sign_on_url
    logout_url    = var.logout_url
  }

  identifier_uris = var.identifier_uris
}

# -------------------------------
# 3. SERVICE PRINCIPAL
# -------------------------------

resource "azuread_service_principal" "saml_sso_sp" {
  client_id = azuread_application.saml_sso.client_id
}

# -------------------------------
# 4. ASSIGN USERS/GROUPS
# -------------------------------

resource "azuread_app_role_assignment" "assignments" {
  for_each = toset(var.assigned_object_ids)

  principal_object_id = each.value
  resource_object_id  = azuread_service_principal.saml_sso_sp.id
  app_role_id         = "00000000-0000-0000-0000-000000000000"
}

# -------------------------------
# 6. UPLOAD CERTIFICATE
# -------------------------------

resource "azuread_service_principal_certificate" "saml_cert" {
  count               = var.generate_sp_certificate ? 1 : 0
  service_principal_id = azuread_service_principal.saml_sso_sp.id
  
  # EXTRACT PUBLIC CERT ONLY (no private key/chain)
  value    = tls_self_signed_cert.saml[0].cert_pem
  encoding = "pem"
  type     = "AsymmetricX509Cert"
}
