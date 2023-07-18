data "azurerm_resource_group" "resourcegroup" {
  count = length(var.resourcegroup)
  name  = var.resourcegroup[count.index].name

  depends_on = [
    azurerm_resource_group.resourcegroup
  ]
}