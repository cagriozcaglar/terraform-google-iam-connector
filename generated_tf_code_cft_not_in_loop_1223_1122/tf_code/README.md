# Google Cloud IAM Member Module

This module is used to create Identity and Access Management (IAM) bindings on various Google Cloud resources. It provides a flexible interface to connect a principal (user, group, or service account) to a specific role on a project, storage bucket, or BigQuery dataset. By using `google_*_iam_member`, this module ensures that bindings are managed additively without overwriting existing policies. This approach is ideal for managing permissions granularly and adhering to the principle of least privilege.

The module supports creating multiple bindings for each resource type in a single invocation by accepting maps of binding configurations. This allows for efficient and declarative management of IAM policies across different resource types.

## Usage

The following example demonstrates how to create IAM bindings for a project, a storage bucket, and a BigQuery dataset.

```hcl
module "iam_bindings" {
  source = "./path/to/this/module"

  project_bindings = {
    "project-viewer-for-devs" = {
      project = "my-gcp-project-id"
      role    = "roles/viewer"
      member  = "group:developers@example.com"
    }
  }

  storage_bucket_bindings = {
    "bucket-reader-for-app-sa" = {
      bucket = "my-app-storage-bucket"
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:my-app-sa@my-gcp-project-id.iam.gserviceaccount.com"
    }
  }

  bigquery_dataset_bindings = {
    "dataset-user-for-analysts" = {
      project    = "my-data-project-id"
      dataset_id = "marketing_data"
      role       = "roles/bigquery.dataUser"
      member     = "group:analysts@example.com"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bigquery_dataset_bindings` | A map of IAM bindings to create on BigQuery datasets. The key of each map item is a descriptive name for the binding, and the value is an object containing the dataset details, role, and member. | <pre>map(object({<br>  project    = string<br>  dataset_id = string<br>  role       = string<br>  member     = string<br>}))</pre> | `{}` | no |
| `project_bindings` | A map of IAM bindings to create on projects. The key of each map item is a descriptive name for the binding, and the value is an object containing the project, role, and member. | <pre>map(object({<br>  project = string<br>  role    = string<br>  member  = string<br>}))</pre> | `{}` | no |
| `storage_bucket_bindings` | A map of IAM bindings to create on storage buckets. The key of each map item is a descriptive name for the binding, and the value is an object containing the bucket, role, and member. | <pre>map(object({<br>  bucket = string<br>  role   = string<br>  member = string<br>}))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `all_binding_ids` | A map of all created IAM binding IDs, keyed by the descriptive name from the input maps, prefixed by resource type to avoid collisions. |
| `bigquery_dataset_bindings` | A map of the created google\_bigquery\_dataset\_iam\_member resources, keyed by the name provided in the input 'bigquery\_dataset\_bindings' map. |
| `project_bindings` | A map of the created google\_project\_iam\_member resources, keyed by the name provided in the input 'project\_bindings' map. |
| `storage_bucket_bindings` | A map of the created google\_storage\_bucket\_iam\_member resources, keyed by the name provided in the input 'storage\_bucket\_bindings' map. |

## Requirements

The following sections describe the requirements for using this module.

### Software

The following software is required:
- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Terraform Provider for GCP](https://github.com/hashicorp/terraform-provider-google) >= 4.50.0

### APIs

A project with the following APIs enabled is required:
- `cloudresourcemanager.googleapis.com`

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset_iam_member.bigquery_dataset_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member) | resource |
| [google_project_iam_member.project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_storage_bucket_iam_member.storage_bucket_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
