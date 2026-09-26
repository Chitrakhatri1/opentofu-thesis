variable "name_prefix" {
  description = "Prefix used for Azure resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.name_prefix))
    error_message = "name_prefix must be 3-32 lowercase characters, digits, or hyphens, starting with a letter."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure resource group containing the network."
  type        = string
}

variable "location" {
  description = "Azure region used for the network."
  type        = string
}

variable "vnet_address_space" {
  description = "IPv4 CIDR blocks assigned to the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.vnet_address_space) > 0 && alltrue([for cidr in var.vnet_address_space : can(cidrnetmask(cidr))])
    error_message = "vnet_address_space must contain at least one valid IPv4 CIDR block."
  }
}

variable "subnets" {
  description = "Subnet CIDR blocks keyed by a stable logical name."
  type        = map(list(string))

  validation {
    condition     = length(var.subnets) > 0 && alltrue(flatten([for prefixes in values(var.subnets) : [for cidr in prefixes : can(cidrnetmask(cidr))]]))
    error_message = "Define at least one subnet containing valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Additional tags applied to Azure resources that support tags."
  type        = map(string)
  default     = {}
}
