# Google Terraform Cloud/Enterprise OIDC Provider

Terraform module which creates Workload Identity Pools, OIDC Providers and Service Accounts for Terraform Cloud/Enterprise projects and workspaces.

## Usage

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

> [!IMPORTANT]
> An `account_id` for each service account is created in the format: `tfe-apply-{{workspace}}` or `tfe-plan-{{workspace}}` and the length must be between 6 and 30 characters so each value in `workspaces` must be at most 20 characters long.

## Examples

- [iam-tfe-oidc](https://github.com/PCDEV-Cloud/terraform-google-iam/tree/main/examples/iam-tfe-oidc) - Creates OIDC provider for Terraform Cloud/Enterprise
