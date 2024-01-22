################################################################################
# Identity Pools
################################################################################

output "identity_pools" {
  value       = local.identity_pools
  description = "A list of Workload Identity Pool IDs."
}