terraform {
  # This block specifies the required Terraform version and provider configurations.
  required_version = ">= 1.3"
  required_providers {
    # The Google Provider is required for managing GCP resources.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
