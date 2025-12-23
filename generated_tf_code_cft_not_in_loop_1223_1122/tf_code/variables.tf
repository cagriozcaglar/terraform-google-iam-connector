variable "project_bindings" {
  description = "A map of IAM bindings to create on projects. The key of each map item is a descriptive name for the binding, and the value is an object containing the project, role, and member."
  type = map(object({
    # The ID of the project to apply the binding to.
    project = string
    # The role to grant. For example, 'roles/viewer'.
    role = string
    # The principal to grant the role to. Must be in the format '{type}:{email/id}'. For example, 'user:test@example.com'.
    member = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for b in values(var.project_bindings) : can(regex("^(user|group|serviceAccount|domain):.+", b.member))
    ])
    error_message = "Each member in project_bindings must be a valid IAM principal string, e.g., 'user:test@example.com'."
  }
}

variable "storage_bucket_bindings" {
  description = "A map of IAM bindings to create on storage buckets. The key of each map item is a descriptive name for the binding, and the value is an object containing the bucket, role, and member."
  type = map(object({
    # The name of the Storage Bucket to apply the binding to.
    bucket = string
    # The role to grant. For example, 'roles/storage.objectViewer'.
    role = string
    # The principal to grant the role to. Must be in the format '{type}:{email/id}' or a special identifier. For example, 'user:test@example.com' or 'allUsers'.
    member = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for b in values(var.storage_bucket_bindings) : b.member == "allUsers" || b.member == "allAuthenticatedUsers" || can(regex("^(user|group|serviceAccount|domain):.+", b.member))
    ])
    error_message = "Each member in storage_bucket_bindings must be a valid IAM principal string (e.g., 'user:test@example.com') or one of 'allUsers', 'allAuthenticatedUsers'."
  }
}

variable "bigquery_dataset_bindings" {
  description = "A map of IAM bindings to create on BigQuery datasets. The key of each map item is a descriptive name for the binding, and the value is an object containing the dataset details, role, and member."
  type = map(object({
    # The ID of the project containing the BigQuery dataset.
    project = string
    # The ID of the BigQuery dataset.
    dataset_id = string
    # The role to grant. For example, 'roles/bigquery.dataViewer'.
    role = string
    # The principal to grant the role to. Must be in the format '{type}:{email/id}' or a special identifier. For example, 'user:test@example.com' or 'view:project/dataset/table'.
    member = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for b in values(var.bigquery_dataset_bindings) : can(regex("^(user|group|serviceAccount|domain|specialGroup|iamMember|view):.+", b.member))
    ])
    error_message = "Each member in bigquery_dataset_bindings must be a valid IAM principal string, e.g., 'user:test@example.com'."
  }
}
