output "project_id" { value = var.project_id }
output "region" { value = var.region }
output "network_name" { value = module.network.network_name }
output "subnet_name" { value = module.network.subnet_name }
output "bucket_name" { value = module.storage.bucket_name }
output "service_account_email" { value = module.identity.service_account_email }
output "compute_enabled" { value = var.enable_compute }
output "instance_name" { value = var.enable_compute ? module.compute[0].instance_name : null }
