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
  description = "HTTP URL for the demonstration. It is reachable only when allowed_http_cidrs permits the caller."
  value       = "http://${module.compute.public_dns}"
}

output "ami_id" {
  description = "Amazon Linux 2023 AMI selected for the experiment."
  value       = nonsensitive(module.compute.ami_id)
}

output "bucket_name" {
  description = "Generated S3 bucket name."
  value       = module.storage.bucket_id
}
