output "storage_account_id" {
  description = "ID of the Azure storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Globally unique name of the Azure storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint. Public network access is disabled."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
