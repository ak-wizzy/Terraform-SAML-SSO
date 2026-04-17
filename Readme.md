# Terraform Infrastructure as Code (IaC) for Microsoft Entra ID Identity Automation

This repository contains a reusable Terraform-based Infrastructure as Code (IaC) structure for managing Microsoft Entra ID identity resources.

It is designed to support a modular, multi-environment workflow for automating identity infrastructure in a clean, repeatable, and Git-friendly way.

## Overview

This project provides reusable Terraform modules for:

- SAML SSO application provisioning.
- Conditional Access policies.
- Groups, roles, and identity governance.
- Token protection, with support planned for a future module.

Terraform can manage Microsoft Entra ID resources such as enterprise applications, service principals, and Conditional Access policies through the AzureAD provider. Microsoft’s Graph and Entra documentation also supports the SAML SSO configuration flow used by enterprise applications. [learn.microsoft.com][web:27]

## Multi-environment workflow

Each environment is fully isolated and treated as its own Terraform workspace or deployment target.

Each environment has its own:

- `main.tf`
- `variables.tf`
- `terraform.tfvars`
- `.terraform` working directory
- `terraform.tfstate`

### Deploy to DEV

```sh
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Deploy to PROD

```sh
cd environments/prod
terraform init
terraform plan
terraform apply
```

## Authentication

The AzureAD provider should be authenticated using environment variables rather than hardcoded provider credentials.

### Local development

Set the required variables in your shell:

```sh
export ARM_CLIENT_ID="APP_ID"
export ARM_CLIENT_SECRET="SECRET"
export ARM_TENANT_ID="TENANT_GUID"
export ARM_SUBSCRIPTION_ID="SUBSCRIPTION_ID"
```

Then authenticate with Azure CLI:

```sh
az login --use-device-code --tenant "<tenant-id>"
```

You can also place the exports in `~/.zshrc` or `~/.bashrc` for convenience.

### Terraform Cloud

If you use Terraform Cloud, add these as workspace environment variables:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

Mark all secret values as sensitive.

## Module: `modules/saml_sso`

This module provisions a fully automated SAML SSO application in Microsoft Entra ID.

It handles:

- Entra ID application object creation.
- Service principal creation.
- SAML settings configuration.
- Entity ID configuration.
- ACS / Reply URLs.
- Sign-on URL.
- Logout URL.
- Relay State.
- Logo URL.
- TLS certificate generation.
- Optional certificate upload.
- Claims mapping policy support.
- User and group assignments.

### Module inputs

Module variables are declared in:

```text
modules/saml_sso/variables.tf
```

Module values are passed from the environment root module and are not stored in `terraform.tfvars` inside the reusable module itself.

## Variable strategy

Recommended structure:

- Secrets such as `client_id` and `client_secret` should come from environment variables.
- Root-level values such as `tenant_id` should be declared in the root `variables.tf`.
- Module inputs should be passed from each environment’s `main.tf`.
- Environment-specific values should live in each environment’s `terraform.tfvars`.

This keeps secrets, module logic, and environment configuration cleanly separated.

## Backend options

The project currently uses the local backend by default.

If you want to enable a remote backend, choose one of the following:

### Terraform Cloud backend

Add a `backend.tf` file in the root only.

### Azure Storage backend

Add a `backend.tf` file with an `azurerm` backend configuration.

Each environment should use its own backend key or state file.

## Getting started

1. Install Terraform.
2. Install Azure CLI if you plan to authenticate locally.

```sh
brew install azure-cli
az login
```

3. Export the required `ARM_*` environment variables if you are not using Azure CLI authentication.
4. Navigate to an environment folder.

```sh
cd environments/dev
terraform init
terraform plan
terraform apply
```

5. Repeat the same process for production when ready.

## Repository structure

```text
terraform-entra-id/
├── main.tf                  # Loads the correct environment
├── providers.tf             # Providers only
├── variables.tf             # Root variable declarations
├── outputs.tf               # Root outputs
├── terraform.tfvars         # Optional global defaults
├── modules/
│   └── saml_sso/
│       ├── main.tf          # Module logic only
│       ├── variables.tf     # Module input declarations
│       ├── outputs.tf       # Module output declarations
│       └── README.md
└── environments/
    ├── dev/
    │   ├── main.tf          # Calls module with dev settings
    │   ├── terraform.tfvars # Dev values
    │   └── variables.tf     # Variables used in dev main.tf
    └── prod/
        ├── main.tf          # Calls module with prod settings
        ├── terraform.tfvars # Prod values
        └── variables.tf     # Variables used in prod main.tf
```

## Notes

- Keep environment-specific settings out of the reusable module.
- Keep secrets out of Git.
- Prefer environment variables for authentication.
- Use separate state per environment.
- Validate every change with `terraform fmt`, `terraform validate`, and `terraform plan`.

## Recommended workflow

```sh
terraform fmt -recursive
terraform validate
terraform plan
```

## References

- Microsoft Entra ID and Terraform provider documentation.
- Microsoft Graph documentation for SAML-based single sign-on configuration.
- HashiCorp Terraform documentation for provider and module structure.