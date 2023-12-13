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

output "apply_service_accounts" {
  value       = [for i in google_service_account.apply : i.id]
  description = "A list of default or apply run phase Service Account IDs."
}

output "apply_service_account_names" {
  value       = [for i in google_service_account.apply : i.name]
  description = "A list of default or apply run phase Service Account names."
}

output "apply_service_account_emails" {
  value       = [for i in google_service_account.apply : i.email]
  description = "A list of default or apply run phase Service Account emails."
}

output "plan_service_accounts" {
  value       = [for i in google_service_account.plan : i.id]
  description = "A list of plan run phase Service Account IDs."
}

output "plan_service_account_names" {
  value       = [for i in google_service_account.plan : i.name]
  description = "A list of plan run phase Service Account names."
}

output "plan_service_account_emails" {
  value       = [for i in google_service_account.plan : i.email]
  description = "A list of plan run phase Service Account emails."
}
