variable "name_prefix" {
  description = "Lowercase prefix used to construct the storage account name."
  type        = string
}

variable "unique_suffix" {
  description = "Lowercase letters and digits appended to make the storage account name globally unique."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,10}$", var.unique_suffix))
    error_message = "unique_suffix must contain 4-10 lowercase letters or digits."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure resource group containing the storage account."
  type        = string
}

variable "location" {
  description = "Azure region used for the storage account."
  type        = string
}

variable "tags" {
  description = "Additional tags applied to the storage account."
  type        = map(string)
  default     = {}
}
