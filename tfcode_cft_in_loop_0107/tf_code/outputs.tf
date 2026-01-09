output "additive_members" {
  description = "A map of the additive IAM member resources created by this module, keyed by a composite of role and member."
  value = merge(
    google_project_iam_member.additive,
    google_folder_iam_member.additive,
    google_organization_iam_member.additive,
    google_storage_bucket_iam_member.additive,
    google_service_account_iam_member.additive,
    google_pubsub_topic_iam_member.additive
  )
}

output "authoritative_bindings" {
  description = "A map of the authoritative IAM binding resources created by this module, keyed by role."
  value = merge(
    google_project_iam_binding.authoritative,
    google_folder_iam_binding.authoritative,
    google_organization_iam_binding.authoritative,
    google_storage_bucket_iam_binding.authoritative,
    google_service_account_iam_binding.authoritative,
    google_pubsub_topic_iam_binding.authoritative
  )
}
