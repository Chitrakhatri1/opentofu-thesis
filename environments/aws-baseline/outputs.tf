output "vpc_id" {
  description = "ID of the baseline VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by logical name."
  value       = module.network.public_subnet_ids
}

output "instance_id" {
  description = "ID of the demonstration EC2 instance."
  value       = module.compute.instance_id
}

output "instance_public_ip" {
  description = "Public IPv4 address of the demonstration EC2 instance."
  value       = module.compute.public_ip
}

output "instance_url" {
  description = "Direct instance URL for diagnostics. HTTP ingress permits only the load-balancer security group."
  value       = "http://${module.compute.public_dns}"
}

output "load_balancer_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = module.load_balancer.dns_name
}

output "load_balancer_url" {
  description = "Public HTTP URL for the thesis demonstration workload."
  value       = "http://${module.load_balancer.dns_name}"
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI selected for the experiment."
  value       = nonsensitive(module.compute.ami_id)
}

output "bucket_name" {
  description = "Generated S3 bucket name."
  value       = module.storage.bucket_id
}
