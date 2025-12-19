terraform {
  # This module requires Terraform version 1.3.0 or newer.
  required_version = ">= 1.3"

  # This module uses the Google Cloud Beta provider for Workforce Identity Pool features.
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.45.0"
    }
  }
}
