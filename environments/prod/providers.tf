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

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "azapi" {}

provider "tls" {}