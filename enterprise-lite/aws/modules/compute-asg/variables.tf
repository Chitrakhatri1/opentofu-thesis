variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "alb_security_group_id" { type = string }
variable "target_group_arn" { type = string }
variable "instance_profile_name" { type = string }
variable "instance_type" { type = string }
variable "tags" { type = map(string) }
