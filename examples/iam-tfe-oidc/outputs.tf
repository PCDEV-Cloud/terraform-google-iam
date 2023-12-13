output "identity_pools" {
  value = module.iam-tfe-oidc.identity_pools
}

output "identity_pool_names" {
  value = module.iam-tfe-oidc.identity_pool_names
}

output "providers" {
  value = module.iam-tfe-oidc.providers
}

output "provider_names" {
  value = module.iam-tfe-oidc.provider_names
}

output "apply_service_accounts" {
  value = module.iam-tfe-oidc.apply_service_accounts
}

output "apply_service_account_names" {
  value = module.iam-tfe-oidc.apply_service_account_names
}

output "apply_service_account_emails" {
  value = module.iam-tfe-oidc.apply_service_account_emails
}

output "plan_service_accounts" {
  value = module.iam-tfe-oidc.plan_service_accounts
}

output "plan_service_account_names" {
  value = module.iam-tfe-oidc.plan_service_account_names
}

output "plan_service_account_emails" {
  value = module.iam-tfe-oidc.plan_service_account_emails
}