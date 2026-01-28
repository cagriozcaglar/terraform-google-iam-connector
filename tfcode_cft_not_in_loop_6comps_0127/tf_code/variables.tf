# The variables.tf file defines all the input variables that can be passed to the module.
# Each variable has a type, a description, and an optional default value, making the module
# configurable and reusable.

variable "project_id" {
  description = "The ID of the project to which IAM policies will be applied. If not provided, no resources will be created."
  type        = string
  # A default of null is used to make this variable optional, allowing the module to be
  # planned without a project ID, in which case no resources will be created.
  default     = null
}

variable "bindings" {
  description = "A map of authoritative IAM bindings. The keys are IAM roles, and the values are lists of members. This will overwrite any existing members for the given roles."
  type        = map(set(string))
  default     = {}
  # Example: { "roles/storage.admin" = ["user:jane@example.com", "group:admins@example.com"] }
}

variable "additive_bindings" {
  description = "A map of non-authoritative IAM members. The keys are IAM roles, and the values are lists of members. This will add members to roles without affecting existing members."
  type        = map(set(string))
  default     = {}
  # Example: { "roles/viewer" = ["serviceAccount:my-sa@project.iam.gserviceaccount.com"] }
}

variable "conditional_bindings" {
  description = "A list of authoritative conditional IAM bindings. Each object represents a binding with a condition."
  type = list(object({
    role        = string
    title       = string
    description = optional(string)
    expression  = string
    members     = set(string)
  }))
  default = []
  # Example:
  # [
  #   {
  #     role       = "roles/storage.objectAdmin"
  #     title      = "access_during_business_hours"
  #     expression = "request.time.getHours('Europe/London') >= 9 && request.time.getHours('Europe/London') < 18"
  #     members    = ["group:contractors@example.com"]
  #   }
  # ]
}

variable "audit_configs" {
  description = "A list of IAM audit configurations for the project. Each object specifies a service and its audit log configurations."
  type = list(object({
    service = string
    audit_log_configs = list(object({
      log_type         = string
      exempted_members = optional(set(string), [])
    }))
  }))
  default = []
  # Example:
  # [
  #   {
  #     service = "allServices"
  #     audit_log_configs = [
  #       { log_type = "ADMIN_READ", exempted_members = ["user:auditor@example.com"] },
  #       { log_type = "DATA_WRITE" },
  #     ]
  #   }
  # ]
}
