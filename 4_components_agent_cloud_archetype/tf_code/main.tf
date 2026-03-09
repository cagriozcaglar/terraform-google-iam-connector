# <!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# This module provides a generic way to manage IAM bindings for multiple Google Cloud resource types.
# It supports both additive bindings, which preserve existing IAM policies, and authoritative policies,
# which replace all existing bindings for a given role. This is useful for centrally managing
# IAM permissions across different resources like projects, storage buckets, and Pub/Sub topics
# based on a common map of roles and members.
#
# The module intelligently dispatches to the correct Terraform IAM resource based on the format
# of the resource ID provided.
#
# Currently supported resource ID formats:
# - Projects: `projects/project-id`
# - Storage Buckets: `projects/project-id/buckets/bucket-name`
# - Pub/Sub Topics: `projects/project-id/topics/topic-name`
# <!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

locals {
  # Use a non-slash delimiter for creating unique keys for the flattened map.
  # This prevents issues with role names that might contain slashes.
  delimiter = "@@@"

  # Flatten the resources and bindings into a single map for easier iteration in additive mode.
  # Each entry represents a unique combination of a resource and a role.
  additive_bindings = {
    for pair in setproduct(var.resources, keys(var.bindings)) :
    "${pair[0]}${local.delimiter}${pair[1]}" => {
      resource = pair[0]
      role     = pair[1]
      members  = var.bindings[pair[1]]
    } if var.mode == "additive" && length(var.bindings[pair[1]]) > 0
  }

  # Filter the flattened map to create dedicated maps for each supported resource type in additive mode.
  # This allows using for_each with the correct Terraform resource type.
  project_additive_bindings = {
    for k, v in local.additive_bindings : k => v if(
      # Matches "projects/project-id" format.
      length(split("/", v.resource)) == 2 && split("/", v.resource)[0] == "projects"
    )
  }
  bucket_additive_bindings = {
    for k, v in local.additive_bindings : k => v if(
      # Matches "projects/project-id/buckets/bucket-name" format.
      length(split("/", v.resource)) == 4 && split("/", v.resource)[2] == "buckets"
    )
  }
  topic_additive_bindings = {
    for k, v in local.additive_bindings : k => v if(
      # Matches "projects/project-id/topics/topic-name" format.
      length(split("/", v.resource)) == 4 && split("/", v.resource)[2] == "topics"
    )
  }

  # For authoritative mode, group resources by their type to apply a complete policy.
  authoritative_projects = {
    for r in var.resources : r => var.bindings if(
      var.mode == "authoritative" && length(split("/", r)) == 2 && split("/", r)[0] == "projects"
    )
  }
  authoritative_buckets = {
    for r in var.resources : r => var.bindings if(
      var.mode == "authoritative" && length(split("/", r)) == 4 && split("/", r)[2] == "buckets"
    )
  }
  authoritative_topics = {
    for r in var.resources : r => var.bindings if(
      var.mode == "authoritative" && length(split("/", r)) == 4 && split("/", r)[2] == "topics"
    )
  }
}

#
# Additive IAM Bindings
# These resources add IAM bindings without affecting existing ones.
#

# Manages additive IAM bindings for Google Cloud projects.
resource "google_project_iam_binding" "project_additive" {
  for_each = local.project_additive_bindings

  project = split("/", each.value.resource)[1]
  role    = each.value.role
  members = each.value.members
}

# Manages additive IAM bindings for Google Cloud Storage buckets.
resource "google_storage_bucket_iam_binding" "bucket_additive" {
  for_each = local.bucket_additive_bindings

  bucket  = split("/", each.value.resource)[3]
  role    = each.value.role
  members = each.value.members
}

# Manages additive IAM bindings for Google Cloud Pub/Sub topics.
resource "google_pubsub_topic_iam_binding" "topic_additive" {
  for_each = local.topic_additive_bindings

  project = split("/", each.value.resource)[1]
  topic   = split("/", each.value.resource)[3]
  role    = each.value.role
  members = each.value.members
}

#
# Authoritative IAM Policies
# These resources replace all existing IAM policies for the given resource.
# Use with caution as this can remove essential permissions.
#

# Constructs an IAM policy document for projects in authoritative mode.
data "google_iam_policy" "project_policy_builder" {
  for_each = local.authoritative_projects

  # Defines a binding for a role to a list of members.
  dynamic "binding" {
    for_each = each.value
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

# Manages authoritative IAM policies for Google Cloud projects.
resource "google_project_iam_policy" "project_authoritative" {
  for_each = local.authoritative_projects

  project     = split("/", each.key)[1]
  policy_data = data.google_iam_policy.project_policy_builder[each.key].policy_data
}

# Constructs an IAM policy document for buckets in authoritative mode.
data "google_iam_policy" "bucket_policy_builder" {
  for_each = local.authoritative_buckets

  # Defines a binding for a role to a list of members.
  dynamic "binding" {
    for_each = each.value
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

# Manages authoritative IAM policies for Google Cloud Storage buckets.
resource "google_storage_bucket_iam_policy" "bucket_authoritative" {
  for_each = local.authoritative_buckets

  bucket      = split("/", each.key)[3]
  policy_data = data.google_iam_policy.bucket_policy_builder[each.key].policy_data
}

# Constructs an IAM policy document for topics in authoritative mode.
data "google_iam_policy" "topic_policy_builder" {
  for_each = local.authoritative_topics

  # Defines a binding for a role to a list of members.
  dynamic "binding" {
    for_each = each.value
    content {
      role    = binding.key
      members = binding.value
    }
  }
}

# Manages authoritative IAM policies for Google Cloud Pub/Sub topics.
resource "google_pubsub_topic_iam_policy" "topic_authoritative" {
  for_each = local.authoritative_topics

  project     = split("/", each.key)[1]
  topic       = split("/", each.key)[3]
  policy_data = data.google_iam_policy.topic_policy_builder[each.key].policy_data
}
