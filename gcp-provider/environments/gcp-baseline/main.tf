locals {
  name_prefix = "${var.project_name}-gcp-${var.environment}"

  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform-or-opentofu"
    purpose     = "masters-thesis-experiment"
    provider    = "gcp"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix = local.name_prefix
  project_id  = var.project_id
  region      = var.region
  subnet_cidr = var.subnet_cidr
}

module "storage" {
  source = "../../modules/storage"

  name_prefix   = local.name_prefix
  bucket_suffix = var.bucket_suffix
  project_id    = var.project_id
  region        = var.region
  labels        = local.common_labels
}
