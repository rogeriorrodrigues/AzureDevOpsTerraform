 resource "azurerm_user_assigned_identity" "aks_identity" {
    count               = length(var.aks)
   location            = var.aks[count.index].location
   name                = local.create_aks_identity[count.index]
   resource_group_name = var.aks[count.index].resource_group_name
 }

# resource "azurerm_role_assignment" "default" {
#   principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
#   scope                = azurerm_resource_group.default.id
#   role_definition_name = "Network Contributor"
# }

resource "azurerm_kubernetes_cluster" "aks" {
  count                             = length(var.aks)
  name                              = local.create_aks[count.index]
  location                          = var.aks[count.index].location
  resource_group_name               = var.aks[count.index].resource_group_name
  dns_prefix = var.aks[count.index].dns_prefix
  #dns_prefix                        = each.value.is_private_cluster ? local.dns_prefix_private[each.key] : local.dns_prefix_public[each.key]
  role_based_access_control_enabled = true
  #depends_on                        = [azurerm_role_assignment.default]

  default_node_pool {
    name            = var.aks[count.index].default_node_pool.name
    node_count      = var.aks[count.index].node_count
    vm_size         = var.aks[count.index].node_type
    os_disk_size_gb = var.aks[count.index].default_node_pool.os_disk_size_gb
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity[count.index].id]
  }

}