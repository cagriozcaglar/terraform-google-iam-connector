# The versions.tf file is used to specify the required versions of Terraform and providers.
# It ensures that the module is used with compatible versions, preventing potential issues
# due to breaking changes.

terraform {
  # This block specifies the required version of Terraform and the providers used in the module.
  required_providers {
    # The Google Provider is required for managing Google Cloud Platform resources.
    # Version constraint is set to ~> 5.0, allowing any non-breaking changes within version 5.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}
