output "vnet_id" {
  description = "The id of the newly created vNet"
  value       = tomap(
    {
      for name, vnet in azurerm_virtual_network.vnet : name => vnet.id
    }
  )
}

output "vnet" {
  description = "The newly created vNet"
  value       = tomap(
    {
      for name, vnet in azurerm_virtual_network.vnet : name => vnet
    }
  )
}

output "vnet_location" {
  description = "The location of the newly created vNet"
  value       = tomap(
    {
      for name, vnet in azurerm_virtual_network.vnet : name => vnet.location
    }
  )
}

output "vnet_address_space" {
  description = "The address space of the newly created vNet"
  value       = tomap(
    {
      for name, vnet in azurerm_virtual_network.vnet : name => vnet.address_space
    }
  )
}

output "vnet_subnet_ids" {
  description = "The ids of subnets created inside the newly created vNet"
  value       = azurerm_subnet.subnet.*.id
}

output "vnet_subnet_names" {
  description = "The names of subnets created inside the newly created vNet"
  value       = azurerm_subnet.subnet.*.name
}

# output "vnet_delegate_subnet_ids" {
#   description = "The ids of subnets created inside the newly created vNet"
#   value       = azurerm_subnet.subnet_delegate.each["id"]
# }

output "vnet_delegate_subnet_names" {
  value = tomap(
    {
      for name, subnet in azurerm_subnet.subnet_delegate : name => subnet.name
    }
  )
}