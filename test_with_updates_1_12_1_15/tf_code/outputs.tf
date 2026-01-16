# The `project_bindings` output contains the authoritative project IAM binding resources created by the module.
output "project_bindings" {
  description = "The authoritative project IAM binding resources created."
  value       = google_project_iam_binding.project_bindings
}

# The `bucket_bindings` output contains the authoritative storage bucket IAM binding resources created by the module.
output "bucket_bindings" {
  description = "The authoritative storage bucket IAM binding resources created."
  value       = google_storage_bucket_iam_binding.bucket_bindings
}

# The `service_account_bindings` output contains the authoritative service account IAM binding resources created by the module.
output "service_account_bindings" {
  description = "The authoritative service account IAM binding resources created."
  value       = google_service_account_iam_binding.sa_bindings
}

# The `project_members` output contains the non-authoritative project IAM member resources created by the module.
output "project_members" {
  description = "The non-authoritative project IAM member resources created."
  value       = google_project_iam_member.project_members
}

# The `bucket_members` output contains the non-authoritative storage bucket IAM member resources created by the module.
output "bucket_members" {
  description = "The non-authoritative storage bucket IAM member resources created."
  value       = google_storage_bucket_iam_member.bucket_members
}

# The `service_account_members` output contains the non-authoritative service account IAM member resources created by the module.
output "service_account_members" {
  description = "The non-authoritative service account IAM member resources created."
  value       = google_service_account_iam_member.sa_members
}
