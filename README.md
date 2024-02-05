# Google IAM Terraform module

## Features
1. Create identity providers with set of roles and permissions for external identities, e.g. Terraform Cloud/Enterprise, Bitbucket.

## Usage

`iam-tfe-oidc`

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

`iam-bitbucket-oidc`

```hcl
module "iam-bitbucket-oidc" {
  source = "github.com/PCDEV-Cloud/terraform-google-iam//modules/iam-bitbucket-oidc?ref=v1.1.0"

  project = "<GOOGLE-PROJECT-HERE>"

  issuer_url = "https://api.bitbucket.org/2.0/workspaces/<WORKSPACE-NAME-HERE>/pipelines-config/identity/oidc"
  audience   = "ari:cloud:bitbucket::workspace/<WORKSPACE-UUID-HERE>"

  repositories = [
    {
      name = "Example-Repository"
      uuid = "<REPOSITORY-UUID-HERE>"
    }
  ]
}
```

## Examples

- [iam-tfe-oidc](https://github.com/PCDEV-Cloud/terraform-google-iam/tree/main/examples/iam-tfe-oidc) - Creates OIDC provider for Terraform Cloud/Enterprise
- [iam-bitbucket-oidc](https://github.com/PCDEV-Cloud/terraform-google-iam/tree/main/examples/iam-bitbucket-oidc) - Creates OIDC provider for Bitbucket