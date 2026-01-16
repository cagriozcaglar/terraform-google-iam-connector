variable "project_id" {
  description = "The Google Cloud project ID to deploy the resources in."
  type        = string
}

variable "user_email" {
  description = "The user email address to grant the Storage Object Viewer role to. For example, 'name@example.com'."
  type        = string
}

variable "region" {
  description = "The Google Cloud region to create the storage bucket in."
  type        = string
  default     = "us-central1"
}
