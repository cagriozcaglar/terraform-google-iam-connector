# The organization ID where the workforce pool will be created.
variable "organization_id" {
  description = "The organization ID where the workforce pool will be created. If not provided, no resources will be created."
  type        = string
  default     = null
}

# The ID of the workforce pool. It must be a globally unique identifier.
variable "workforce_pool_id" {
  description = "The ID of the workforce pool. It must be a globally unique identifier. If not provided, no resources will be created."
  type        = string
  default     = null
}

# A user-friendly display name for the workforce pool.
variable "workforce_pool_display_name" {
  description = "A user-friendly display name for the workforce pool. If not provided, no resources will be created."
  type        = string
  default     = null
}

# A description for the workforce pool.
variable "workforce_pool_description" {
  description = "A description for the workforce pool."
  type        = string
  default     = ""
}

# Whether the workforce pool is disabled. You cannot use a disabled pool to exchange tokens.
variable "workforce_pool_disabled" {
  description = "Whether the workforce pool is disabled. You cannot use a disabled pool to exchange tokens."
  type        = bool
  default     = false
}

# The duration that the Google Cloud access tokens, console sign-in sessions, and gcloud sign-in sessions from this pool are valid.
variable "workforce_pool_session_duration" {
  description = "The duration that the Google Cloud access tokens, console sign-in sessions, and gcloud sign-in sessions from this pool are valid. Acceptable formats are seconds followed by 's', e.g., '3600s'."
  type        = string
  default     = "3600s"
}

# A map of workforce identity providers to create. The key of the map is the provider_id.
variable "workforce_pool_providers" {
  description = "A map of workforce identity providers to create. The key of the map is the provider_id."
  type = map(object({
    display_name      = string
    description       = optional(string, "Workforce pool provider managed by Terraform.")
    disabled          = optional(bool, false)
    attribute_mapping = map(string)
    attribute_condition = optional(string, null)
    oidc = optional(object({
      issuer_uri = string
      client_id  = optional(string)
    }), null)
    saml = optional(object({
      idp_metadata_xml = string
    }), null)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for k, v in var.workforce_pool_providers :
      (v.oidc != null && v.saml == null) || (v.oidc == null && v.saml != null)
    ])
    error_message = "Each provider must have exactly one of 'oidc' or 'saml' configuration block defined."
  }
}
