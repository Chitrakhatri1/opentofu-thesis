output "vnet_id" {
  description = "ID of the Azure virtual network."
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Azure subnet IDs keyed by logical subnet name."
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}
