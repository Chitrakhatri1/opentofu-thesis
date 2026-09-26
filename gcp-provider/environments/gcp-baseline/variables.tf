variable "project_id" {
  description = "Google Cloud project ID used for the extensibility case."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid Google Cloud project ID."
  }
}

variable "region" {
  description = "Google Cloud region used for the extensibility case."
  type        = string
  default     = "europe-west3"
}

variable "project_name" {
  description = "Short lowercase project name used in resource names."
  type        = string
  default     = "opentofu-thesis"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase characters, digits, or hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Environment label added to names and labels."
  type        = string
  default     = "experiment"

  validation {
    condition     = contains(["experiment", "development"], var.environment)
    error_message = "environment must be experiment or development."
  }
}

variable "bucket_suffix" {
  description = "Lowercase letters and digits used to make the Cloud Storage bucket name globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,12}$", var.bucket_suffix))
    error_message = "bucket_suffix must contain 4-12 lowercase letters or digits."
  }
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block assigned to the workload subnet."
  type        = string
  default     = "10.40.1.0/24"
}
