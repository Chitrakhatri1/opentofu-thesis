variable "name_prefix" {
  description = "Prefix used for resource names and tags."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the instance and security group are created."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet in which the demonstration instance is created."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the demonstration workload."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to access HTTP port 80. Keep empty unless conducting a short test."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "Every allowed_http_cidrs entry must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
