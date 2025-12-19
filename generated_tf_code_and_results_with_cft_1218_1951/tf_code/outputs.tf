output "workforce_pool_name" {
  description = "The full resource name of the created workforce pool."
  value       = google_iam_workforce_pool.main.name
}

output "workforce_pool_id" {
  description = "The ID of the created workforce pool."
  value       = google_iam_workforce_pool.main.workforce_pool_id
}

output "workforce_pool_provider_name" {
  description = "The full resource name of the created workforce pool provider."
  value       = google_iam_workforce_pool_provider.main.name
}

output "workforce_pool_provider_id" {
  description = "The ID of the created workforce pool provider."
  value       = google_iam_workforce_pool_provider.main.provider_id
}
