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


terraform-entra-id/
│
├── environments/
│   ├── dev/
│   │   ├── main.tf             # Module calls for dev
│   │   ├── variables.tf        # Variables needed by dev modules
│   │   ├── terraform.tfvars    # Values for dev
│   │   └── providers.tf        # Provider configuration (AzureAD, AzAPI, TLS)
|   |   └── output.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
│       └── providers.tf
|       └── output.tf
│
└── modules/
|     └── saml_sso/               # Example module
├── Readme.md

---
    Components Explained
    1. Root Project (Top-Level Terraform Workspace)
    main.tf
    Defines which modules are being deployed in this environment.
    Example:
    
    
    
    Terraform
    module "my_saml_app" {
     source = "./modules/saml_app"
    
     app_display_name = "My SAML App"
     identifier_uris = ["https://app.company.com/metadata"]
     reply_urls = ["https://app.company.com/acs"]
    }
    Show more lines
    
    2. providers.tf
    Declares the Terraform providers:
        ○ AzureAD provider (manages Entra ID objects)
        ○ AzAPI provider (Graph API access for SAML claims)
        ○ TLS provider (certificate generation)
        The AzureAD Conditional Access provider supports creating CA policies through the azuread_conditional_access_policy resource. [youtube.com]
        
        3. Modules Folder
        Contains reusable building blocks.
        Each module is:
            § Contained
            § Parameter-driven
            § Reusable across environments/tenants
            Modules do not contain providers, backends, or Terraform blocks — those belong in the root.
            
            4. environments/
            Optional but recommended.
            Each environment:
                □ Inherits modules
                □ Uses the same structure
                □ Has isolated state files (if backend is implemented)
                □ Supports separation of Dev/Test/Prod
                
                Terraform Workflow
                All Terraform commands must be executed from the root folder or from an environment folder, never from within a module.
                Steps:
                    1. Authenticate
az login
                    2. Initialize providers
terraform init
                    3. Validate
terraform validate
                    4. Preview
terraform plan
                    5. Deploy
terraform apply
                    
                    SAML SSO Module
                    This module supports:
                        ◊ Entity IDs
                        ◊ ACS URLs
                        ◊ Sign‑on & Logout URLs
                        ◊ RelayState
                        ◊ Logo
                        ◊ Custom Claims (via Claims Mapping Policy)
                        ◊ Auto-generated SP signing certificates
                        ◊ Certificate upload
                        ◊ Assigning users or groups
                        It leverages AzureAD resources for application + service principal management, which is supported by Microsoft and HashiCorp for SAML integrations. [learn.microsoft.com], [digitalbunker365.com]
