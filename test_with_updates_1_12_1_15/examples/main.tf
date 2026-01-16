# This file provisions the prerequisite resources (a storage bucket and two service accounts)
# and then instantiates the IAM module to manage permissions on them and the project.

# Provides a random suffix for resource names to ensure uniqueness.
resource "random_id" "suffix" {
  byte_length = 4
}

# Creates a Google Cloud Storage bucket to which IAM policies will be applied.
resource "google_storage_bucket" "example_bucket" {
  project  = var.project_id
  name     = "iam-module-example-bucket-${random_id.suffix.hex}"
  location = var.region
  # Uniform bucket-level access is required for IAM policies.
  uniform_bucket_level_access = true
}

# Creates a service account that will have IAM policies applied to it.
resource "google_service_account" "test_sa" {
  project      = var.project_id
  account_id   = "iam-test-sa-${random_id.suffix.hex}"
  display_name = "IAM Module Test Service Account"
}

# Creates a service account that will be granted IAM roles.
resource "google_service_account" "member_sa" {
  project      = var.project_id
  account_id   = "iam-member-sa-${random_id.suffix.hex}"
  display_name = "IAM Module Member Service Account"
}

# Instantiates the IAM module to manage IAM policies for the project,
# the storage bucket, and the service account created above.
module "iam_manager" {
  source = "../../"

  # iam_bindings are authoritative and overwrite any existing members for a given role.
  # This example grants the 'logging.viewer' role to a service account on the project.
  iam_bindings = [
    {
      resource_type = "project"
      resource_id   = var.project_id
      role          = "roles/logging.viewer"
      members       = [google_service_account.member_sa.member]
    }
  ]

  # iam_members are non-authoritative and additively grant permissions.
  # This is the recommended approach for most use cases.
  iam_members = [
    # 1. Grant a user the 'storage.objectViewer' role on the created bucket.
    {
      resource_type = "storage_bucket"
      resource_id   = google_storage_bucket.example_bucket.name
      role          = "roles/storage.objectViewer"
      member        = "user:${var.user_email}"
    },
    # 2. Grant one service account the ability to create tokens for another service account.
    {
      resource_type = "service_account"
      resource_id   = google_service_account.test_sa.name # Note: .name gives the full resource identifier
      role          = "roles/iam.serviceAccountTokenCreator"
      member        = google_service_account.member_sa.member
    },
    # 3. Grant the member service account the 'iam.serviceAccountUser' role on the project.
    {
      resource_type = "project"
      resource_id   = var.project_id
      role          = "roles/iam.serviceAccountUser"
      member        = google_service_account.member_sa.member
    },
    # 4. Conditionally grant a role to a service account on the bucket.
    #    This role is only active before Jan 1, 2030.
    {
      resource_type = "storage_bucket"
      resource_id   = google_storage_bucket.example_bucket.name
      role          = "roles/storage.objectCreator"
      member        = google_service_account.member_sa.member
      condition = {
        title       = "expires_2030"
        description = "Access is valid until the start of 2030."
        expression  = "request.time < timestamp(\"2030-01-01T00:00:00Z\")"
      }
    }
  ]
}
