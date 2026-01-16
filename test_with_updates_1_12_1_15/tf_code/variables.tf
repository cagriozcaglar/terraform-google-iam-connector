# The `iam_bindings` variable defines a list of authoritative IAM bindings to create.
# An IAM binding is a list of members for a single role.
# `iam_bindings` are authoritative and will overwrite any existing members for that role on the resource. Use with caution.
# Each object in the list must have the following attributes:
# - `resource_type`: The type of the resource to apply the binding to. Must be one of `project`, `storage_bucket`, or `service_account`.
# - `resource_id`: The identifier of the resource. For `project`, it's the project ID. For `storage_bucket`, it's the bucket name. For `service_account`, it's the full service account name in the format `projects/{project_id}/serviceAccounts/{service_account_email}`.
# - `role`: The role to grant.
# - `members`: A list of members to grant the role to.
# - `condition`: (Optional) An IAM condition block with `title`, `description`, and `expression` attributes.
variable "iam_bindings" {
  description = "A list of authoritative IAM bindings to create. A binding is a list of members for a single role. Note that this is authoritative and will overwrite any existing members for the role on the given resource."
  type = list(object({
    resource_type = string
    resource_id   = string
    role          = string
    members       = list(string)
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = []
}

# The `iam_members` variable defines a list of non-authoritative IAM members to create.
# An IAM member is a single member/role pairing.
# `iam_members` are non-authoritative and will add the member to the role without affecting other members. This is the recommended way to grant permissions.
# Each object in the list must have the following attributes:
# - `resource_type`: The type of the resource to apply the binding to. Must be one of `project`, `storage_bucket`, or `service_account`.
# - `resource_id`: The identifier of the resource. For `project`, it's the project ID. For `storage_bucket`, it's the bucket name. For `service_account`, it's the full service account name in the format `projects/{project_id}/serviceAccounts/{service_account_email}`.
# - `role`: The role to grant.
# - `member`: The member to grant the role to.
# - `condition`: (Optional) An IAM condition block with `title`, `description`, and `expression` attributes.
variable "iam_members" {
  description = "A list of non-authoritative IAM members to create. A member is a single member/role pairing. This is non-authoritative and will not affect other members for the role on the given resource."
  type = list(object({
    resource_type = string
    resource_id   = string
    role          = string
    member        = string
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = []
}
