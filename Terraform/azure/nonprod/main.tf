provider "azurerm" {
  #version = "~> 2.0"
  features {}
}

variable "resourcegroup" {
  description = "Azure Resource Group configurations"
  type = list(object({
    name     = string
    location = string
    tags     = map(string)
    resourcegroup = list(object({
      name     = string
      location = string
      network = list(object({
        vnets = list(object({
          name                = string
          resource_group_name = string
          address_space       = list(string)
          dns_servers         = list(string)
          subnets = list(object({
            name                                           = string
            address_prefixes                               = list(string)
            service_endpoints                              = map(any)
            enforce_private_link_endpoint_network_policies = bool
            enforce_private_link_service_network_policies  = bool
            nsg_id                                         = string
            delegation = list(object({
              name = string
              service_delegation = list(object({
                name    = string
                actions = list(string)
              }))
            }))
          }))
        }))
      }))
    }))



  }))
}

module "rg" {
  source        = "../../modules/resourcegroup"
  resourcegroup = var.resourcegroup
}

module "vnet" {
  source = "../../modules/vnet"

  vnet = flatten([
    for vnet in var.resourcegroup : [
      for vnet in vnet.network : {
        name                                           = vnet.vnets.name
        resource_group_name                            = vnet.vnets.resource_group_name
        address_space                                  = vnet.vnets.address_space
        dns_servers                                    = vnet.vnets.dns_servers
        subnet_prefixes                                = vnet.vnets.subnets.address_prefixes
        subnet_names                                   = vnet.vnets.subnets.name
        subnet_service_endpoints                       = vnet.vnets.subnets.service_endpoints
        subnet_enforce_private_link_endpoint_network_policies = vnet.vnets.subnets.enforce_private_link_endpoint_network_policies
        subnet_enforce_private_link_service_network_policies  = vnet.vnets.subnets.enforce_private_link_service_network_policies
        nsg_ids                                        = vnet.vnets.subnets.nsg_id
        delegation                                     = vnet.vnets.subnets.delegation
        tags                                           = vnet.vnets.tags
      }
    ]
  ])
}