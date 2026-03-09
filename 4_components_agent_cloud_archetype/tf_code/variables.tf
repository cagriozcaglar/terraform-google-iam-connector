variable "resources" {
  description = "A list of resource IDs to apply IAM bindings to. The module determines the resource type from the ID format."
  type        = list(string)
  default     = []
}

variable "bindings" {
  description = "A map of IAM roles to a list of members. The members are defined in the format accepted by the IAM binding resources (e.g., `user:test@example.com`, `serviceAccount:my-sa@...`)."
  type        = map(list(string))
  default     = {}
}

variable "mode" {
  description = "The mode of operation. `additive` adds IAM bindings without removing existing ones. `authoritative` replaces all existing bindings with the ones provided."
  type        = string
  default     = "additive"

  validation {
    condition     = contains(["additive", "authoritative"], var.mode)
    error_message = "The mode must be either 'additive' or 'authoritative'."
  }
}
