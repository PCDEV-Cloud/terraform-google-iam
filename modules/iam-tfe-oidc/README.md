# Google Terraform Cloud/Enterprise OIDC Provider

Terraform module which creates Workload Identity Pools, OIDC Providers and Service Accounts for Terraform Cloud/Enterprise projects and workspaces.

## Usage

```hcl
module "iam-tfe-oidc" {
  source = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-tfe-oidc?ref=v1.1.0"

  project = "<GOOGLE-PROJECT-HERE>"

  access_configuration = [
    {
      organization    = "<TFE-ORGANIZATION-HERE>"
      project         = "Default"
      workspaces      = ["Example-Staging", "Example-Production"]
      split_run_phase = true
    }
  ]
}
```

## Examples

- [iam-tfe-oidc](https://github.com/PCDEV-Cloud/terraform-google-iam/tree/main/examples/iam-tfe-oidc) - Creates OIDC provider for Terraform Cloud/Enterprise
