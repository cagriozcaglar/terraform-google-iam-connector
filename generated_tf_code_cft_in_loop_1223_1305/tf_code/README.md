<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# Google Cloud IAM Member Module

This module provides a flexible and reusable way to manage Google Cloud IAM member-level bindings (`*_iam_member`) for various resource types, including Projects, Folders, Organizations, GCS Buckets, and Service Accounts.

It is designed to take a single resource identifier (e.g., a project ID or a folder ID) and a map of role-to-member bindings, applying them authoritatively for each individual member-role pair. This ensures that each specified member is granted the intended role without affecting other IAM bindings on the resource.

## Usage

Provide the module with a single resource identifier and a map of bindings. The module will automatically detect the resource type and apply the IAM member bindings accordingly.

### Basic Example: Project-Level IAM Bindings

The following example grants the `roles/storage.objectViewer` to a user and a group, and `roles/editor` to a service account on the specified project.

```hcl
module "project_iam_bindings" {
  source  = "path/to/this/module"
  project = "my-gcp-project-id"

  bindings = {
    "storage-viewers" = {
      role    = "roles/storage.objectViewer"
      members = [
        "user:jane.doe@example.com",
        "group:data-viewers@example.com",
      ]
    },
    "project-editors" = {
      role    = "roles/editor"
      members = [
        "serviceAccount:my-app@my-gcp-project-id.iam.gserviceaccount.com",
      ]
    }
  }
}
```

### Advanced Example: Folder-Level IAM with a Condition

This example grants the `roles/storage.admin` role to a user on a folder, but only for resources (buckets) that match the condition.

```hcl
module "folder_iam_bindings" {
  source = "path/to/this/module"
  folder = "123456789012"

  bindings = {
    "conditional-storage-admin" = {
      role    = "roles/storage.admin"
      members = ["user:admin.user@example.com"]
      condition = {
        title       = "access-to-secure-buckets"
        description = "Only allow admin access to buckets prefixed with 'secure-'"
        expression  = "resource.name.startsWith(\"projects/_/buckets/secure-\")"
      }
    }
  }
}
```

## Requirements

### Terraform

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

### Permissions

The service account or user running Terraform must have the necessary permissions to set IAM policies on the target resource. For example:
- **Project**: `resourcemanager.projects.setIamPolicy`
- **Folder**: `resourcemanager.folders.setIamPolicy`
- **Organization**: `resourcemanager.organizations.setIamPolicy`
- **Bucket**: `storage.buckets.setIamPolicy`
- **Service Account**: `iam.serviceAccounts.setIamPolicy`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bindings"></a> [bindings](#input\_bindings) | A map of IAM bindings to apply to the resource. The key is a logical name for the binding, and the value is an object containing a `role`, a list of `members`, and an optional `condition` block. The `condition` object takes a `title`, `description`, and `expression`. | <pre>map(object({<br>    role    = string<br>    members = list(string)<br>    condition = optional(object({<br>      title       = string<br>      description = optional(string)<br>      expression  = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The GCS bucket name to apply IAM bindings to. Mutually exclusive with `project`, `folder`, `organization`, and `service_account`. | `string` | `null` | no |
| <a name="input_folder"></a> [folder](#input\_folder) | The folder ID (e.g., 'folders/12345') to apply IAM bindings to. Mutually exclusive with 'project', 'organization', 'bucket', and 'service_account'. | `string` | `null` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | The organization ID (e.g., '12345') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'bucket', and 'service_account'. | `string` | `null` | no |
| <a name="input_project"></a> [project](#input\_project) | The project ID to apply IAM bindings to. Mutually exclusive with 'folder', 'organization', 'bucket', and 'service_account'. | `string` | `null` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The full identifier of the service account ('projects/{project}/serviceAccounts/{email}') to apply IAM bindings to. Mutually exclusive with 'project', 'folder', 'organization', and 'bucket'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_iam_bindings"></a> [bucket\_iam\_bindings](#output\_bucket\_iam\_bindings) | Map of GCS bucket-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member. |
| <a name="output_folder_iam_bindings"></a> [folder\_iam\_bindings](#output\_folder\_iam\_bindings) | Map of folder-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member. |
| <a name="output_organization_iam_bindings"></a> [organization\_iam\_bindings](#output\_organization\_iam\_bindings) | Map of organization-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member. |
| <a name="output_project_iam_bindings"></a> [project\_iam\_bindings](#output\_project\_iam\_bindings) | Map of project-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member. |
| <a name="output_service_account_iam_bindings"></a> [service\_account\_iam\_bindings](#output\_service\_account\_iam\_bindings) | Map of service account-level IAM bindings created, keyed by a JSON-encoded string of the binding key, role, and member. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
