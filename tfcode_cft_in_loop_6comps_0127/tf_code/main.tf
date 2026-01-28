# This locals block preprocesses the input variables to filter IAM grants by resource type,
# and to perform validation checks.
locals {
  # Filters the `bindings` variable to include only those intended for projects.
  project_bindings = { for k, v in var.bindings : k => v if v.project_id != null }
  # Filters the `bindings` variable to include only those intended for folders.
  folder_bindings = { for k, v in var.bindings : k => v if v.folder_id != null }
  # Filters the `bindings` variable to include only those intended for organizations.
  organization_bindings = { for k, v in var.bindings : k => v if v.org_id != null }
  # Filters the `bindings` variable to include only those intended for storage buckets.
  bucket_bindings = { for k, v in var.bindings : k => v if v.bucket != null }

  # Filters the `members` variable to include only those intended for projects.
  project_members = { for k, v in var.members : k => v if v.project_id != null }
  # Filters the `members` variable to include only those intended for folders.
  folder_members = { for k, v in var.members : k => v if v.folder_id != null }
  # Filters the `members` variable to include only those intended for organizations.
  organization_members = { for k, v in var.members : k => v if v.org_id != null }
  # Filters the `members` variable to include only those intended for storage buckets.
  bucket_members = { for k, v in var.members : k => v if v.bucket != null }

  # Creates a set of unique resource-role identifiers for bindings to detect conflicts.
  # A prefix is added to distinguish between resource types (e.g., a project ID and a bucket name that are identical).
  # Folder and Org IDs are normalized to their numeric representation.
  binding_keys = toset([
    for binding in values(var.bindings) :
    "${
      binding.project_id != null ? "project:${binding.project_id}" :
      binding.folder_id != null ? "folder:${trimprefix(binding.folder_id, "folders/")}" :
      binding.org_id != null ? "organization:${trimprefix(binding.org_id, "organizations/")}" :
      "bucket:${binding.bucket}"
    }:${binding.role}"
  ])

  # Creates a set of unique resource-role identifiers for members to detect conflicts.
  # A prefix is added to distinguish between resource types (e.g., a project ID and a bucket name that are identical).
  # Folder and Org IDs are normalized to their numeric representation.
  member_keys = toset([
    for member in values(var.members) :
    "${
      member.project_id != null ? "project:${member.project_id}" :
      member.folder_id != null ? "folder:${trimprefix(member.folder_id, "folders/")}" :
      member.org_id != null ? "organization:${trimprefix(member.org_id, "organizations/")}" :
      "bucket:${member.bucket}"
    }:${member.role}"
  ])

  # Identifies conflicting keys that appear in both authoritative bindings and non-authoritative members.
  conflicting_keys = setintersection(local.binding_keys, local.member_keys)

  # A set of primitive IAM roles that are discouraged for use.
  primitive_roles = toset(["roles/owner", "roles/editor", "roles/viewer"])

  # A set of all roles specified in the input variables.
  all_roles = toset(concat(
    [for b in values(var.bindings) : b.role],
    [for m in values(var.members) : m.role]
  ))

  # Identifies roles that do not follow the expected format for predefined or custom roles.
  invalidly_formatted_roles = [
    for role in local.all_roles : role
    if !(startswith(role, "roles/") || startswith(role, "projects/") || startswith(role, "organizations/"))
  ]

  # A set of primitive roles that are currently in use, for validation purposes.
  primitive_roles_in_use = setintersection(local.primitive_roles, local.all_roles)
}

# This check validates that a given resource and role are not targeted by both an
# authoritative binding and a non-authoritative member grant. Such a configuration
# would lead to a perpetual diff in Terraform.
check "no_binding_member_conflict" {
  assert {
    # The condition checks if there are any conflicting keys.
    condition     = length(local.conflicting_keys) == 0
    # The error message lists the conflicting resource:role pairs.
    error_message = "A resource and role cannot be specified in both 'bindings' (authoritative) and 'members' (non-authoritative) variables. Conflicts found for: ${join(", ", local.conflicting_keys)}"
  }
}

# This check validates that all specified IAM roles follow a valid format.
# Roles should either be predefined (e.g., `roles/viewer`) or custom roles
# with a full resource path (e.g., `projects/my-project/roles/myCustomRole`).
check "valid_role_format" {
  assert {
    # The condition checks if there are any roles with an invalid format.
    condition     = length(local.invalidly_formatted_roles) == 0
    # The error message lists the invalid roles.
    error_message = "Invalid IAM role format. Roles must be predefined (e.g., 'roles/viewer') or custom (e.g., 'projects/my-project/roles/myCustomRole'). The following roles are invalid: ${join(", ", local.invalidly_formatted_roles)}"
  }
}

# This check validates that primitive roles are not used if forbidden by the `forbid_primitive_roles` variable.
# Using fine-grained predefined or custom roles is a security best practice.
check "no_primitive_roles" {
  assert {
    # The condition is always true if `forbid_primitive_roles` is false.
    # Otherwise, it checks that no primitive roles are in use.
    condition     = !var.forbid_primitive_roles || length(local.primitive_roles_in_use) == 0
    # The error message explains why the check failed and lists the conflicting roles.
    error_message = "Usage of primitive roles (owner, editor, viewer) is discouraged by the 'forbid_primitive_roles' setting. The following primitive roles were found: ${join(", ", local.primitive_roles_in_use)}"
  }
}

