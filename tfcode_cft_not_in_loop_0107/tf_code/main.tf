# This module provides a flexible way to create and manage IAM connections (bindings and members)
# for various Google Cloud Platform resources. It supports additive (`iam_member`) and
# authoritative (`iam_binding`) policies for Projects, Storage Buckets, and Service Accounts.

#
# Project IAM Bindings
#

resource "google_project_iam_member" "project_members" {
  # Description: Creates additive IAM role memberships for GCP projects.
  for_each = { for i, b in var.project_iam_members : i => b }

  # The project ID to which the IAM member will be added.
  project = each.value.project
  # The role that should be applied.
  role = each.value.role
  # The principal to whom the role should be granted.
  member = each.value.member

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}

resource "google_project_iam_binding" "project_bindings" {
  # Description: Creates authoritative IAM role bindings for GCP projects.
  # This will overwrite any existing members for the given role.
  for_each = { for i, b in var.project_iam_bindings : i => b }

  # The project ID to which the IAM binding will be applied.
  project = each.value.project
  # The role that should be applied.
  role = each.value.role
  # A list of principals to whom the role should be granted.
  members = each.value.members

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}

#
# Storage Bucket IAM Bindings
#

resource "google_storage_bucket_iam_member" "storage_bucket_members" {
  # Description: Creates additive IAM role memberships for GCS buckets.
  for_each = { for i, b in var.storage_bucket_iam_members : i => b }

  # The name of the GCS bucket.
  bucket = each.value.bucket
  # The role that should be applied.
  role = each.value.role
  # The principal to whom the role should be granted.
  member = each.value.member

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}

resource "google_storage_bucket_iam_binding" "storage_bucket_bindings" {
  # Description: Creates authoritative IAM role bindings for GCS buckets.
  # This will overwrite any existing members for the given role.
  for_each = { for i, b in var.storage_bucket_iam_bindings : i => b }

  # The name of the GCS bucket.
  bucket = each.value.bucket
  # The role that should be applied.
  role = each.value.role
  # A list of principals to whom the role should be granted.
  members = each.value.members

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}

#
# Service Account IAM Bindings
#

resource "google_service_account_iam_member" "service_account_members" {
  # Description: Creates additive IAM role memberships for GCP service accounts.
  for_each = { for i, b in var.service_account_iam_members : i => b }

  # The full identifier of the service account.
  service_account_id = each.value.service_account_id
  # The role that should be applied.
  role = each.value.role
  # The principal to whom the role should be granted.
  member = each.value.member

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}

resource "google_service_account_iam_binding" "service_account_bindings" {
  # Description: Creates authoritative IAM role bindings for GCP service accounts.
  # This will overwrite any existing members for the given role.
  for_each = { for i, b in var.service_account_iam_bindings : i => b }

  # The full identifier of the service account.
  service_account_id = each.value.service_account_id
  # The role that should be applied.
  role = each.value.role
  # A list of principals to whom the role should be granted.
  members = each.value.members

  # A dynamic block to create a conditional IAM binding.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression that defines the condition.
      expression = condition.value.expression
    }
  }
}
