```markdown
# Google Project IAM Module

This Terraform module provides a comprehensive way to manage Identity and Access Management (IAM) policies at the Google Cloud project level. It supports authoritative, additive, and conditional bindings, as well as audit logging configurations.

## Usage

This module allows you to manage different types of IAM policies. If the `project_id` variable is not provided (`null`), no resources will be created.

### Basic Example

This example demonstrates how to apply a few common IAM bindings to a project. It assigns the `roles/storage.admin` role authoritatively (overwriting any existing members) and adds a single service account as a `roles/viewer` without affecting other viewers.

```terraform
module "project_iam" {
  source = "./" # Replace with module source

  project_id = "your-gcp-project-id"

  # Authoritative bindings: Replaces all members for the specified role.
  bindings = {
    "roles/storage.admin" = [
      "user:jane@example.com",
      "group:storage-admins@example.com",
    ]
  }

  # Additive bindings: Adds members to a role without affecting existing members.
  additive_bindings = {
    "roles/viewer" = [
      "serviceAccount:my-app-sa@your-gcp-project-id.iam.gserviceaccount.com",
    ]
  }
}
```

### Advanced Example

This example showcases conditional bindings and audit configurations. It grants a role only during specific hours and configures audit logs for data write operations across all services.

```terraform
module "project_iam_advanced" {
  source = "./" # Replace with module source

  project_id = "your-gcp-project-id"

  # Conditional bindings: Grants a role only when the condition is met.
  conditional_bindings = [
    {
      role        = "roles/storage.objectAdmin"
      title       = "access_during_business_hours"
      description = "Grants objectAdmin role to contractors during London business hours."
      expression  = "request.time.getHours('Europe/London') >= 9 && request.time.getHours('Europe/London') < 18"
      members     = ["group:contractors@example.com"]
    }
  ]

  # Audit configs: Defines which actions are logged for which services.
  audit_configs = [
    {
      service = "allServices"
      audit_log_configs = [
        {
          log_type = "DATA_WRITE"
        },
        {
          log_type         = "ADMIN_READ"
          exempted_members = ["user:auditor-bot@example.com"]
        },
      ]
    }
  ]
}
```

## Requirements

The following requirements are needed by this module.

### Software

The following software is required:

-   [Terraform](https://www.terraform.io/downloads.html) >= 1.0

### Providers

The following providers are required:

| Name | Version |
|------|---------|
| google | ~> 5.0 |

### APIs

A project with the following APIs enabled must be used:
-   Cloud Resource Manager API: `cloudresourcemanager.googleapis.com`

### Roles

The service account or user running Terraform must have the following roles on the project:
-   `roles/resourcemanager.projectIamAdmin` - to manage IAM policies.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `additive_bindings` | A map of non-authoritative IAM members. The keys are IAM roles, and the values are lists of members. This will add members to roles without affecting existing members. | `map(set(string))` | `{}` | no |
| `audit_configs` | A list of IAM audit configurations for the project. Each object specifies a service and its audit log configurations. | <pre>list(object({<br>    service = string<br>    audit_log_configs = list(object({<br>      log_type         = string<br>      exempted_members = optional(set(string), [])<br>    }))<br>  }))</pre> | `[]` | no |
| `bindings` | A map of authoritative IAM bindings. The keys are IAM roles, and the values are lists of members. This will overwrite any existing members for the given roles. | `map(set(string))` | `{}` | no |
| `conditional_bindings` | A list of authoritative conditional IAM bindings. Each object represents a binding with a condition. | <pre>list(object({<br>    role        = string<br>    title       = string<br>    description = optional(string)<br>    expression  = string<br>    members     = set(string)<br>  }))</pre> | `[]` | no |
| `project_id` | The ID of the project to which IAM policies will be applied. If not provided, no resources will be created. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `additive_members` | A map of non-authoritative IAM members created, keyed by role and member. |
| `authoritative_bindings_roles` | A list of roles managed with authoritative bindings. |
| `conditional_bindings_roles` | A set of roles managed with conditional bindings. |
| `project_id` | The ID of the project where the IAM policies were applied. |
```
