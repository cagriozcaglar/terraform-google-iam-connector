# Specifies the minimum version of Terraform required to apply this configuration.
terraform {
  required_version = ">= 1.5.0"

  # Specifies the required providers and their versions.
  required_providers {
    # The Google Cloud provider.
    google = {
      # The official HashiCorp Google Cloud provider.
      source  = "hashicorp/google"
      # The recommended version constraint.
      version = "~> 5.0"
    }
  }
}
