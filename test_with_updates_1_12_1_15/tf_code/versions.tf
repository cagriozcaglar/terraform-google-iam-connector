# Specifies the required versions for Terraform and the Google Provider.
# The `optional` attribute in variable types requires Terraform 1.3.0 or later.
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.54.0"
    }
  }
}
