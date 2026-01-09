# -------------------------------------------------------------------------------------
# IAM Connector Module
#
# This module provides a generic interface for creating IAM bindings on various
# Google Cloud resources. It supports authoritative (`iam_binding`) and additive
# (`iam_member`) modes, as well as conditional bindings. This module helps enforce
# the principle of least privilege by allowing granular control over permissions.
#
# Usage:
# To use this module, specify exactly one resource scope identifier (e.g., `project_id`,
# `bucket_name`) and provide a map of IAM bindings.
# -------------------------------------------------------------------------------------

locals {
  # Determine the single active resource scope from the provided variables.
  # This approach enforces that exactly one scope variable is set.
  scopes = {
    project = var.project_id != null ? {
      # The resource ID used in the google provider resources.
      id   = var.project_id
      # The type identifier used for conditional resource creation.
      type = "project"
    } : null
    folder = var.folder_id != null ? {
      # The resource ID used in the google provider resources. This handles both `folders/123` and `123`.
      id   = basename(var.folder_id)
      # The type identifier used for conditional resource creation.
      type = "folder"
    } : null
    organization = var.organization_id != null ? {
      # The resource ID used in the google provider resources.
      id   = var.organization_id
      # The type identifier used for conditional resource creation.
      type = "organization"
    } : null
    storage_bucket = var.bucket_name != null ? {
      # The resource ID used in the google provider resources.
      id   = var.bucket_name
      # The type identifier used for conditional resource creation.
      type = "storage_bucket"
    } : null
    service_account = var.service_account_email != null ? {
      # The resource ID used in the google provider resources.
      # This handles both a plain email and a fully qualified service account ID.
      id   = strcontains(var.service_account_email, "/") ? var.service_account_email : "projects/-/serviceAccounts/${var.service_account_email}"
      # The type identifier used for conditional resource creation.
      type = "service_account"
    } : null
    pubsub_topic = var.pubsub_topic_id != null ? {
      # The resource ID used in the google provider resources.
      id   = var.pubsub_topic_id
      # The type identifier used for conditional resource creation.
      type = "pubsub_topic"
    } : null
  }

  # Filter out the null scopes to find the active ones.
  active_scopes = { for k, v in local.scopes : k => v if v != null }

  # Get the single active scope. This will be null if zero or more than one scopes are defined.
  active_scope = length(local.active_scopes) == 1 ? values(local.active_scopes)[0] : null

  # Get the type of the active scope, or null if no single scope is active.
  # This prevents "Attempt to get attribute from null value" errors in for_each expressions
  # when no scope is defined and local.active_scope is null.
  active_scope_type = try(local.active_scope.type, null)

  # For additive mode, flatten the bindings map into a list of {role, member, condition} objects.
  # This structure is suitable for iterating with for_each in iam_member resources.
  additive_members = var.mode == "additive" ? flatten([
    for role, binding_details in var.bindings : [
      for member in binding_details.members : {
        # A unique key for for_each composed of role and member.
        key = "${role}::${member}"
        # The IAM role to grant.
        role = role
        # The member to grant the role to.
        member = member
        # The optional IAM condition.
        condition = binding_details.condition
      }
    ]
  ]) : []

  # Create a map of additive members for for_each, using the generated unique key.
  additive_members_map = { for item in local.additive_members : item.key => item }
}

