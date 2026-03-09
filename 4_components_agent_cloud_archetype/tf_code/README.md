# Terraform Google Generic IAM

This module provides a generic way to manage IAM bindings for multiple Google Cloud resource types. It supports both additive bindings, which preserve existing IAM policies, and authoritative policies, which replace all existing bindings for a given role. This is useful for centrally managing IAM permissions across different resources like projects, storage buckets, and Pub/Sub topics based on a common map of roles and members.

The module intelligently dispatches to the correct Terraform IAM resource based on the format of the resource ID provided.

Currently supported resource ID formats:
- Projects: `projects/project-id`
- Storage Buckets: `projects/project-id/buckets/bucket-name`
- Pub/Sub Topics: `projects/project-id/topics/topic-name`

## Usage

Basic usage of this module is as follows:

```hcl
module "iam_bindings" {
  source = "path/to/module"

  resources = [
    "projects/my-gcp-project",
    "projects/my-gcp-project/buckets/my-storage-bucket",
    "projects/my-gcp-project/topics/my-pubsub-topic",
  ]

  mode = "additive"

  bindings = {
    "roles/viewer" = [
      "user:jane.doe@example.com",
    ]
    "roles/storage.objectAdmin" = [
      "serviceAccount:my-sa@my-gcp-project.iam.gserviceaccount.com",
    ]
    "roles/pubsub.publisher" = [
      "group:publishers@example.com",
    ]
  }
}
```

## Examples

### Additive IAM Bindings

This example demonstrates how to add new IAM bindings to multiple resources without affecting existing permissions. The module will apply the `roles/resourcemanager.projectIamAdmin` role to the specified project and the `roles/storage.admin` role to the specified bucket.

```hcl
module "iam_additive_example" {
  source = "path/to/module"

  resources = [
    "projects/my-gcp-project",
    "projects/my-gcp-project/buckets/my-storage-bucket",
  ]

  mode = "additive"

  bindings = {
    "roles/resourcemanager.projectIamAdmin" = [
      "user:admin@example.com",
    ]
    "roles/storage.admin" = [
      "serviceAccount:storage-admin-sa@my-gcp-project.iam.gserviceaccount.com",
    ]
  }
}
```

### Authoritative IAM Policy

This example demonstrates how to set an authoritative IAM policy on a Pub/Sub topic. This will **replace all existing IAM policies** on the topic with the ones defined in the `bindings` map.

**Warning:** Using `authoritative` mode is destructive and can remove critical permissions (including your own) if not configured carefully. It should be used with extreme caution.

```hcl
module "iam_authoritative_example" {
  source = "path/to/module"

  resources = [
    "projects/my-gcp-project/topics/sensitive-data-topic",
  ]

  mode = "authoritative"

  bindings = {
    "roles/pubsub.editor" = [
      "group:topic-editors@example.com",
    ]
    "roles/pubsub.viewer" = [
      "serviceAccount:auditor-sa@my-gcp-project.iam.gserviceaccount.com",
    ]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bindings` | A map of IAM roles to a list of members. The members are defined in the format accepted by the IAM binding resources (e.g., `user:test@example.com`, `serviceAccount:my-sa@...`). | `map(list(string))` | `{}` | no |
| `mode` | The mode of operation. `additive` adds IAM bindings without removing existing ones. `authoritative` replaces all existing bindings with the ones provided. | `string` | `"additive"` | no |
| `resources` | A list of resource IDs to apply IAM bindings to. The module determines the resource type from the ID format. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `iam_results` | A map of the full resource IDs of the IAM bindings or policies that were created, keyed by a unique identifier combining the resource and role. |

## Requirements

### Software

The following software is required to use this module:

- [Terraform](https://www.terraform.io/downloads.html): v1.3+
- [Terraform Google Provider](https://github.com/hashicorp/terraform-provider-google): ~> 5.0

### Service Account

A service account with the following roles is required to run this module:

- To manage Project IAM: `roles/resourcemanager.projectIamAdmin` on the project.
- To manage Storage Bucket IAM: `roles/storage.admin` on the project or bucket.
- To manage Pub/Sub Topic IAM: `roles/pubsub.admin` on the project or topic.

### APIs

The following APIs must be enabled on the project where the resources are being managed:

- Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`
- Cloud Storage API: `storage.googleapis.com`
- Cloud Pub/Sub API: `pubsub.googleapis.com`
