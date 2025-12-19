variable "organization_id" {
  description = "The organization ID where the workforce pool will be created. The parent format is `organizations/{organization_id}`. A placeholder default is provided for testability, but this must be overridden with a valid organization ID."
  type        = string
  default     = "123456789012"
}

variable "workforce_pool_id" {
  description = "The ID of the workforce pool to create. It must be a globally unique identifier. A placeholder default is provided for testability, but this must be overridden."
  type        = string
  default     = "example-workforce-pool"
}

variable "workforce_pool_display_name" {
  description = "A user-specified display name for the workforce pool. Cannot be longer than 32 characters."
  type        = string
  default     = null
}

variable "workforce_pool_description" {
  description = "A user-specified description of the workforce pool. Cannot be longer than 256 characters."
  type        = string
  default     = null
}

variable "workforce_pool_session_duration" {
  description = "Duration that the Google Cloud access tokens, console sign-in sessions, and gcloud sign-in sessions from this pool are valid. Must be between 15 minutes (900s) and 12 hours (43200s). Default is 1 hour."
  type        = string
  default     = "3600s"
}

variable "workforce_pool_disabled" {
  description = "Whether the workforce pool is disabled. You cannot use a disabled pool to exchange tokens, or use existing tokens to access resources. If true, the pool is disabled. If false, the pool is enabled."
  type        = bool
  default     = false
}

variable "provider_id" {
  description = "The ID of the workforce pool provider to create. It must be a globally unique identifier. A placeholder default is provided for testability, but this must be overridden."
  type        = string
  default     = "example-provider"
}

variable "provider_display_name" {
  description = "A user-specified display name for the provider. Cannot be longer than 32 characters."
  type        = string
  default     = null
}

variable "provider_description" {
  description = "A user-specified description of the provider. Cannot be longer than 256 characters."
  type        = string
  default     = null
}

variable "provider_disabled" {
  description = "Whether the provider is disabled. You cannot use a disabled provider to exchange tokens. If true, the provider is disabled. If false, the provider is enabled."
  type        = bool
  default     = false
}

variable "attribute_mapping" {
  description = "A map of attribute mapping from the identity provider to Google Cloud. The key is the full attribute name in Google Cloud (e.g., `google.subject`), and the value is a Common Expression Language (CEL) expression for the source attribute (e.g., `assertion.sub`)."
  type        = map(string)
  default = {
    "google.subject" = "assertion.sub"
  }
}

variable "oidc_provider_config" {
  description = "Configuration for an OIDC provider. You must set either `oidc_provider_config` or `saml_provider_config`. A default is provided for testability."
  type = object({
    issuer_uri = string
    client_id  = string
    jwks_json  = optional(string)
  })
  default = {
    issuer_uri = "https://accounts.google.com"
    client_id  = "example-client-id"
  }
}

variable "saml_provider_config" {
  description = "Configuration for a SAML provider. You must set either `oidc_provider_config` or `saml_provider_config`."
  type = object({
    idp_metadata_xml = string
  })
  default = null
}
