variable "bindings" {
  description = "A map of IAM bindings to apply. The key is the role, and the value is an object containing a list of members and an optional condition. Example `{'roles/storage.objectViewer' = { members = ['user:foo@example.com'], condition = { title = 'expires_2024', expression = 'request.time < timestamp(\"2025-01-01T00:00:00Z\")' } } }`"
  type = map(object({
    members = list(string)
    condition = optional(object({
      title       = string
      description = optional(string)
      expression  = string
    }))
  }))
  default = {}
}

variable "bucket_name" {
  description = "The name of the GCS bucket to apply IAM policies to. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}

variable "folder_id" {
  description = "The ID of the folder to apply IAM policies to. Can be the numeric ID or the full ID in the format `folders/{folder_id}`. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}

variable "mode" {
  description = "Mode of operation. 'authoritative' creates 'google_*_iam_binding' resources, overwriting any existing members for the given roles. Warning: This is a destructive operation and can remove existing IAM members from the specified roles. 'additive' creates 'google_*_iam_member' resources, adding members to roles without affecting existing members."
  type        = string
  default     = "additive"

  validation {
    condition     = contains(["authoritative", "additive"], var.mode)
    error_message = "Valid values for mode are 'authoritative' or 'additive'."
  }
}

variable "organization_id" {
  description = "The numeric ID of the organization (e.g., '123456789012') to apply IAM policies to. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}

variable "project_id" {
  description = "The ID of the project to apply IAM policies to. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}

variable "pubsub_topic_id" {
  description = "The ID of the Pub/Sub topic to apply IAM policies to, in the format `projects/PROJECT_ID/topics/TOPIC_NAME`. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}

variable "service_account_email" {
  description = "The identity of the service account to apply IAM policies to. Can be the short email address, or the full resource name `projects/PROJECT_ID/serviceAccounts/SA_EMAIL`. Only one of `project_id`, `folder_id`, `organization_id`, `bucket_name`, `service_account_email`, or `pubsub_topic_id` must be specified."
  type        = string
  default     = null
}
