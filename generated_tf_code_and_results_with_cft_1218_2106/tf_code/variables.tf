variable "project_id" {
  description = "The ID of the project to which IAM policies will be applied. Mutually exclusive with `folder_id` and `organization_id`."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The ID of the folder to which IAM policies will be applied (e.g., 'folders/12345678'). Mutually exclusive with `project_id` and `organization_id`."
  type        = string
  default     = null
}

variable "organization_id" {
  description = "The ID of the organization to which IAM policies will be applied (e.g., 'organizations/12345678'). Mutually exclusive with `project_id` and `folder_id`."
  type        = string
  default     = null
}

variable "bindings" {
  description = "A map of authoritative IAM bindings. The key is the role and the value is a list of members. Any existing members of these roles will be removed. Example: {'roles/viewer' = ['user:jane@example.com']}"
  type        = map(list(string))
  default     = {}
}

variable "conditional_bindings" {
  description = "A list of additive IAM bindings, each with an optional condition. Each binding grants a role to a single member without affecting other members of the role."
  type = list(object({
    role   = string
    member = string
    condition = optional(object({
      title       = string
      description = string
      expression  = string
    }))
  }))
  default = []
}
