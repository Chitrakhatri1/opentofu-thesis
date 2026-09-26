output "project_id" {
  description = "Google Cloud project containing the deployed resources."
  value       = var.project_id
}

output "region" {
  description = "Google Cloud region containing the regional resources."
  value       = var.region
}

output "network_name" {
  description = "Name of the custom VPC network."
  value       = module.network.network_name
}

output "network_id" {
  description = "ID of the custom VPC network."
  value       = module.network.network_id
}

output "subnet_name" {
  description = "Name of the workload subnet."
  value       = module.network.subnet_name
}

output "subnet_id" {
  description = "ID of the workload subnet."
  value       = module.network.subnet_id
}

output "bucket_name" {
  description = "Name of the private Cloud Storage bucket."
  value       = module.storage.bucket_name
}

output "bucket_url" {
  description = "Google Storage URL of the private bucket."
  value       = module.storage.bucket_url
}
