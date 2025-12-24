locals {
  # Determines whether the workforce pool and its providers should be created.
  # Creation is skipped if essential variables are not provided.
  enabled = var.organization_id != null && var.workforce_pool_id != null && var.workforce_pool_display_name != null
}

# Creates the Workforce Identity Pool, which acts as a container for external identity providers.
resource "google_iam_workforce_pool" "main" {
  # Create this resource only if the required variables are provided.
  count = local.enabled ? 1 : 0

  # The parent resource of the pool. Must be in the format 'organizations/{organization_id}'.
  parent = "organizations/${var.organization_id}"
  # The location for the resource. This is always 'global'.
  location = "global"
  # The user-specified ID for the pool.
  workforce_pool_id = var.workforce_pool_id
  # The display name for the pool.
  display_name = var.workforce_pool_display_name
  # A description for the pool.
  description = var.workforce_pool_description
  # Whether the pool is disabled.
  disabled = var.workforce_pool_disabled
  # The session duration for tokens issued by this pool.
  session_duration = var.workforce_pool_session_duration
}

# Creates one or more Workforce Identity Pool Providers, which define connections to external identity providers (IdPs).
resource "google_iam_workforce_pool_provider" "main" {
  # Iterate over the provider IDs. Using keys() avoids the 'sensitive value in for_each' error.
  # Create providers only if the pool is being created.
  for_each = local.enabled ? toset(keys(var.workforce_pool_providers)) : toset([])

  # The location for the resource. This is always 'global'.
  location = google_iam_workforce_pool.main[0].location
  # The ID of the parent workforce pool.
  workforce_pool_id = google_iam_workforce_pool.main[0].workforce_pool_id
  # The user-specified ID for the provider. This is the key from the for_each set.
  provider_id = each.key
  # The display name for the provider.
  display_name = var.workforce_pool_providers[each.key].display_name
  # A description for the provider.
  description = var.workforce_pool_providers[each.key].description
  # Whether the provider is disabled.
  disabled = var.workforce_pool_providers[each.key].disabled
  # Maps attributes from the IdP to GCP attributes.
  attribute_mapping = var.workforce_pool_providers[each.key].attribute_mapping
  # A CEL expression that must be true for authentication to succeed.
  attribute_condition = var.workforce_pool_providers[each.key].attribute_condition

  # Defines an OIDC identity provider. This block is created dynamically if 'oidc' is configured.
  dynamic "oidc" {
    for_each = var.workforce_pool_providers[each.key].oidc != null ? [var.workforce_pool_providers[each.key].oidc] : []
    content {
      # The OIDC issuer URI.
      issuer_uri = oidc.value.issuer_uri
      # The OIDC client ID.
      client_id = oidc.value.client_id
    }
  }

  # Defines a SAML identity provider. This block is created dynamically if 'saml' is configured.
  dynamic "saml" {
    for_each = var.workforce_pool_providers[each.key].saml != null ? [var.workforce_pool_providers[each.key].saml] : []
    content {
      # The SAML 2.0 IdP metadata XML content.
      idp_metadata_xml = saml.value.idp_metadata_xml
    }
  }
}
