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

variable "allowed_http_security_group_ids" {
  description = "Security group IDs allowed to access HTTP port 80."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to every resource."
  type        = map(string)
  default     = {}
}
