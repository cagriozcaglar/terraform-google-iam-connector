output "bucket_name" {
  description = "The name of the created GCS bucket."
  value       = google_storage_bucket.example_bucket.name
}

output "test_service_account_email" {
  description = "The email of the service account being managed."
  value       = google_service_account.test_sa.email
}

output "member_service_account_email" {
  description = "The email of the service account being granted permissions."
  value       = google_service_account.member_sa.email
}

output "project_bindings" {
  description = "The authoritative project IAM binding resources created by the module."
  value       = module.iam_manager.project_bindings
}

output "bucket_members" {
  description = "The non-authoritative storage bucket IAM member resources created by the module."
  value       = module.iam_manager.bucket_members
}

output "service_account_members" {
  description = "The non-authoritative service account IAM member resources created by the module."
  value       = module.iam_manager.service_account_members
}
