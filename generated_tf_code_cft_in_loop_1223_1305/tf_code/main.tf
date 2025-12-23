# This check block ensures that only one resource identifier (e.g., project, folder) is provided.
check "one_resource_provided" {
  # Precondition to ensure mutual exclusivity of target resource variables.
  assert {
    condition     = local.num_resources_provided <= 1
    error_message = "Only one of 'project', 'folder', 'organization', 'bucket', or 'service_account' variables can be specified."
  }
}

# This check block ensures that if bindings are specified, a target resource is also specified.
check "resource_provided_with_bindings" {
  # Precondition to ensure a target resource is specified when bindings are provided.
  assert {
    condition     = !(length(var.bindings) > 0 && local.num_resources_provided == 0)
    error_message = "If 'bindings' are provided, one of 'project', 'folder', 'organization', 'bucket', or 'service_account' must be specified."
  }
}

locals {
  # Count how many resource identifiers have been provided to enforce mutual exclusivity.
  num_resources_provided = length([for v in [var.project, var.folder, var.organization, var.bucket, var.service_account] : v if v != null])

  # Create a flattened list of bindings, where each element represents a single member-role assignment.
  # This is necessary because google_*_iam_member resources manage a single role-member pair,
  # while the input `bindings` variable can specify multiple members for a single role.
  flattened_bindings = flatten([
    for b_key, b_val in var.bindings : [
      for member in b_val.members : {
        # A composite key for uniqueness within the list. Using jsonencode is more robust than string interpolation with a separator.
        key       = jsonencode([b_key, b_val.role, member])
        role      = b_val.role
        member    = member
        condition = b_val.condition
      }
    ]
  ])

  # Convert the flattened list into a map for use with for_each.
  # The key is a JSON-encoded tuple of the binding key, role, and member, ensuring uniqueness.
  binding_map = {
    for b in local.flattened_bindings : b.key => b
  }

  # Ensure folder ID has the 'folders/' prefix, making the module more robust.
  folder_id = var.folder != null ? (startswith(var.folder, "folders/") ? var.folder : "folders/${var.folder}") : null

  # Ensure organization ID is just the numeric ID by stripping any prefix, making the module more robust.
  organization_id = var.organization != null ? basename(var.organization) : null
}

# Creates IAM bindings on a Google Cloud Storage Bucket.
resource "google_storage_bucket_iam_member" "bucket" {
  # Create a binding for each unique role-member pair if a bucket name is specified.
  for_each = var.bucket != null ? local.binding_map : {}

  # The bucket to apply the IAM policies to.
  bucket = var.bucket
  # The role that should be applied.
  role = each.value.role
  # The member (user, group, service account) to grant the role to.
  member = each.value.member

  # An IAM Condition, which specifies a condition that must be met for the binding to apply.
  dynamic "condition" {
    # The condition block is only added if a condition is defined for the binding.
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

# Creates IAM bindings at the Folder level.
resource "google_folder_iam_member" "folder" {
  # Create a binding for each unique role-member pair if a folder ID is specified.
  for_each = var.folder != null ? local.binding_map : {}

  # The folder to apply the IAM policies to.
  folder = local.folder_id
  # The role that should be applied.
  role = each.value.role
  # The member (user, group, service account) to grant the role to.
  member = each.value.member

  # An IAM Condition, which specifies a condition that must be met for the binding to apply.
  dynamic "condition" {
    # The condition block is only added if a condition is defined for the binding.
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

# Creates IAM bindings at the Organization level.
resource "google_organization_iam_member" "organization" {
  # Create a binding for each unique role-member pair if an organization ID is specified.
  for_each = var.organization != null ? local.binding_map : {}

  # The organization to apply the IAM policies to.
  org_id = local.organization_id
  # The role that should be applied.
  role = each.value.role
  # The member (user, group, service account) to grant the role to.
  member = each.value.member

  # An IAM Condition, which specifies a condition that must be met for the binding to apply.
  dynamic "condition" {
    # The condition block is only added if a condition is defined for the binding.
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

# Creates IAM bindings at the Project level.
resource "google_project_iam_member" "project" {
  # Create a binding for each unique role-member pair if a project ID is specified.
  for_each = var.project != null ? local.binding_map : {}

  # The project to apply the IAM policies to.
  project = var.project
  # The role that should be applied.
  role = each.value.role
  # The member (user, group, service account) to grant the role to.
  member = each.value.member

  # An IAM Condition, which specifies a condition that must be met for the binding to apply.
  dynamic "condition" {
    # The condition block is only added if a condition is defined for the binding.
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

# Creates IAM bindings on a Service Account.
resource "google_service_account_iam_member" "service_account" {
  # Create a binding for each unique role-member pair if a service account ID is specified.
  for_each = var.service_account != null ? local.binding_map : {}

  # The fully-qualified name of the service account to apply the IAM policies to.
  service_account_id = var.service_account
  # The role that should be applied.
  role = each.value.role
  # The member (user, group, service account) to grant the role to.
  member = each.value.member

  # An IAM Condition, which specifies a condition that must be met for the binding to apply.
  dynamic "condition" {
    # The condition block is only added if a condition is defined for the binding.
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
