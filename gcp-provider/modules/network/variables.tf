variable "name_prefix" {
  description = "Prefix used for network resource names."
  type        = string
}

variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region for the subnet."
  type        = string
}

variable "subnet_cidr" {
  description = "IPv4 CIDR block assigned to the workload subnet."
  type        = string
}
