################################################################################
# Identity Pools
################################################################################

output "identity_pools" {
  value       = [for i in google_iam_workload_identity_pool.this : i.id]
  description = "A list of Workload Identity Pool IDs."
}

output "identity_pool_names" {
  value       = [for i in google_iam_workload_identity_pool.this : i.name]
  description = "A list of Workload Identity Pool names."
}

################################################################################
# Providers
################################################################################

output "providers" {
  value       = [for i in google_iam_workload_identity_pool_provider.this : i.id]
  description = "A list of Provider IDs."
}

output "provider_names" {
  value       = [for i in google_iam_workload_identity_pool_provider.this : i.name]
  description = "A list of Provider names."
}

################################################################################
# Service Accounts
################################################################################

output "service_accounts" {
  value       = concat([for i in google_service_account.this : i.id], [for i in google_service_account.environment : i.id])
  description = "A list of default or apply run phase Service Account IDs."
}

output "service_account_names" {
  value       = concat([for i in google_service_account.this : i.name], [for i in google_service_account.environment : i.name])
  description = "A list of default or apply run phase Service Account names."
}

output "service_account_emails" {
  value       = concat([for i in google_service_account.this : i.email], [for i in google_service_account.environment : i.name])
  description = "A list of default or apply run phase Service Account emails."
}