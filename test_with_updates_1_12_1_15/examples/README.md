# Basic IAM Example

This example demonstrates how to use the IAM module to manage both authoritative (`iam_binding`) and non-authoritative (`iam_member`) IAM policies on various Google Cloud resources.

The example will:
1. Create a new Google Cloud Storage bucket.
2. Create two new Service Accounts.
3. Use the IAM module to:
    - **Authoritatively** assign `roles/logging.viewer` on the project to one of the service accounts.
    - **Non-authoritatively** assign `roles/storage.objectViewer` on the bucket to a specified user.
    - **Non-authoritatively** assign `roles/iam.serviceAccountTokenCreator` on one service account to the other.
    - **Non-authoritatively** and **conditionally** assign `roles/storage.objectCreator` on the bucket, with the permission expiring at the start of 2030.

## How to use this example

### Prerequisites
1. Terraform v1.3.0 or later installed.
2. Google Cloud SDK installed and authenticated: `gcloud auth application-default login`.
3. A Google Cloud project with the necessary APIs enabled (Compute Engine, Cloud Resource Manager, IAM, and Cloud Storage).

### Running the example
1. Create a `terraform.tfvars` file in this directory with the following content, replacing the placeholder values with your own:
