# The main.tf file contains the core logic of the module. It defines the resources
# that will be created and managed by Terraform based on the input variables. This
# module focuses on creating various types of IAM policies at the GCP project level.

locals {
  # This local variable flattens the additive_bindings map into a list of objects,
  # where each object represents a single role-member pair. This structure is
  # necessary for creating individual `google_project_iam_member` resources using a for_each loop.
  # If project_id is null, this will be an empty list, preventing resource creation.
  additive_members_flat = var.project_id == null ? [] : flatten([
    for role, members in var.additive_bindings : [
      for member in members : {
        role   = role
        member = member
        # Create a unique key for the for_each loop by combining the role and member.
        key = "${role}/${member}"
      }
    ]
  ])
}

# This resource manages authoritative IAM bindings for a project.
# An IAM binding is an association between a role and a list of members.
# This resource is authoritative for a given role; it will overwrite any
# existing members for that role on the project.
resource "google_project_iam_binding" "authoritative" {
  # Iterate over the `bindings` map to create one binding per role.
  # If project_id is null, the for_each map will be empty, and no resources will be created.
  for_each = var.project_id == null ? {} : var.bindings

  # The ID of the project to which the binding will be applied.
  project = var.project_id

  # The IAM role to be granted. `each.key` refers to the key in the `bindings` map.
  role = each.key

  # The set of members to be granted the role. `each.value` refers to the value in the `bindings` map.
  members = each.value
}

# This resource manages non-authoritative IAM members for a project.
# It adds a single member to a role without affecting other members of that role.
# This is the safest way to grant permissions, as it avoids unintended removal of existing access.
resource "google_project_iam_member" "additive" {
  # Iterate over the flattened list of role-member pairs from the `additive_bindings` variable.
  # A unique key is constructed to ensure Terraform can track each resource individually.
  # If project_id is null, local.additive_members_flat is empty, and no resources will be created.
  for_each = { for item in local.additive_members_flat : item.key => item }

  # The ID of the project to which the member will be added.
  project = var.project_id

  # The IAM role to be granted to the member.
  role = each.value.role

  # The member to be added to the role.
  member = each.value.member
}

# This resource manages authoritative IAM bindings with a condition.
# A conditional binding grants a role to members only when the specified
# condition evaluates to true.
resource "google_project_iam_binding" "conditional" {
  # Iterate over the list of conditional bindings. A unique key is created
  # from the role and title to identify each resource.
  # If project_id is null, the for_each map will be empty, and no resources will be created.
  for_each = var.project_id == null ? {} : { for b in var.conditional_bindings : "${b.role}/${b.title}" => b }

  # The ID of the project to which the conditional binding will be applied.
  project = var.project_id

  # The IAM role to be granted.
  role = each.value.role

  # The set of members to be granted the role, subject to the condition.
  members = each.value.members

  # The condition block that specifies the logic for the binding.
  condition {
    # A title for the condition.
    title = each.value.title

    # An optional description for the condition.
    description = each.value.description

    # The Common Expression Language (CEL) expression that defines the condition.
    expression = each.value.expression
  }
}

# This resource manages IAM audit configurations for a project.
# Audit configs specify which types of log entries are written for a given service.
resource "google_project_iam_audit_config" "audit" {
  # Iterate over the list of audit configs, using the service name as the unique key.
  # If project_id is null, the for_each map will be empty, and no resources will be created.
  for_each = var.project_id == null ? {} : { for config in var.audit_configs : config.service => config }

  # The ID of the project to which the audit config will be applied.
  project = var.project_id

  # The service for which to configure audit logging (e.g., "allServices").
  service = each.key

  # A dynamic block to create one or more `audit_log_config` blocks.
  dynamic "audit_log_config" {
    # Iterate over the list of log configurations for the current service.
    for_each = each.value.audit_log_configs

    # The content of the `audit_log_config` block.
    content {
      # The type of log to record (e.g., "ADMIN_READ", "DATA_WRITE", "DATA_READ").
      log_type = audit_log_config.value.log_type

      # A list of members whose principals are exempt from logging for this log type.
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}
