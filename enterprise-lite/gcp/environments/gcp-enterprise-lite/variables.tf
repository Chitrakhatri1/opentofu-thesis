variable "project_id" {
  description = "Google Cloud project ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must use lowercase letters, digits, and hyphens only; underscores are not valid."
  }
}

variable "project_name" {
  description = "Lowercase project name used in resources."
  type        = string
  default     = "opentofu-thesis"
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "enterprise"
}

variable "region" {
  description = "Free Tier eligible region for the bounded implementation."
  type        = string
  default     = "us-central1"

  validation {
    condition     = contains(["us-central1", "us-east1", "us-west1"], var.region)
    error_message = "Use us-central1, us-east1, or us-west1 for current GCP Free Tier eligibility."
  }
}

variable "zone" {
  description = "Compute zone within the selected region."
  type        = string
  default     = "us-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR for the private workload subnet."
  type        = string
  default     = "10.70.1.0/24"
}

variable "bucket_suffix" {
  description = "Globally unique 4-12 character lowercase suffix."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{4,12}$", var.bucket_suffix))
    error_message = "bucket_suffix must be 4-12 lowercase letters or digits."
  }
}

variable "enable_compute" {
  description = "Create one private e2-micro VM. Disabled by default to avoid accidental usage."
  type        = bool
  default     = false
}
