# Google Cloud Workforce Identity Federation Module

This module handles the creation and configuration of a Google Cloud Workforce Identity Pool and its associated identity providers (IdPs). Workforce identity federation allows you to grant external identities, such as employees or partners, access to Google Cloud resources without needing to sync user directories.

This module creates a workforce pool and can configure multiple OIDC or SAML-based identity providers within that pool.

## Usage

Below is a basic example of how to use the module to create a workforce pool with one OIDC provider and one SAML provider.

```hcl
module "workforce_identity_federation" {
  source = "./" # Replace with module source

  organization_id             = "123456789012"
  workforce_pool_id           = "my-workforce-pool"
  workforce_pool_display_name = "My Example Workforce Pool"
  workforce_pool_description  = "A pool for authenticating corporate identities."
  workforce_pool_session_duration = "7200s"

  workforce_pool_providers = {
    "my-oidc-provider" = {
      display_name = "My OIDC Provider"
      description  = "OIDC provider for my-app."
      disabled     = false
      attribute_mapping = {
        "google.subject"       = "assertion.sub",
        "google.groups"        = "assertion.groups",
        "attribute.department" = "assertion.department"
      }
      attribute_condition = "assertion.aud == 'my-audience'"
      oidc = {
        issuer_uri = "https://my-oidc-issuer.example.com"
        client_id  = "my-client-id"
      }
    },
    "my-saml-provider" = {
      display_name = "My SAML Provider"
      description  = "SAML provider for corporate SSO."
      attribute_mapping = {
        "google.subject" = "assertion.subject",
        "attribute.email" = "assertion.attributes.email[0]"
      }
      saml = {
        idp_metadata_xml = file("path/to/metadata.xml")
      }
    }
  }
}
```

**Note:** No resources will be created if `organization_id`, `workforce_pool_id`, or `workforce_pool_display_name` are left as `null`.

## Requirements

The following requirements are needed by this module.

### Software

The following software is required:

-   [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
-   [Terraform Provider for GCP][terraform-provider-google] >= 4.54.0

### APIs

The following APIs must be enabled on the project:

-   IAM API: `iam.googleapis.com`
-   Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`

### Permissions

The service account or user running Terraform must have the following roles on the organization:

-   `roles/iam.workforcePoolAdmin`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organization\_id | The organization ID where the workforce pool will be created. If not provided, no resources will be created. | `string` | `null` | yes |
| workforce\_pool\_description | A description for the workforce pool. | `string` | `""` | no |
| workforce\_pool\_disabled | Whether the workforce pool is disabled. You cannot use a disabled pool to exchange tokens. | `bool` | `false` | no |
| workforce\_pool\_display\_name | A user-friendly display name for the workforce pool. If not provided, no resources will be created. | `string` | `null` | yes |
| workforce\_pool\_id | The ID of the workforce pool. It must be a globally unique identifier. If not provided, no resources will be created. | `string` | `null` | yes |
| workforce\_pool\_providers | A map of workforce identity providers to create. The key of the map is the provider\_id. Each provider must have exactly one of 'oidc' or 'saml' configured. | <pre>map(object({<br>    display_name      = string<br>    description       = optional(string, "Workforce pool provider managed by Terraform.")<br>    disabled          = optional(bool, false)<br>    attribute_mapping = map(string)<br>    attribute_condition = optional(string, null)<br>    oidc = optional(object({<br>      issuer_uri = string<br>      client_id  = optional(string)<br>    }), null)<br>    saml = optional(object({<br>      idp_metadata_xml = string<br>    }), null)<br>  }))</pre> | `{}` | no |
| workforce\_pool\_session\_duration | The duration that the Google Cloud access tokens, console sign-in sessions, and gcloud sign-in sessions from this pool are valid. Acceptable formats are seconds followed by 's', e.g., '3600s'. | `string` | `"3600s"` | no |

## Outputs

| Name | Description | Type |
|------|-------------|------|
| provider\_ids | A list of the IDs of the created workforce identity providers. | `list(string)` |
| provider\_names | A map of the full resource names of the workforce identity providers, keyed by provider ID. | `map(string)` |
| workforce\_pool\_id | The ID of the workforce identity pool. | `string` |
| workforce\_pool\_name | The full resource name of the workforce identity pool. | `string` |
| workforce\_pool\_state | The state of the workforce identity pool. | `string` |

## Resources

| Name | Type |
|------|------|
| [google\_iam\_workforce\_pool.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workforce_pool) | resource |
| [google\_iam\_workforce\_pool\_provider.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workforce_pool_provider) | resource |

[terraform-provider-google]: https://github.com/hashicorp/terraform-provider-google
