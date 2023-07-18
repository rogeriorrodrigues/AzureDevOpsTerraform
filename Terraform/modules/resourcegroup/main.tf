resource "azurerm_resource_group" "resourcegroup" {
    count    = var.resourcegroup ? 1 : 0
    name     = var.resourcegroup[count.index].name
    location = var.resourcegroup[count.index].location
    tags     = var.resourcegroup[count.index].tags
}
