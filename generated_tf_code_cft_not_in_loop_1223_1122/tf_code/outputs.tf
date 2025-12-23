output "project_bindings" {
  description = "A map of the created google_project_iam_member resources, keyed by the name provided in the input 'project_bindings' map."
  value       = google_project_iam_member.project_iam_member
}

output "storage_bucket_bindings" {
  description = "A map of the created google_storage_bucket_iam_member resources, keyed by the name provided in the input 'storage_bucket_bindings' map."
  value       = google_storage_bucket_iam_member.storage_bucket_iam_member
}

output "bigquery_dataset_bindings" {
  description = "A map of the created google_bigquery_dataset_iam_member resources, keyed by the name provided in the input 'bigquery_dataset_bindings' map."
  value       = google_bigquery_dataset_iam_member.bigquery_dataset_iam_member
}

output "all_binding_ids" {
  description = "A map of all created IAM binding IDs, keyed by the descriptive name from the input maps, prefixed by resource type to avoid collisions."
  value = merge(
    { for k, v in google_project_iam_member.project_iam_member : "project-${k}" => v.id },
    { for k, v in google_storage_bucket_iam_member.storage_bucket_iam_member : "storage-${k}" => v.id },
    { for k, v in google_bigquery_dataset_iam_member.bigquery_dataset_iam_member : "bigquery-${k}" => v.id }
  )
}
