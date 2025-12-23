# A map of IAM bindings to apply to the resource. The key is a logical name for the binding, and the value is an object containing a `role`, a list of `members`, and an optional `condition` block. The `condition` object takes a `title`, `description`, and `expression`.
variable "bindings" {
  description = "A map of IAM bindings to apply to the resource. The key is a logical name for the binding, and the value is an object containing a `role`, a list of `members`, and an optional `condition` block. The `condition` object takes a `title`, `description`, and `expression`."
  type = map(object({
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

# The GCS bucket name to apply IAM bindings to. Mutually exclusive with `project`, `folder`, `organization`, and `service_account`.
variable "bucket" {
  description = "The GCS bucket name to apply IAM bindings to. Mutually exclusive with `project`, `folder`, `organization`, and `service_account`."
  type        = string
  default     = null
}

# The folder ID (e.g., 'folders/12345') to apply IAM bindings to. Mutually exclusive with 'project', 'organization', 'bucket', and 'service_account'.
variable "folder" {
  description = "The folder ID (e.g., 'folders/12345') to apply IAM bindings to. Mutually exclusive with 'project', 'organization', 'bucket', and 'service_account'."
  type        = string
  default     = null
}

# The organization ID (e.g., '12345') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'bucket', and 'service_account'.
variable "organization" {
  description = "The organization ID (e.g., '12345') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'bucket', and 'service_account'."
  type        = string
  default     = null
}

# The project ID to apply IAM bindings to. Mutually exclusive with 'folder', 'organization', 'bucket', and 'service_account'.
variable "project" {
  description = "The project ID to apply IAM bindings to. Mutually exclusive with 'folder', 'organization', 'bucket', and 'service_account'."
  type        = string
  default     = null
}

# The full identifier of the service account ('projects/{project}/serviceAccounts/{email}') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'organization', and 'bucket'.
variable "service_account" {
  description = "The full identifier of the service account ('projects/{project}/serviceAccounts/{email}') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'organization', and 'bucket'."
  type        = string
  default     = null
}
