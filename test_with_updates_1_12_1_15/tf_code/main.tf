# This locals block transforms the input lists into maps suitable for use with `for_each`.
# It filters the lists by `resource_type` and creates a unique key for each item to prevent collisions.
locals {
  # Map of authoritative project bindings, keyed by project ID and role.
  project_bindings = {
    for b in var.iam_bindings : "${b.resource_id}.${b.role}" => b
    if b.resource_type == "project"
  }
  # Map of authoritative bucket bindings, keyed by bucket name and role.
  bucket_bindings = {
    for b in var.iam_bindings : "${b.resource_id}.${b.role}" => b
    if b.resource_type == "storage_bucket"
  }
  # Map of authoritative service account bindings, keyed by service account ID and role.
  sa_bindings = {
    for b in var.iam_bindings : "${b.resource_id}.${b.role}" => b
    if b.resource_type == "service_account"
  }

  # Map of non-authoritative project members, keyed by project ID, role, member, and list index.
  # The index ensures uniqueness if the same member is specified multiple times.
  project_members = {
    for i, m in var.iam_members : "${m.resource_id}.${m.role}.${m.member}.${i}" => m
    if m.resource_type == "project"
  }
  # Map of non-authoritative bucket members, keyed by bucket name, role, member, and list index.
  bucket_members = {
    for i, m in var.iam_members : "${m.resource_id}.${m.role}.${m.member}.${i}" => m
    if m.resource_type == "storage_bucket"
  }
  # Map of non-authoritative service account members, keyed by service account ID, role, member, and list index.
  sa_members = {
    for i, m in var.iam_members : "${m.resource_id}.${m.role}.${m.member}.${i}" => m
    if m.resource_type == "service_account"
  }
}

#
# Authoritative IAM Bindings (google_*_iam_binding)
#

# This resource manages authoritative IAM bindings for Google Cloud Projects.
resource "google_project_iam_binding" "project_bindings" {
  for_each = local.project_bindings
  # The project ID to which the IAM policy is applied.
  project = each.value.resource_id
  # The role that should be applied (e.g., 'roles/viewer').
  role = each.value.role
  # A list of members to which the role is assigned.
  members = each.value.members

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# This resource manages authoritative IAM bindings for Google Cloud Storage Buckets.
resource "google_storage_bucket_iam_binding" "bucket_bindings" {
  for_each = local.bucket_bindings
  # The name of the bucket to which the IAM policy is applied.
  bucket = each.value.resource_id
  # The role that should be applied (e.g., 'roles/storage.objectViewer').
  role = each.value.role
  # A list of members to which the role is assigned.
  members = each.value.members

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# This resource manages authoritative IAM bindings for Google Cloud Service Accounts.
resource "google_service_account_iam_binding" "sa_bindings" {
  for_each = local.sa_bindings
  # The full name of the service account (`projects/{project}/serviceAccounts/{email}`).
  service_account_id = each.value.resource_id
  # The role that should be applied (e.g., 'roles/iam.serviceAccountUser').
  role = each.value.role
  # A list of members to which the role is assigned.
  members = each.value.members

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}


#
# Non-authoritative IAM Members (google_*_iam_member)
#

# This resource manages non-authoritative IAM members for Google Cloud Projects.
resource "google_project_iam_member" "project_members" {
  for_each = local.project_members
  # The project ID to which the IAM policy is applied.
  project = each.value.resource_id
  # The role that should be applied (e.g., 'roles/viewer').
  role = each.value.role
  # The member to which the role is assigned (e.g., 'user:foo@example.com').
  member = each.value.member

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# This resource manages non-authoritative IAM members for Google Cloud Storage Buckets.
resource "google_storage_bucket_iam_member" "bucket_members" {
  for_each = local.bucket_members
  # The name of the bucket to which the IAM policy is applied.
  bucket = each.value.resource_id
  # The role that should be applied (e.g., 'roles/storage.objectViewer').
  role = each.value.role
  # The member to which the role is assigned (e.g., 'user:foo@example.com').
  member = each.value.member

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# This resource manages non-authoritative IAM members for Google Cloud Service Accounts.
resource "google_service_account_iam_member" "sa_members" {
  for_each = local.sa_members
  # The full name of the service account (`projects/{project}/serviceAccounts/{email}`).
  service_account_id = each.value.resource_id
  # The role that should be applied (e.g., 'roles/iam.serviceAccountUser').
  role = each.value.role
  # The member to which the role is assigned (e.g., 'user:foo@example.com').
  member = each.value.member

  # Defines an optional IAM condition.
  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # Title for the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}
