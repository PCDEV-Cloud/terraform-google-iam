provider "google" {}

module "iam-bitbucket-oidc" {
  source = "../../modules/iam-bitbucket-oidc"

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