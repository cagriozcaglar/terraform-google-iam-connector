terraform {
  # This block specifies the required version of Terraform.
  required_version = ">= 1.3.0"
  required_providers {
    # This block specifies the required version of the Google Cloud provider.
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}
