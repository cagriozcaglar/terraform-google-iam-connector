variable "project_iam_members" {
  description = "List of additive IAM bindings for projects. Each object in the list requires `project`, `role`, and `member`. A `condition` block is optional."
  type = list(object({
    project = string
    role    = string
    member  = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "project_iam_bindings" {
  description = "List of authoritative IAM bindings for projects. Each object in the list requires `project`, `role`, and `members`. A `condition` block is optional."
  type = list(object({
    project = string
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "storage_bucket_iam_members" {
  description = "List of additive IAM bindings for GCS buckets. Each object in the list requires `bucket`, `role`, and `member`. A `condition` block is optional."
  type = list(object({
    bucket = string
    role   = string
    member = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "storage_bucket_iam_bindings" {
  description = "List of authoritative IAM bindings for GCS buckets. Each object in the list requires `bucket`, `role`, and `members`. A `condition` block is optional."
  type = list(object({
    bucket  = string
    role    = string
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "service_account_iam_members" {
  description = "List of additive IAM bindings for service accounts. Each object in the list requires `service_account_id`, `role`, and `member`. A `condition` block is optional. `service_account_id` is the full name, e.g., projects/PROJECT_ID/serviceAccounts/EMAIL."
  type = list(object({
    service_account_id = string
    role               = string
    member             = string
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}

variable "service_account_iam_bindings" {
  description = "List of authoritative IAM bindings for service accounts. Each object in the list requires `service_account_id`, `role`, and `members`. A `condition` block is optional. `service_account_id` is the full name, e.g., projects/PROJECT_ID/serviceAccounts/EMAIL."
  type = list(object({
    service_account_id = string
    role               = string
    members            = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = []
}
