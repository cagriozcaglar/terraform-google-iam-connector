output "authoritative_bindings_etags" {
  description = "A map of etags for the authoritative IAM bindings created, keyed by role."
  value = merge(
    { for k, v in google_project_iam_binding.authoritative : k => v.etag },
    { for k, v in google_folder_iam_binding.authoritative : k => v.etag },
    { for k, v in google_organization_iam_binding.authoritative : k => v.etag }
  )
}

output "additive_members_ids" {
  description = "A map of resource IDs for the additive IAM members created, keyed by 'role/member'."
  value = merge(
    { for k, v in google_project_iam_member.additive : k => v.id },
    { for k, v in google_folder_iam_member.additive : k => v.id },
    { for k, v in google_organization_iam_member.additive : k => v.id }
  )
}
