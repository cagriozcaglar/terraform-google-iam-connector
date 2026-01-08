# Google Cloud IAM Module

This Terraform module provides a flexible way to create and manage IAM connections for various Google Cloud Platform resources. It supports both additive (`iam_member`) and authoritative (`iam_binding`) policies for Projects, Storage Buckets, and Service Accounts. It also supports conditional IAM bindings.

This module is designed to be a centralized place for managing common IAM policies, reducing code duplication and improving maintainability.

## Usage

Below is a basic example of how to use the module to manage IAM for a project, a storage bucket, and a service account.

```hcl
module "iam_management" {
  source = "./" # Or a Git repository source

  # Authoritative binding for a project
  project_iam_bindings = [
    {
      project = "my-gcp-project-id"
      role    = "roles/storage.admin"
      members = [
        "group:storage-admins@example.com",
        "serviceAccount:my-app@my-gcp-project-id.iam.gserviceaccount.com",
      ]
    }
  ]

  # Additive member for a storage bucket with a condition
  storage_bucket_iam_members = [
    {
      bucket = "my-important-data-bucket"
      role   = "roles/storage.objectViewer"
      member = "user:jane.doe@example.com"
      condition = {
        title       = "access_from_corp_network"
        description = "Allow access only from the corporate IP range"
        expression  = "request.ip in ['203.0.113.0/24']"
      }
    }
  ]

  # Additive member for a service account
  service_account_iam_members = [
    {
      service_account_id = "projects/my-gcp-project-id/serviceAccounts/workflow-sa@my-gcp-project-id.iam.gserviceaccount.com"
      role               = "roles/iam.serviceAccountUser"
      member             = "group:developers@example.com"
    }
  ]
}
```

## Requirements

The following requirements are needed by this module:

- Terraform >= 1.3
- Terraform Google Provider ~> 5.0

### APIs

The project where this module is deployed must have the following APIs enabled:

-   `cloudresourcemanager.googleapis.com` (Cloud Resource Manager API)
-   `storage.googleapis.com` (Cloud Storage API)
-   `iam.googleapis.com` (Identity and Access Management (IAM) API)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project\_iam\_bindings | List of authoritative IAM bindings for projects. Each object in the list requires `project`, `role`, and `members`. A `condition` block is optional. | <pre>list(object({<br>  project = string<br>  role    = string<br>  members = list(string)<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| project\_iam\_members | List of additive IAM bindings for projects. Each object in the list requires `project`, `role`, and `member`. A `condition` block is optional. | <pre>list(object({<br>  project = string<br>  role    = string<br>  member  = string<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| service\_account\_iam\_bindings | List of authoritative IAM bindings for service accounts. Each object in the list requires `service_account_id`, `role`, and `members`. A `condition` block is optional. `service_account_id` is the full name, e.g., projects/PROJECT\_ID/serviceAccounts/EMAIL. | <pre>list(object({<br>  service_account_id = string<br>  role               = string<br>  members            = list(string)<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| service\_account\_iam\_members | List of additive IAM bindings for service accounts. Each object in the list requires `service_account_id`, `role`, and `member`. A `condition` block is optional. `service_account_id` is the full name, e.g., projects/PROJECT\_ID/serviceAccounts/EMAIL. | <pre>list(object({<br>  service_account_id = string<br>  role               = string<br>  member             = string<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| storage\_bucket\_iam\_bindings | List of authoritative IAM bindings for GCS buckets. Each object in the list requires `bucket`, `role`, and `members`. A `condition` block is optional. | <pre>list(object({<br>  bucket  = string<br>  role    = string<br>  members = list(string)<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| storage\_bucket\_iam\_members | List of additive IAM bindings for GCS buckets. Each object in the list requires `bucket`, `role`, and `member`. A `condition` block is optional. | <pre>list(object({<br>  bucket = string<br>  role   = string<br>  member = string<br>  condition = optional(object({<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| project\_iam\_bindings | A map of the created `google_project_iam_binding` resources, keyed by the index of the input variable `project_iam_bindings`. |
| project\_iam\_members | A map of the created `google_project_iam_member` resources, keyed by the index of the input variable `project_iam_members`. |
| service\_account\_iam\_bindings | A map of the created `google_service_account_iam_binding` resources, keyed by the index of the input variable `service_account_iam_bindings`. |
| service\_account\_iam\_members | A map of the created `google_service_account_iam_member` resources, keyed by the index of the input variable `service_account_iam_members`. |
| storage\_bucket\_iam\_bindings | A map of the created `google_storage_bucket_iam_binding` resources, keyed by the index of the input variable `storage_bucket_iam_bindings`. |
| storage\_bucket\_iam\_members | A map of the created `google_storage_bucket_iam_member` resources, keyed by the index of the input variable `storage_bucket_iam_members`. |
