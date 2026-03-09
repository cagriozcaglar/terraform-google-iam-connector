output "iam_results" {
  description = "A map of the full resource IDs of the IAM bindings or policies that were created, keyed by a unique identifier combining the resource and role."
  value = merge(
    { for k, v in google_project_iam_binding.project_additive : k => v.id },
    { for k, v in google_storage_bucket_iam_binding.bucket_additive : k => v.id },
    { for k, v in google_pubsub_topic_iam_binding.topic_additive : k => v.id },
    { for k, v in google_project_iam_policy.project_authoritative : k => v.id },
    { for k, v in google_storage_bucket_iam_policy.bucket_authoritative : k => v.id },
    { for k, v in google_pubsub_topic_iam_policy.topic_authoritative : k => v.id }
  )
}
