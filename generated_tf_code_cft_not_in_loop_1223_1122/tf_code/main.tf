# This module is used to create Identity and Access Management (IAM) bindings on
# various Google Cloud resources. It provides a flexible interface to connect a
# principal (user, group, or service account) to a specific role on a project,
# storage bucket, or BigQuery dataset. By using `google_*_iam_member`, this module
# ensures that bindings are managed additively without overwriting existing policies.
# This approach is ideal for managing permissions granularly and adhering to the
# principle of least privilege.
#
# The module supports creating multiple bindings for each resource type in a single
# invocation by accepting maps of binding configurations. This allows for efficient
# and declarative management of IAM policies across different resource types.

# Create IAM member bindings at the project level.
resource "google_project_iam_member" "project_iam_member" {
  # Iterate over each project-level binding defined in the input variables.
  for_each = var.project_bindings

  # The project to apply the IAM policy to.
  project = each.value.project
  # The role to be assigned.
  role = each.value.role
  # The member to whom the role is assigned.
  member = each.value.member
}

# Create IAM member bindings at the Google Cloud Storage bucket level.
# This grants the role on a specific bucket, following the principle of least privilege.
resource "google_storage_bucket_iam_member" "storage_bucket_iam_member" {
  # Iterate over each bucket-level binding defined in the input variables.
  for_each = var.storage_bucket_bindings

  # The name of the bucket to apply the IAM policy to.
  bucket = each.value.bucket
  # The role to be assigned.
  role = each.value.role
  # The member to whom the role is assigned.
  member = each.value.member
}

# Create IAM member bindings at the BigQuery dataset level.
# This scopes permissions to a single dataset, which is a best practice for data governance.
resource "google_bigquery_dataset_iam_member" "bigquery_dataset_iam_member" {
  # Iterate over each dataset-level binding defined in the input variables.
  for_each = var.bigquery_dataset_bindings

  # The project containing the dataset.
  project = each.value.project
  # The ID of the dataset to apply the IAM policy to.
  dataset_id = each.value.dataset_id
  # The role to be assigned.
  role = each.value.role
  # The member to whom the role is assigned.
  member = each.value.member
}
