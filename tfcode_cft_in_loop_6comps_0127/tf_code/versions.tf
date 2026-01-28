# This block defines the required Terraform version and the necessary providers for this module.
# It specifies the source and version constraints for the Google Cloud provider.
terraform {
  # Specifies the minimum required version of Terraform. Version bumped to 1.5 to support check blocks.
  required_version = ">= 1.5"

  # Defines the required providers for this module.
  required_providers {
    # Defines the Google Cloud provider.
    google = {
      # The official source of the Google provider.
      source = "hashicorp/google"
      # The minimum version of the Google provider required.
      version = ">= 4.54.0"
    }
  }
}
