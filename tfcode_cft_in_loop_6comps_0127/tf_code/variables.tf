# This variable defines a map of authoritative IAM bindings to be created.
# Each key in the map represents a unique logical name for an IAM binding.
# The value is an object that specifies the role, members, the resource to which the binding applies, and an optional condition.
variable "bindings" {
  description = <<-EOD
  A map of IAM bindings to create. The key of the map is a logical name for the binding, and the value is the binding configuration.
  An IAM binding is authoritative for a single role. It replaces any existing IAM policy binding for that role.
  Note: `google_*_iam_binding` is authoritative for a single role. It will overwrite any existing members for that role. Be cautious when using this resource, especially on roles managed by Google, as it can remove default service accounts or other essential grants.

  Each binding object has the following attributes:
  - `role`: (Required|string) The role that should be applied. e.g., 'roles/storage.objectViewer'.
  - `members`: (Required|list(string)) A list of identities that will be granted the privilege of the role. e.g., ['user:jane@example.com', 'group:admins@example.com'].
  - `project_id`: (Optional|string) The ID of the project to apply the binding to. One of `project_id`, `folder_id`, `org_id`, or `bucket` must be specified.
  - `folder_id`: (Optional|string) The ID of the folder to apply the binding to. Can be prefixed with `folders/` or not. e.g., 'folders/123456789012' or '123456789012'.
  - `org_id`: (Optional|string) The ID of the organization to apply the binding to. Can be prefixed with `organizations/` or not. e.g., '123456789012' or 'organizations/123456789012'.
  - `bucket`: (Optional|string) The name of the GCS bucket to apply the binding to. e.g., 'my-bucket'.
  - `condition`: (Optional|object) An IAM condition block.
    - `title`: (Required|string) The title of the condition.
    - `description`: (Optional|string) An optional description of the condition.
    - `expression`: (Required|string) The CEL expression of the condition.
  EOD
  type = map(object({
    role       = string
    members    = list(string)
    project_id = optional(string)
    folder_id  = optional(string)
    org_id     = optional(string)
    bucket     = optional(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  # The default value is an empty map, meaning no bindings will be created if this variable is not provided.
  default = {}
  # This ensures that the variable cannot be set to null, which could cause issues in the module's logic.
  nullable = false

  # This validation rule ensures that each binding targets exactly one resource type.
  validation {
    condition = alltrue([
      for k, v in var.bindings :
      length([
        for id in [v.project_id, v.folder_id, v.org_id, v.bucket] : id if id != null
      ]) == 1
    ])
    error_message = "Each binding must specify exactly one of project_id, folder_id, org_id, or bucket."
  }

  # This validation rule ensures that the members list for a binding is not empty.
  validation {
    condition     = alltrue([for v in values(var.bindings) : length(v.members) > 0])
    error_message = "The 'members' attribute for each binding must not be an empty list."
  }
}

# This variable controls whether the use of primitive IAM roles (roles/owner, roles/editor, roles/viewer) is allowed.
# Using more specific predefined or custom roles is a security best practice.
variable "forbid_primitive_roles" {
  description = "If true, prevents the use of primitive roles (owner, editor, viewer)."
  type        = bool
  # By default, primitive roles are forbidden to encourage the use of least-privilege principles.
  default = true
}

# This variable defines a map of non-authoritative IAM member grants to be created.
# Each key in the map represents a unique logical name for an IAM member grant.
# The value is an object that specifies the role, a single member, the resource to which the grant applies, and an optional condition.
variable "members" {
  description = <<-EOD
  A map of IAM members to create. The key of the map is a logical name for the member grant, and the value is the member configuration.
  An IAM member is non-authoritative. It adds a single member to a role, leaving other members untouched.

  Each member object has the following attributes:
  - `role`: (Required|string) The role that should be applied. e.g., 'roles/compute.viewer'.
  - `member`: (Required|string) The identity that will be granted the privilege of the role. e.g., 'user:jane@example.com'.
  - `project_id`: (Optional|string) The ID of the project to apply the grant to. One of `project_id`, `folder_id`, `org_id`, or `bucket` must be specified.
  - `folder_id`: (Optional|string) The ID of the folder to apply the grant to. Can be prefixed with `folders/` or not. e.g., 'folders/123456789012' or '123456789012'.
  - `org_id`: (Optional|string) The ID of the organization to apply the grant to. Can be prefixed with `organizations/` or not. e.g., '123456789012' or 'organizations/123456789012'.
  - `bucket`: (Optional|string) The name of the GCS bucket to apply the grant to. e.g., 'my-bucket'.
  - `condition`: (Optional|object) An IAM condition block.
    - `title`: (Required|string) The title of the condition.
    - `description`: (Optional|string) An optional description of the condition.
    - `expression`: (Required|string) The CEL expression of the condition.
  EOD
  type = map(object({
    role       = string
    member     = string
    project_id = optional(string)
    folder_id  = optional(string)
    org_id     = optional(string)
    bucket     = optional(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  # The default value is an empty map, meaning no member grants will be created if this variable is not provided.
  default = {}
  # This ensures that the variable cannot be set to null, which could cause issues in the module's logic.
  nullable = false

  # This validation rule ensures that each member grant targets exactly one resource type.
  validation {
    condition = alltrue([
      for k, v in var.members :
      length([
        for id in [v.project_id, v.folder_id, v.org_id, v.bucket] : id if id != null
      ]) == 1
    ])
    error_message = "Each member must specify exactly one of project_id, folder_id, org_id, or bucket."
  }
}
