
resource "azurerm_virtual_network" "vnet" {
  for_each = local.vnet_list
  name                = each.value.name[0] != null ? each.value.name[0] : data.azurerm_resource_group.vnet[each.key].name
  resource_group_name = each.value.resource_group_name[0] != null ? each.value.resource_group_name[0] : data.azurerm_resource_group.vnet[each.key].name
  location            = each.value.location[0] != null ? each.value.location[0] : data.azurerm_resource_group.vnet[each.key].location
  address_space       = each.value.address_space[0]
  dns_servers         = tolist(lookup(each.value, "dns_servers", [])) != [] ? tolist(lookup(each.value, "dns_servers", [])) : ["Azure DNS"]
  tags                = each.value.tags[0] != null ? each.value.tags[0] : data.azurerm_resource_group.vnet[each.key].tags
  depends_on          = [data.azurerm_resource_group.vnet] 
}

resource "azurerm_subnet" "subnet" {
  for_each = local.vnet_list

  name                                           = each.value.subnet_names[0]
  resource_group_name                            = each.value.resource_group_name[0] != null ? each.value.resource_group_name[0] : data.azurerm_resource_group.vnet[each.key].name
  virtual_network_name                           = each.value.name[0] != null ? each.value.name[0] : data.azurerm_resource_group.vnet[each.key].name
  address_prefixes                               = each.value.subnet_prefixes[0]
  service_endpoints                              = lookup(each.value.subnet_service_endpoints, each.value.subnet_names[0], [])
  enforce_private_link_endpoint_network_policies = lookup(each.value.subnet_enforce_private_link_endpoint_network_policies, each.value.subnet_names[0], false)
  enforce_private_link_service_network_policies  = lookup(each.value.subnet_enforce_private_link_service_network_policies, each.value.subnet_names[0], false)
  depends_on                                     = [azurerm_virtual_network.vnet]
}

locals {
  subnets = {
    for subnet in azurerm_subnet.subnet: 
    subnet.name => subnet.address_prefixes
  }
}

resource "azurerm_subnet" "subnet_delegate" {
  for_each                                       = local.vnet_list
  name                                           = each.value.subnet_names[0]
  resource_group_name                            = each.value.resource_group_name[0] != null ? each.value.resource_group_name[0] : data.azurerm_resource_group.vnet[each.key].name
  virtual_network_name                           = each.value.name[0] != null ? each.value.name[0] : data.azurerm_resource_group.vnet[each.key].name
  address_prefixes                               = each.value.subnet_prefixes[0]
  service_endpoints                              = lookup(each.value, "service_endpoints", [])
  enforce_private_link_endpoint_network_policies = lookup(each.value, "enforce_private_link_endpoint_network_policies", null)
  enforce_private_link_service_network_policies  = lookup(each.value, "enforce_private_link_service_network_policies", null)
  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }
}

locals {
  azurerm_subnets = {
    for index, subnet in azurerm_subnet.subnet :
    subnet.name => subnet.id
  }
  delegate_subnets = {
    for delegate_index, delegate_subnet in azurerm_subnet.subnet_delegate :
    delegate_subnet.name => delegate_subnet.id
  }
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each                  = local.vnet_list.nsg_ids # criar uma variable para tabela de security próprio para subnets delegadas
  
  subnet_id                 = local.azurerm_subnets[each.key] ? local.azurerm_subnets[each.key] : local.delegate_subnets[each.key]
  network_security_group_id = each.value != null ? each.value : null
}

resource "azurerm_subnet_route_table_association" "vnet" {
  for_each       = local.vnet_list.route_tables_ids # criar uma variable para tabela de roteamento próprio para subnets delegadas
  route_table_id = each.value != null ? each.value : null
  subnet_id      = local.azurerm_subnets[each.key] ? local.azurerm_subnets[each.key] : local.delegate_subnets[each.key]
}

resource "azurerm_subnet_network_security_group_association" "subnet_delegate" {
  for_each                  = local.vnet_list.nsg_ids # criar uma variable para tabela de security próprio para subnets delegadas
  subnet_id                 = local.delegate_subnets[each.key] ? local.delegate_subnets[each.key] : local.azurerm_subnets[each.key]
  network_security_group_id = each.value != null ? each.value : null
}

resource "azurerm_subnet_route_table_association" "subnet_delegate" {
  for_each       = local.vnet_list.route_tables_ids # criar uma variable para tabela de roteamento próprio para subnets delegadas
  route_table_id = each.value != null ? each.value : null
  subnet_id      = local.delegate_subnets[each.key] ? local.delegate_subnets[each.key] : local.azurerm_subnets[each.key]
}