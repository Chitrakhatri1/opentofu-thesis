locals {
  name_prefix = "${var.project_name}-gcp-${var.environment}"
  common_labels = {
    project      = var.project_name
    environment  = var.environment
    managed_by   = "terraform-or-opentofu"
    purpose      = "masters-thesis-enterprise-lite"
    architecture = "enterprise-lite"
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

module "identity" {
  source = "../../modules/identity"

  name_prefix = local.name_prefix
  project_id  = var.project_id
  bucket_name = module.storage.bucket_name
}

module "compute" {
  source = "../../modules/compute"
  count  = var.enable_compute ? 1 : 0

  name_prefix           = local.name_prefix
  project_id            = var.project_id
  zone                  = var.zone
  subnetwork_id         = module.network.subnetwork_id
  service_account_email = module.identity.service_account_email
  labels                = local.common_labels
}
