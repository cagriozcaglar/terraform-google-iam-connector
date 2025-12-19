locals {
  # Create a unique key for each conditional binding to use in for_each.
  # Example key: "roles/editor/user:temp-contractor@external.com"
  conditional_members_map = {
    for b in var.conditional_bindings : "${b.role}/${b.member}" => b
  }
}

# This dummy resource enforces that exactly one of project_id, folder_id, or organization_id is provided.
# It will only be created if at least one ID is specified, and the precondition will then validate the input.
resource "null_resource" "module_validation" {
  # The number of resources to create.
  count = var.project_id == null && var.folder_id == null && var.organization_id == null ? 0 : 1

  lifecycle {
    precondition {
      # The condition to evaluate.
      condition     = (var.project_id != null ? 1 : 0) + (var.folder_id != null ? 1 : 0) + (var.organization_id != null ? 1 : 0) == 1
      # The error message to display if the condition is false.
      error_message = "Exactly one of 'project_id', 'folder_id', or 'organization_id' must be specified."
    }
  }
}

# -----------------------------------------------------------------------------
# Authoritative IAM Bindings (google_*_iam_binding)
# Manages the full list of members for a given role. This is the recommended
# approach for managing team access as it prevents drift.
# -----------------------------------------------------------------------------

# Creates authoritative IAM bindings for a GCP Project.
resource "google_project_iam_binding" "authoritative" {
  # Iterates over the `bindings` map only if a `project_id` is provided.
  for_each = var.project_id != null ? var.bindings : {}

  # The project to apply the IAM policies to.
  project = var.project_id
  # The role that should be applied.
  role = each.key
  # A list of members who should be granted the role.
  members = each.value
}

# Creates authoritative IAM bindings for a GCP Folder.
resource "google_folder_iam_binding" "authoritative" {
  # Iterates over the `bindings` map only if a `folder_id` is provided.
  for_each = var.folder_id != null ? var.bindings : {}

  # The folder to apply the IAM policies to.
  folder = var.folder_id
  # The role that should be applied.
  role = each.key
  # A list of members who should be granted the role.
  members = each.value
}

# Creates authoritative IAM bindings for a GCP Organization.
resource "google_organization_iam_binding" "authoritative" {
  # Iterates over the `bindings` map only if an `organization_id` is provided.
  for_each = var.organization_id != null ? var.bindings : {}

  # The organization to apply the IAM policies to.
  org_id = var.organization_id
  # The role that should be applied.
  role = each.key
  # A list of members who should be granted the role.
  members = each.value
}

# -----------------------------------------------------------------------------
# Additive IAM Members (google_*_iam_member)
# Adds a single member to a role without affecting other members.
# Useful for one-off grants or for applying IAM Conditions.
# -----------------------------------------------------------------------------

# Creates additive IAM members for a GCP Project.
resource "google_project_iam_member" "additive" {
  # Iterates over the `conditional_bindings` list only if a `project_id` is provided.
  for_each = var.project_id != null ? local.conditional_members_map : {}

  # The project to apply the IAM policies to.
  project = var.project_id
  # The role that should be applied.
  role = each.value.role
  # The member who should be granted the role.
  member = each.value.member

  # A dynamic block to create a condition only if one is specified in the input.
  dynamic "condition" {
    # Iterates over a list containing the condition object, or an empty list if no condition is set.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the IAM condition.
      title = condition.value.title
      # A description for the IAM condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression for the IAM condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a GCP Folder.
resource "google_folder_iam_member" "additive" {
  # Iterates over the `conditional_bindings` list only if a `folder_id` is provided.
  for_each = var.folder_id != null ? local.conditional_members_map : {}

  # The folder to apply the IAM policies to.
  folder = var.folder_id
  # The role that should be applied.
  role = each.value.role
  # The member who should be granted the role.
  member = each.value.member

  # A dynamic block to create a condition only if one is specified in the input.
  dynamic "condition" {
    # Iterates over a list containing the condition object, or an empty list if no condition is set.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the IAM condition.
      title = condition.value.title
      # A description for the IAM condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression for the IAM condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a GCP Organization.
resource "google_organization_iam_member" "additive" {
  # Iterates over the `conditional_bindings` list only if an `organization_id` is provided.
  for_each = var.organization_id != null ? local.conditional_members_map : {}

  # The organization to apply the IAM policies to.
  org_id = var.organization_id
  # The role that should be applied.
  role = each.value.role
  # The member who should be granted the role.
  member = each.value.member

  # A dynamic block to create a condition only if one is specified in the input.
  dynamic "condition" {
    # Iterates over a list containing the condition object, or an empty list if no condition is set.
    for_each = each.value.condition != null ? [each.value.condition] : []
    content {
      # The title of the IAM condition.
      title = condition.value.title
      # A description for the IAM condition.
      description = condition.value.description
      # The Common Expression Language (CEL) expression for the IAM condition.
      expression = condition.value.expression
    }
  }
}
