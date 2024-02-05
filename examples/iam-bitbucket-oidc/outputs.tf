output "identity_pools" {
  value = module.iam-bitbucket-oidc.identity_pools
}

output "identity_pool_names" {
  value = module.iam-bitbucket-oidc.identity_pool_names
}

output "providers" {
  value = module.iam-bitbucket-oidc.providers
}

output "provider_names" {
  value = module.iam-bitbucket-oidc.provider_names
}

output "service_accounts" {
  value = module.iam-bitbucket-oidc.service_accounts
}

output "service_account_names" {
  value = module.iam-bitbucket-oidc.service_account_names
}

output "service_account_emails" {
  value = module.iam-bitbucket-oidc.service_account_emails
}