locals {
  name_prefix = "${var.project_name}-azure-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform-or-OpenTofu"
    Purpose     = "Masters-thesis-experiment"
    Provider    = "Azure"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name_prefix}-rg"
  location = var.azure_location
  tags     = local.common_tags
}

module "network" {
  source = "../../modules/network"

  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_address_space  = var.vnet_address_space
  subnets             = var.subnets
  tags                = local.common_tags
}

module "storage" {
  source = "../../modules/storage"

  name_prefix         = local.name_prefix
  unique_suffix       = var.unique_suffix
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  tags                = local.common_tags
}
