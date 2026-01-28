# The outputs.tf file defines the values that will be exposed by the module.
# Outputs can be used to pass information about the resources created by this module
# to other parts of your Terraform configuration.

output "project_id" {
  description = "The ID of the project where the IAM policies were applied."
  value       = var.project_id
}

output "authoritative_bindings_roles" {
  description = "A list of roles managed with authoritative bindings."
  value       = keys(google_project_iam_binding.authoritative)
}

output "additive_members" {
  description = "A map of non-authoritative IAM members created, keyed by role and member."
  value       = google_project_iam_member.additive
}

output "conditional_bindings_roles" {
  description = "A set of roles managed with conditional bindings."
  value       = toset([for b in google_project_iam_binding.conditional : b.role])
}
