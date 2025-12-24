# The full resource name of the workforce identity pool.
output "workforce_pool_name" {
  description = "The full resource name of the workforce identity pool."
  value       = one(google_iam_workforce_pool.main[*].name)
}

# The ID of the workforce identity pool.
output "workforce_pool_id" {
  description = "The ID of the workforce identity pool."
  value       = one(google_iam_workforce_pool.main[*].workforce_pool_id)
}

# The state of the workforce identity pool.
output "workforce_pool_state" {
  description = "The state of the workforce identity pool."
  value       = one(google_iam_workforce_pool.main[*].state)
}

# A map of the full resource names of the workforce identity providers, keyed by provider ID.
output "provider_names" {
  description = "A map of the full resource names of the workforce identity providers, keyed by provider ID."
  value       = { for k, v in google_iam_workforce_pool_provider.main : k => v.name }
}

# A list of the IDs of the created workforce identity providers.
output "provider_ids" {
  description = "A list of the IDs of the created workforce identity providers."
  value       = keys(google_iam_workforce_pool_provider.main)
}
