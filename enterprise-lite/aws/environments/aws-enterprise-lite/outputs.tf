output "vpc_id" { value = module.network.vpc_id }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "s3_endpoint_id" { value = module.network.s3_endpoint_id }
output "bucket_name" { value = module.storage.bucket_name }
output "workload_role_name" { value = module.identity.role_name }
output "autoscaling_group_name" { value = module.compute.autoscaling_group_name }
output "load_balancer_url" { value = module.load_balancer.url }
