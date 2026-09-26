variable "name_prefix" {
  description = "Prefix used for load-balancer resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the load balancer and target group are created."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs used by the Application Load Balancer."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "The Application Load Balancer requires at least two subnets."
  }
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDR blocks permitted to reach the public HTTP listener."
  type        = list(string)

  validation {
    condition     = length(var.allowed_http_cidrs) > 0 && alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "Provide at least one valid IPv4 CIDR block for ALB HTTP access."
  }
}

variable "health_check_path" {
  description = "HTTP path used to check target health."
  type        = string
  default     = "/"

  validation {
    condition     = startswith(var.health_check_path, "/")
    error_message = "health_check_path must start with /."
  }
}

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
