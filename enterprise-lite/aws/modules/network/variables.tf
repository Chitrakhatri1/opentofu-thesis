variable "name_prefix" { type = string }
variable "aws_region" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" {
  type = map(object({ cidr_block = string, availability_zone = string }))
}
variable "private_subnets" {
  type = map(object({ cidr_block = string, availability_zone = string }))
}
variable "tags" { type = map(string) }
