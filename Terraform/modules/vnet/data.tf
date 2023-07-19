data "azurerm_resource_group" "vnet" {
  for_each = { for idx, rg in var.vnet : rg.name[0] => rg }

  name = each.value.resource_group_name
}