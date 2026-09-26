terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    google = {
      source  = "registry.terraform.io/hashicorp/google"
      version = "~> 7.0"
    }
  }
}
