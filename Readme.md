Terraform Infrastructure‑as‑Code (IaC) Structure for Entra ID Identity Automation
Overview
This documentation describes a complete Infrastructure‑as‑Code (IaC) structure for managing Microsoft Entra ID identity resources using Terraform.
It includes reusable modules for:
    • SAML SSO Application Provisioning
    • Conditional Access Policies
    • Groups, Roles, and Identity Governance
    • Token Protection (optional future module)
    Terraform supports lifecycle management of Entra ID resources such as Conditional Access Policies and enterprise SSO application creation through the AzureAD provider. 
Microsoft and HashiCorp also confirm support for SAML SSO integration flow using Enterprise Applications and SAML settings in Entra ID. [youtube.com] [learn.microsoft.com], [digitalbunker365.com]

## 🌍 Multi‑Environment Workflow (dev/prod)
Each environment is fully isolated and treated as a separate Terraform workspace,
with its own:
- `main.tf`  
- `variables.tf`  
- `terraform.tfvars`  
- `.terraform` working directory  
- `terraform.tfstate`
To deploy:
### ▶ Deploy to DEV
```sh
cd environments/dev
terraform init
terraform plan
terraform apply
▶ Deploy to PROD



Shell
cd environments/prod
terraform init
terraform plan
terraform apply
Show more lines

🔐 Authentication (AzureAD Provider v3)
The AzureAD provider does NOT allow client_id/client_secret inside providers.tf.
Terraform authentication must come from environment variables.
If running locally (recommended during development):
Run these exports in your shell:



Shell
export ARM_CLIENT_ID="APP_ID"
export ARM_CLIENT_SECRET="SECRET"
export ARM_TENANT_ID="TENANT_GUID"

Show more lines
You may also place them into ~/.zshrc or ~/.bashrc.
If running in Terraform Cloud:
Go to:
Workspace → Variables → Environment Variables
Add:
    • ARM_CLIENT_ID
    • ARM_CLIENT_SECRET
    • ARM_TENANT_ID
    • ARM_SUBSCRIPTION_ID
    All secrets should be marked sensitive.
    
    📦 Module: modules/saml_sso
    This module provisions a fully automated SAML SSO application in Entra ID:
        ○ Entra ID application object
        ○ Service principal
        ○ SAML metadata: 
            § Entity ID
            § ACS URLs
            § Sign‑on URL
            § Logout URL
            § RelayState
            § Logo URL
            § Certificate generation (TLS)
            § Optional certificate upload
            § Claims mapping policy (AzAPI)
            § User/group assignments
            Module variables are declared inside:
            modules/saml_sso/variables.tf
            Module values are never stored in terraform.tfvars.
            They are always passed via the environment’s main.tf.
            
            📘 Environment Variable Strategy
                □ All secrets (client_id, client_secret) → ENV vars
                □ All root variables (tenant_id) → root variables.tf
                □ All module inputs → environment folder main.tf
                □ All environment-specific values → environment folder terraform.tfvars
                This guarantees clean separation of:
                    ® environments
                    ® secrets
                    ® module logic
                    ® provider logic
                    
                    🏗 Backend Options
                    This project currently uses local backend by default.
                    To enable:
                    ▶ Terraform Cloud backend
                    Use a backend.tf in root only.
                    ▶ Azure Storage backend
                    Use a backend.tf with an azurerm block.
                    Note:
                    Each environment must have its own backend key / state file.
                    
                    🚀 Getting Started
                        1. Install Terraform
                        2. Install Azure CLI (if using Azure CLI authentication): 
brew install azure-cli
az login
                        3. Export ARM_* environment variables (if not using CLI)
                        4. Navigate into an environment folder: 
cd environments/dev
terraform init
terraform plan
terraform apply
                        5. Repeat for prod when ready


terraform-entra-id/
│
├── main.tf                  # Loads the correct environment
├── providers.tf             # Providers ONLY
├── variables.tf             # Root variables declarations (tenant_id etc.)
├── outputs.tf               # Root outputs
│
├── terraform.tfvars         # (Optional) Global defaults (NOT recommended for envs)
│
├── modules/
│   └── saml_sso/
│       ├── main.tf          # Module logic only
│       ├── variables.tf     # Module input declarations
│       ├── outputs.tf       # Module output declarations
│       └── README.md
│
└── environments/
    ├── dev/
    │   ├── main.tf          # Calls module with dev settings
    │   ├── terraform.tfvars # holds DEV values (tenant_id, module params)
    │   └── variables.tf     # declares variables used in dev main.tf
    │
    └── prod/
        ├── main.tf          # Calls module with PROD settings
        ├── terraform.tfvars # holds PROD values
        └── variables.tf     # declares variables used in prod main.tf