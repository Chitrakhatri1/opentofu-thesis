locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform-or-OpenTofu"
    Purpose     = "Masters-thesis-experiment"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix    = local.name_prefix
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  tags           = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  name_prefix                     = local.name_prefix
  vpc_id                          = module.network.vpc_id
  subnet_id                       = module.network.public_subnet_ids[sort(keys(module.network.public_subnet_ids))[0]]
  instance_type                   = var.instance_type
  allowed_http_security_group_ids = [module.load_balancer.security_group_id]
  tags                            = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  name_prefix   = local.name_prefix
  force_destroy = var.force_destroy_bucket
  tags          = local.common_tags
}

module "load_balancer" {
  source = "../../modules/load-balancer"

  name_prefix        = local.name_prefix
  vpc_id             = module.network.vpc_id
  subnet_ids         = values(module.network.public_subnet_ids)
  allowed_http_cidrs = var.allowed_http_cidrs
  tags               = local.common_tags
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = module.load_balancer.target_group_arn
  target_id        = module.compute.instance_id
  port             = 80
}
