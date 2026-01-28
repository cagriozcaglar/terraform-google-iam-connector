# The output provides access to the full set of attributes for the created `google_storage_bucket_iam_binding` resources.
output "bucket_bindings" {
  description = "A map of the created google_storage_bucket_iam_binding resources, keyed by the logical names from the input variable."
  value       = google_storage_bucket_iam_binding.bucket_bindings
}

# The output provides access to the full set of attributes for the created `google_storage_bucket_iam_member` resources.
output "bucket_members" {
  description = "A map of the created google_storage_bucket_iam_member resources, keyed by the logical names from the input variable."
  value       = google_storage_bucket_iam_member.bucket_members
}

# The output provides access to the full set of attributes for the created `google_folder_iam_binding` resources.
output "folder_bindings" {
  description = "A map of the created google_folder_iam_binding resources, keyed by the logical names from the input variable."
  value       = google_folder_iam_binding.folder_bindings
}

# The output provides access to the full set of attributes for the created `google_folder_iam_member` resources.
output "folder_members" {
  description = "A map of the created google_folder_iam_member resources, keyed by the logical names from the input variable."
  value       = google_folder_iam_member.folder_members
}

# The output provides access to the full set of attributes for the created `google_organization_iam_binding` resources.
output "organization_bindings" {
  description = "A map of the created google_organization_iam_binding resources, keyed by the logical names from the input variable."
  value       = google_organization_iam_binding.organization_bindings
}

# The output provides access to the full set of attributes for the created `google_organization_iam_member` resources.
output "organization_members" {
  description = "A map of the created google_organization_iam_member resources, keyed by the logical names from the input variable."
  value       = google_organization_iam_member.organization_members
}

# The output provides access to the full set of attributes for the created `google_project_iam_binding` resources.
output "project_bindings" {
  description = "A map of the created google_project_iam_binding resources, keyed by the logical names from the input variable."
  value       = google_project_iam_binding.project_bindings
}

# The output provides access to the full set of attributes for the created `google_project_iam_member` resources.
output "project_members" {
  description = "A map of the created google_project_iam_member resources, keyed by the logical names from the input variable."
  value       = google_project_iam_member.project_members
}
