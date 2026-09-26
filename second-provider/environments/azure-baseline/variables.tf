variable "azure_location" {
  description = "Azure region used for the extensibility case."
  type        = string
  default     = "westeurope"
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
  description = "Environment label added to names and tags."
  type        = string
  default     = "experiment"

  validation {
    condition     = contains(["experiment", "development"], var.environment)
    error_message = "environment must be experiment or development."
  }
}

variable "unique_suffix" {
  description = "Lowercase letters and digits used to make the Azure storage account name globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,10}$", var.unique_suffix))
    error_message = "unique_suffix must contain 4-10 lowercase letters or digits."
  }
}

variable "vnet_address_space" {
  description = "IPv4 CIDR blocks assigned to the Azure virtual network."
  type        = list(string)
  default     = ["10.30.0.0/16"]
}

variable "subnets" {
  description = "Azure subnet CIDR blocks keyed by a stable logical name."
  type        = map(list(string))
  default = {
    workload = ["10.30.1.0/24"]
  }
}
