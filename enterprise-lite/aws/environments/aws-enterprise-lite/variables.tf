variable "aws_region" {
  description = "AWS region for the enterprise-lite experiment."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Lowercase project name used in resource names."
  type        = string
  default     = "opentofu-thesis"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.project_name))
    error_message = "project_name must be 3-24 lowercase letters, digits, or hyphens."
  }
}

variable "environment" {
  description = "Environment label."
  type        = string
  default     = "enterprise"
}

variable "vpc_cidr" {
  description = "CIDR for the enterprise-lite VPC."
  type        = string
  default     = "10.60.0.0/16"
}

variable "public_subnets" {
  description = "Public ALB subnet definitions."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    public-a = { cidr_block = "10.60.1.0/24", availability_zone = "eu-central-1a" }
    public-b = { cidr_block = "10.60.2.0/24", availability_zone = "eu-central-1b" }
  }
}

variable "private_subnets" {
  description = "Private application subnet definitions."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    private-a = { cidr_block = "10.60.11.0/24", availability_zone = "eu-central-1a" }
    private-b = { cidr_block = "10.60.12.0/24", availability_zone = "eu-central-1b" }
  }
}

variable "instance_type" {
  description = "Single ASG workload instance type. Confirm current account eligibility before apply."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = var.instance_type == "t3.micro"
    error_message = "The thesis guardrail permits only t3.micro in this environment."
  }
}

variable "allowed_http_cidrs" {
  description = "CIDRs allowed to reach the public ALB; use your current public IPv4 with /32."
  type        = list(string)

  validation {
    condition     = length(var.allowed_http_cidrs) > 0 && alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "Provide at least one valid IPv4 CIDR."
  }
}

variable "force_destroy_bucket" {
  description = "Permit deletion of objects during disposable experiment cleanup."
  type        = bool
  default     = true
}
