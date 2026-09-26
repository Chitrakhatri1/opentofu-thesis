locals {
  normalized_prefix    = replace(var.name_prefix, "-", "")
  storage_account_name = "${substr(local.normalized_prefix, 0, 24 - length(var.unique_suffix))}${var.unique_suffix}"
}

resource "azurerm_storage_account" "this" {
  name                            = local.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  tags                            = var.tags

  blob_properties {
    versioning_enabled = true
  }
}
