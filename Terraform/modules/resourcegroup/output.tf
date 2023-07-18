output "resourcegroup_name" {
  description = "The name of the Resource Group created"
  value       = azurerm_resource_group.resourcegroup.*.name
} 
output "resourcegroup_id" {
  description = "The ID of the Resource Group created"
  value       = azurerm_resource_group.resourcegroup.*.id
  
}

output "tags" {
  description = "The tags of the Resource Group created"
  value       = azurerm_resource_group.resourcegroup.*.tags
  
}

output "data_source" {
  description = "Data source for each Resource Group"
  value       = data.azurerm_resource_group.resourcegroup.*.id
}