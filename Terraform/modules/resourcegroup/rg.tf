resource "azurerm_resource_group" "resourcegroup" {
  count = length(local.create_resourcegroup)

  name     = local.create_resourcegroup[count.index]
  location = var.resourcegroup[count.index].location
  tags     = var.resourcegroup[count.index].tags
}