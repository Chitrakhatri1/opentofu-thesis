variable "name_prefix" {
  description = "Prefix used for resource names and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,31}$", var.name_prefix))
    error_message = "name_prefix must be 3-32 lowercase characters, digits, or hyphens, starting with a letter."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "Map of public subnet definitions keyed by a stable logical name."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  validation {
    condition     = length(var.public_subnets) >= 2 && alltrue([for subnet in values(var.public_subnets) : can(cidrnetmask(subnet.cidr_block))])
    error_message = "Define at least two public subnets with valid IPv4 CIDR blocks."
  }
}

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
