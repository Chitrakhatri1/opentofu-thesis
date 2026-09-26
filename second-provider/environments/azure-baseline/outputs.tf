output "resource_group_name" {
  description = "Name of the Azure resource group."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "ID of the Azure virtual network."
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Azure subnet IDs keyed by logical subnet name."
  value       = module.network.subnet_ids
}

output "storage_account_name" {
  description = "Name of the Azure storage account."
  value       = module.storage.storage_account_name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint. Public network access is disabled."
  value       = module.storage.primary_blob_endpoint
}