# Creates IAM bindings for Google Cloud Storage Buckets. An IAM binding is authoritative for a single role.
resource "google_storage_bucket_iam_binding" "bucket_bindings" {
  # Iterates over the filtered map of bucket bindings.
  for_each = local.bucket_bindings

  # The name of the bucket to which the IAM binding will be applied.
  bucket = each.value.bucket
  # The role that will be assigned to the members.
  role = each.value.role
  # The list of members to whom the role will be assigned.
  members = each.value.members

  # Optional IAM condition for the binding.
  dynamic "condition" {
    # Creates a condition block if one is defined for the binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM member grants for Google Cloud Storage Buckets. An IAM member grant is non-authoritative.
resource "google_storage_bucket_iam_member" "bucket_members" {
  # Iterates over the filtered map of bucket members.
  for_each = local.bucket_members

  # The name of the bucket to which the IAM member will be added.
  bucket = each.value.bucket
  # The role that will be assigned to the member.
  role = each.value.role
  # The member to whom the role will be assigned.
  member = each.value.member

  # Optional IAM condition for the member grant.
  dynamic "condition" {
    # Creates a condition block if one is defined for the member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM bindings for Google Cloud Folders. An IAM binding is authoritative for a single role.
resource "google_folder_iam_binding" "folder_bindings" {
  # Iterates over the filtered map of folder bindings.
  for_each = local.folder_bindings

  # The ID of the folder to which the IAM binding will be applied. The provider expects the numeric folder ID, without the "folders/" prefix.
  folder = trimprefix(each.value.folder_id, "folders/")
  # The role that will be assigned to the members.
  role = each.value.role
  # The list of members to whom the role will be assigned.
  members = each.value.members

  # Optional IAM condition for the binding.
  dynamic "condition" {
    # Creates a condition block if one is defined for the binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM member grants for Google Cloud Folders. An IAM member grant is non-authoritative.
resource "google_folder_iam_member" "folder_members" {
  # Iterates over the filtered map of folder members.
  for_each = local.folder_members

  # The ID of the folder to which the IAM member will be added. The provider expects the numeric folder ID, without the "folders/" prefix.
  folder = trimprefix(each.value.folder_id, "folders/")
  # The role that will be assigned to the member.
  role = each.value.role
  # The member to whom the role will be assigned.
  member = each.value.member

  # Optional IAM condition for the member grant.
  dynamic "condition" {
    # Creates a condition block if one is defined for the member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM bindings for Google Cloud Organizations. An IAM binding is authoritative for a single role.
resource "google_organization_iam_binding" "organization_bindings" {
  # Iterates over the filtered map of organization bindings.
  for_each = local.organization_bindings

  # The ID of the organization to which the IAM binding will be applied. The provider expects the numeric organization ID, without the "organizations/" prefix.
  org_id = trimprefix(each.value.org_id, "organizations/")
  # The role that will be assigned to the members.
  role = each.value.role
  # The list of members to whom the role will be assigned.
  members = each.value.members

  # Optional IAM condition for the binding.
  dynamic "condition" {
    # Creates a condition block if one is defined for the binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM member grants for Google Cloud Organizations. An IAM member grant is non-authoritative.
resource "google_organization_iam_member" "organization_members" {
  # Iterates over the filtered map of organization members.
  for_each = local.organization_members

  # The ID of the organization to which the IAM member will be added. The provider expects the numeric organization ID, without the "organizations/" prefix.
  org_id = trimprefix(each.value.org_id, "organizations/")
  # The role that will be assigned to the member.
  role = each.value.role
  # The member to whom the role will be assigned.
  member = each.value.member

  # Optional IAM condition for the member grant.
  dynamic "condition" {
    # Creates a condition block if one is defined for the member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM bindings for Google Cloud Projects. An IAM binding is authoritative for a single role.
resource "google_project_iam_binding" "project_bindings" {
  # Iterates over the filtered map of project bindings.
  for_each = local.project_bindings

  # The ID of the project to which the IAM binding will be applied.
  project = each.value.project_id
  # The role that will be assigned to the members.
  role = each.value.role
  # The list of members to whom the role will be assigned.
  members = each.value.members

  # Optional IAM condition for the binding.
  dynamic "condition" {
    # Creates a condition block if one is defined for the binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates IAM member grants for Google Cloud Projects. An IAM member grant is non-authoritative.
resource "google_project_iam_member" "project_members" {
  # Iterates over the filtered map of project members.
  for_each = local.project_members

  # The ID of the project to which the IAM member will be added.
  project = each.value.project_id
  # The role that will be assigned to the member.
  role = each.value.role
  # The member to whom the role will be assigned.
  member = each.value.member

  # Optional IAM condition for the member grant.
  dynamic "condition" {
    # Creates a condition block if one is defined for the member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = condition.value.description
      # The CEL expression of the condition.
      expression = condition.value.expression
    }
  }
}
