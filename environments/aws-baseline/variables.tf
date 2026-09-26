variable "aws_region" {
  description = "AWS region used for the baseline."
  type        = string
  default     = "eu-central-1"
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

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the baseline VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet definitions. Availability zones must belong to aws_region."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    public-a = {
      cidr_block        = "10.20.1.0/24"
      availability_zone = "eu-central-1a"
    }
    public-b = {
      cidr_block        = "10.20.2.0/24"
      availability_zone = "eu-central-1b"
    }
  }
}

variable "instance_type" {
  description = "EC2 instance type. Review current AWS pricing before applying."
  type        = string
  default     = "t3.micro"
}

variable "allowed_http_cidrs" {
  description = "IPv4 CIDR blocks allowed to access the public load balancer. Prefer your public IPv4 address with /32."
  type        = list(string)

  validation {
    condition     = length(var.allowed_http_cidrs) > 0 && alltrue([for cidr in var.allowed_http_cidrs : can(cidrnetmask(cidr))])
    error_message = "Provide at least one valid IPv4 CIDR block for load-balancer HTTP access."
  }
}

variable "force_destroy_bucket" {
  description = "Allow deletion of a non-empty experimental S3 bucket."
  type        = bool
  default     = false
}
