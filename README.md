# Google IAM Terraform module

## Features
1. Create identity providers with set of roles and permissions for external identities, e.g. Terraform Cloud/Enterprise.

## Usage

`iam-tfe-oidc`

```hcl
module "iam-tfe-oidc" {
  source = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-tfe-oidc"

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
