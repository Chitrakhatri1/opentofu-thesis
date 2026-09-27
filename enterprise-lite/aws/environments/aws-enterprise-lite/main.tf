locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project      = var.project_name
    Environment  = var.environment
    ManagedBy    = "Terraform-or-OpenTofu"
    Purpose      = "Masters-thesis-enterprise-lite"
    Architecture = "EnterpriseLite"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix     = local.name_prefix
  aws_region      = var.aws_region
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  name_prefix   = local.name_prefix
  force_destroy = var.force_destroy_bucket
  tags          = local.common_tags
}

module "identity" {
  source = "../../modules/identity"

  name_prefix = local.name_prefix
  bucket_arn  = module.storage.bucket_arn
  tags        = local.common_tags
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  subnet_ids         = values(module.network.public_subnet_ids)
  allowed_http_cidrs = var.allowed_http_cidrs
  tags               = local.common_tags
}

module "compute" {
  source = "../../modules/compute-asg"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  private_subnet_ids    = values(module.network.private_subnet_ids)
  alb_security_group_id = module.load_balancer.security_group_id
  target_group_arn      = module.load_balancer.target_group_arn
  instance_profile_name = module.identity.instance_profile_name
  instance_type         = var.instance_type
  tags                  = local.common_tags
}