# This resource acts as a pre-condition check. It will cause a plan-time error
# if the resource scope variables are misconfigured.
resource "null_resource" "precondition_check" {
  # Lifecycle rule to ensure the check is performed during the plan phase.
  lifecycle {
    # Precondition block to enforce input validation.
    precondition {
      # The condition checks for two things:
      # 1. At most one resource scope (project_id, folder_id, etc.) is provided.
      # 2. If any bindings are specified, then exactly one resource scope must be provided.
      condition     = length(local.active_scopes) <= 1 && (length(var.bindings) == 0 || length(local.active_scopes) == 1)
      # The error message to display if the condition is false.
      error_message = "Invalid resource scope configuration. At most one scope (e.g., project_id, folder_id) can be specified. If 'bindings' are provided, exactly one scope is required. Found ${length(local.active_scopes)} scopes with ${length(keys(var.bindings))} binding role(s)."
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Project
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for a project.
resource "google_project_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'project'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "project" ? var.bindings : {}

  # The ID of the project to which the IAM policy is applied.
  project = local.active_scope.id
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a project.
resource "google_project_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'project'.
  for_each = var.mode == "additive" && local.active_scope_type == "project" ? local.additive_members_map : {}

  # The ID of the project to which the IAM policy is applied.
  project = local.active_scope.id
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Folder
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for a folder.
resource "google_folder_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'folder'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "folder" ? var.bindings : {}

  # The folder to apply the IAM policies to, in the format `folders/{folder_id}`.
  folder = "folders/${local.active_scope.id}"
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a folder.
resource "google_folder_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'folder'.
  for_each = var.mode == "additive" && local.active_scope_type == "folder" ? local.additive_members_map : {}

  # The folder to apply the IAM policies to, in the format `folders/{folder_id}`.
  folder = "folders/${local.active_scope.id}"
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Organization
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for an organization.
resource "google_organization_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'organization'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "organization" ? var.bindings : {}

  # The numeric ID of the organization to apply the IAM policies to.
  org_id = local.active_scope.id
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for an organization.
resource "google_organization_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'organization'.
  for_each = var.mode == "additive" && local.active_scope_type == "organization" ? local.additive_members_map : {}

  # The numeric ID of the organization to apply the IAM policies to.
  org_id = local.active_scope.id
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Storage Bucket
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for a GCS bucket.
resource "google_storage_bucket_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'storage_bucket'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "storage_bucket" ? var.bindings : {}

  # The bucket to apply the IAM policies to, prefixed with 'gs://'.
  bucket = "gs://${local.active_scope.id}"
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a GCS bucket.
resource "google_storage_bucket_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'storage_bucket'.
  for_each = var.mode == "additive" && local.active_scope_type == "storage_bucket" ? local.additive_members_map : {}

  # The bucket to apply the IAM policies to, prefixed with 'gs://'.
  bucket = "gs://${local.active_scope.id}"
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Service Account
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for a service account.
resource "google_service_account_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'service_account'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "service_account" ? var.bindings : {}

  # The fully-qualified name of the service account to apply policy to.
  service_account_id = local.active_scope.id
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a service account.
resource "google_service_account_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'service_account'.
  for_each = var.mode == "additive" && local.active_scope_type == "service_account" ? local.additive_members_map : {}

  # The fully-qualified name of the service account to apply policy to.
  service_account_id = local.active_scope.id
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# ------------------------------------------------------------------------------
# IAM Bindings for Google Pub/Sub Topic
# ------------------------------------------------------------------------------

# Creates authoritative IAM bindings for a Pub/Sub Topic.
resource "google_pubsub_topic_iam_binding" "authoritative" {
  # Creates a binding for each role defined in the bindings variable, if mode is 'authoritative' and scope is 'pubsub_topic'.
  for_each = var.mode == "authoritative" && local.active_scope_type == "pubsub_topic" ? var.bindings : {}

  # The ID of the topic to apply the IAM policies to.
  topic = local.active_scope.id
  # The role that should be applied.
  role = each.key
  # A list of IAM members to grant the role to.
  members = each.value.members

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current binding.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}

# Creates additive IAM members for a Pub/Sub Topic.
resource "google_pubsub_topic_iam_member" "additive" {
  # Creates a member resource for each role-member pair, if mode is 'additive' and scope is 'pubsub_topic'.
  for_each = var.mode == "additive" && local.active_scope_type == "pubsub_topic" ? local.additive_members_map : {}

  # The ID of the topic to apply the IAM policies to.
  topic = local.active_scope.id
  # The role that should be applied.
  role = each.value.role
  # The member to grant the role to.
  member = each.value.member

  # Optional IAM condition block.
  dynamic "condition" {
    # Iterate if a condition is defined for the current member.
    for_each = each.value.condition != null ? [each.value.condition] : []
    # The content of the condition block.
    content {
      # The title of the condition.
      title = condition.value.title
      # An optional description of the condition.
      description = try(condition.value.description, null)
      # The Common Expression Language (CEL) expression of the condition.
      expression = condition.value.expression
    }
  }
}
