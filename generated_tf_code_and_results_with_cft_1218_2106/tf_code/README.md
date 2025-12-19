# Google Cloud IAM Module

This module simplifies the management of IAM policies on Google Cloud resources. It allows you to apply IAM bindings at the **project**, **folder**, or **organization** level from a single, unified interface.

The module supports two types of IAM policy management:

1.  **Authoritative Bindings (`google_*_iam_binding`):** This sets the complete list of members for a given role. If you use this, any members for that role that are not specified in your configuration will be **removed**. This is ideal for managing team-based permissions where the entire membership list is known and managed by Terraform.

2.  **Additive Members (`google_*_iam_member`):** This adds a single member to a role without affecting any other members of that role. This is useful for granting specific, one-off permissions or for applying **IAM Conditions**, which are also supported by this module.

You must specify exactly one of `project_id`, `folder_id`, or `organization_id` to define the scope at which the IAM policies will be applied.

## Usage

Below are examples of how to use the module to manage IAM policies at different resource levels.

### Project-level IAM

This example applies both authoritative and conditional additive bindings to a GCP project.

```hcl
module "project_iam" {
  source = "./" # Or a Git repository source

  project_id = "your-gcp-project-id"

  # Authoritative bindings: replaces all existing members for these roles.
  bindings = {
    "roles/storage.objectViewer" = [
      "group:data-analysts@example.com",
    ]
    "roles/viewer" = [
      "user:jane.doe@example.com",
      "serviceAccount:my-app@your-gcp-project-id.iam.gserviceaccount.com",
    ]
  }

  # Additive bindings: adds a member to a role, optionally with a condition.
  conditional_bindings = [
    {
      role   = "roles/iam.serviceAccountUser"
      member = "user:temp-contractor@example.com"
      condition = {
        title       = "expires_after_2024_12_31"
        description = "Temporary access for contractor"
        expression  = "request.time < timestamp('2025-01-01T00:00:00Z')"
      }
    }
  ]
}
```

### Folder-level IAM

To apply policies to a folder, simply provide the `folder_id` instead of `project_id`.

```hcl
module "folder_iam" {
  source = "./"

  folder_id = "folders/123456789012"

  bindings = {
    "roles/resourcemanager.folderViewer" = [
      "group:auditors@example.com",
    ]
  }
}
```

### Organization-level IAM

To apply policies to an organization, provide the `organization_id`.

```hcl
module "org_iam" {
  source = "./"

  organization_id = "organizations/123456789012"

  bindings = {
    "roles/billing.user" = [
      "group:finance-team@example.com",
    ]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bindings` | A map of authoritative IAM bindings. The key is the role and the value is a list of members. Any existing members of these roles will be removed. Example: `{'roles/viewer' = ['user:jane@example.com']}` | `map(list(string))` | `{}` | no |
| `conditional_bindings` | A list of additive IAM bindings, each with an optional condition. Each binding grants a role to a single member without affecting other members of the role. | <pre>list(object({<br>  role   = string<br>  member = string<br>  condition = optional(object({<br>    title       = string<br>    description = string<br>    expression  = string<br>  }))<br>}))</pre> | `[]` | no |
| `folder_id` | The ID of the folder to which IAM policies will be applied (e.g., 'folders/12345678'). Exactly one of `project_id`, `folder_id`, or `organization_id` must be specified. | `string` | `null` | no |
| `organization_id` | The ID of the organization to which IAM policies will be applied (e.g., 'organizations/12345678'). Exactly one of `project_id`, `folder_id`, or `organization_id` must be specified. | `string` | `null` | no |
| `project_id` | The ID of the project to which IAM policies will be applied. Exactly one of `project_id`, `folder_id`, or `organization_id` must be specified. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `additive_members_ids` | A map of resource IDs for the additive IAM members created, keyed by 'role/member'. |
| `authoritative_bindings_etags` | A map of etags for the authoritative IAM bindings created, keyed by role. |

## Requirements

The following requirements are needed by this module.

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.54.0 |
