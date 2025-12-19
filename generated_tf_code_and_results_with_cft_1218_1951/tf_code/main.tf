# This module is used to create a Google Cloud IAM Workforce Identity Pool and a corresponding provider.
# A Workforce Identity Pool allows you to manage access for a workforce, such as employees, partners, and contractors,
# to Google Cloud services. It enables federation with an external identity provider (IdP) like Azure AD, Okta, or any
# SAML 2.0 compliant IdP, allowing users to authenticate using their existing corporate credentials.
#
# This module supports creating a provider for either OIDC or SAML protocols.
resource "google_iam_workforce_pool" "main" {
  # The beta provider is required for workforce pool features.
  provider = google-beta

  # The parent of the pool is the organization. The format is `organizations/{organization_id}`.
  parent = "organizations/${var.organization_id}"

  # The location of the pool is always global.
  location = "global"

  # A user-specified ID for the workforce pool. This is the last part of the pool's resource name.
  workforce_pool_id = var.workforce_pool_id

  # A user-specified display name for the workforce pool.
  display_name = var.workforce_pool_display_name

  # A user-specified description of the workforce pool.
  description = var.workforce_pool_description

  # Duration that the access tokens are valid for.
  session_duration = var.workforce_pool_session_duration

  # The state of the pool.
  disabled = var.workforce_pool_disabled
}

# This resource configures a provider within the Workforce Identity Pool to connect to an external IdP (OIDC or SAML).
resource "google_iam_workforce_pool_provider" "main" {
  # The beta provider is required for workforce pool provider features.
  provider = google-beta

  # The location of the provider must match the pool's location.
  location = google_iam_workforce_pool.main.location

  # The ID of the pool this provider belongs to.
  workforce_pool_id = google_iam_workforce_pool.main.workforce_pool_id

  # A user-specified ID for the provider.
  provider_id = var.provider_id

  # A user-specified display name for the provider.
  display_name = var.provider_display_name

  # A user-specified description of the provider.
  description = var.provider_description

  # The state of the provider.
  disabled = var.provider_disabled

  # Maps attributes from the external identity provider's token to Google Cloud attributes.
  attribute_mapping = var.attribute_mapping

  lifecycle {
    precondition {
      # Ensures that exactly one of the provider configurations is set.
      condition     = (var.oidc_provider_config != null) != (var.saml_provider_config != null)
      error_message = "Exactly one of `oidc_provider_config` or `saml_provider_config` must be provided."
    }
  }

  # Dynamic block for OIDC configuration. This block is created only if `oidc_provider_config` is provided.
  dynamic "oidc" {
    for_each = var.oidc_provider_config != null ? [var.oidc_provider_config] : []
    content {
      # The OIDC issuer URI of the identity provider.
      issuer_uri = oidc.value.issuer_uri

      # The OIDC client ID of the provider.
      client_id = oidc.value.client_id

      # The JSON Web Key Set (JWKS) document provided by the identity provider.
      jwks_json = oidc.value.jwks_json
    }
  }

  # Dynamic block for SAML configuration. This block is created only if `saml_provider_config` is provided.
  dynamic "saml" {
    for_each = var.saml_provider_config != null ? [var.saml_provider_config] : []
    content {
      # The SAML 2.0 IdP metadata XML document.
      idp_metadata_xml = saml.value.idp_metadata_xml
    }
  }
}
