# Map of GCS bucket-level IAM bindings created.
output "bucket_iam_bindings" {
  description = "Map of GCS bucket-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member."
  value       = google_storage_bucket_iam_member.bucket
}

# Map of folder-level IAM bindings created.
output "folder_iam_bindings" {
  description = "Map of folder-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member."
  value       = google_folder_iam_member.folder
}

# Map of organization-level IAM bindings created.
output "organization_iam_bindings" {
  description = "Map of organization-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member."
  value       = google_organization_iam_member.organization
}

# Map of project-level IAM bindings created.
output "project_iam_bindings" {
  description = "Map of project-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member."
  value       = google_project_iam_member.project
}

# Map of service account-level IAM bindings created.
output "service_account_iam_bindings" {
  description = "Map of service account-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member."
  value       = google_service_account_iam_member.service_account
}
