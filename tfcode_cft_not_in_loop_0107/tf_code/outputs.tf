output "project_iam_members" {
  description = "A map of the created `google_project_iam_member` resources, keyed by the index of the input variable `project_iam_members`."
  value       = google_project_iam_member.project_members
}

output "project_iam_bindings" {
  description = "A map of the created `google_project_iam_binding` resources, keyed by the index of the input variable `project_iam_bindings`."
  value       = google_project_iam_binding.project_bindings
}

output "storage_bucket_iam_members" {
  description = "A map of the created `google_storage_bucket_iam_member` resources, keyed by the index of the input variable `storage_bucket_iam_members`."
  value       = google_storage_bucket_iam_member.storage_bucket_members
}

output "storage_bucket_iam_bindings" {
  description = "A map of the created `google_storage_bucket_iam_binding` resources, keyed by the index of the input variable `storage_bucket_iam_bindings`."
  value       = google_storage_bucket_iam_binding.storage_bucket_bindings
}

output "service_account_iam_members" {
  description = "A map of the created `google_service_account_iam_member` resources, keyed by the index of the input variable `service_account_iam_members`."
  value       = google_service_account_iam_member.service_account_members
}

output "service_account_iam_bindings" {
  description = "A map of the created `google_service_account_iam_binding` resources, keyed by the index of the input variable `service_account_iam_bindings`."
  value       = google_service_account_iam_binding.service_account_bindings
}
