provider "azurerm" {
  #version = "~> 2.0"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


data "azurerm_client_config" "current" {}



variable "ambientes" {
  description = "Azure Resource Group configurations"
  type = map(object({
    name     = string
    location = string
    tags     = map(string)
    resourcegroup = list(object({
      name     = string
      location = string
      computer = list(object({
        apim = list(object({
          name                  = string
          location              = string
          resource_group_name   = string
          publisher_name        = string
          publisher_email       = string
          sku_name              = string
          tags                  = map(string)
          policy                = string
          custom_property       = map(string)
          identity              = map(string)
          create_email_template = bool
          path                  = string
          protocols             = list(string)
          description           = string
          policy                = string
          import                = map(string)
          method                = string
          url_template          = string
        }))
        aks = list(object({
          name                              = string
          location                          = string
          resource_group_name               = string
          dns_prefix                        = string
          role_based_access_control_enabled = bool
          kubernetes_version                = string
          min_count                         = string
          max_count                         = string
          max_pod                           = string
          enable_auto_scaling               = string
          default_node_pool                 = map(string)
          #identity                          = map(string)
          service_principal          = map(string)
          node_count                 = string
          node_type                  = string
          environment                = string
          is_private_cluster         = string
          dns_prefix                 = string
          dns_prefix_private_cluster = string
          network_profile            = map(string)
        }))
      }))
      network = list(object({
        vnet = list(object({
          name          = string
          address_space = list(string)
          location      = string
          tags          = map(string)
          subnet = list(object({
            name              = string
            address_prefixes  = list(string)
            service_endpoints = list(string)
            tags              = map(string)
          }))
        }))
      }))
    }))
  }))
  default = {}
}

module "rg" {
  source = "./../../modules/resourcegroup/"
  resourcegroup = flatten([
    for ambiente in var.ambientes : [
      for resourcegroup in ambiente.resourcegroup : {
        name     = resourcegroup.name
        location = resourcegroup.location
        tags     = ambiente.tags
      }
    ]
  ])
}

module "apim" {
  source = "./../../modules/apim/"
  apim = flatten([
    for ambiente in var.ambientes : [
      for resourcegroup in ambiente.resourcegroup : [
        for computer in resourcegroup.computer : [
          for apim in computer.apim : {
            name                  = apim.name
            location              = apim.location
            resource_group_name   = resourcegroup.name
            publisher_name        = apim.publisher_name
            publisher_email       = apim.publisher_email
            sku_name              = apim.sku_name
            tags                  = ambiente.tags
            policy                = apim.policy
            custom_property       = apim.custom_property
            identity              = apim.identity
            create_email_template = apim.create_email_template
            path                  = apim.path
            protocols             = apim.protocols
            description           = apim.description
            policy                = apim.policy
            import                = apim.import
            method                = apim.method
            url_template          = apim.url_template
          }
        ]
      ]
    ]
  ])
  depends_on = [module.rg]
}

module "aks" {
  source = "./../../modules/aks"
  aks = flatten([
    for ambiente in var.ambientes : [
      for resourcegroup in ambiente.resourcegroup : [
        for computer in resourcegroup.computer : [
          for aks in computer.aks : {
            name                              = aks.name
            location                          = aks.location
            resource_group_name               = resourcegroup.name
            dns_prefix                        = aks.dns_prefix
            role_based_access_control_enabled = aks.role_based_access_control_enabled
            kubernetes_version                = aks.kubernetes_version
            min_count                         = aks.min_count
            max_count                         = aks.max_count
            max_pod                           = aks.max_pod
            enable_auto_scaling               = aks.enable_auto_scaling
            default_node_pool                 = aks.default_node_pool
            #identity                          = aks.identity
            service_principal          = aks.service_principal
            node_count                 = aks.node_count
            node_type                  = aks.node_type
            environment                = aks.environment
            is_private_cluster         = aks.is_private_cluster
            dns_prefix_private_cluster = aks.dns_prefix_private_cluster
            network_profile            = aks.network_profile
          }
        ]
      ]
    ]
  ])
  depends_on = [module.rg]
}

module "network" {
  source = "./../../modules/network/vnet"
  vnet = flatten([
    for ambiente in var.ambientes : [
      for resourcegroup in ambiente.resourcegroup : [
        for network in resourcegroup.network : [
          for vnet in network.vnet : {
            name                = vnet.name
            resource_group_name = resourcegroup.name
            location            = vnet.location
            address_space       = vnet.address_space
            tags                = vnet.tags
            subnet = [
              for subnet in vnet.subnet : {
                name                 = subnet.name
                resource_group_name  = resourcegroup.name
                virtual_network_name = vnet.name
                address_prefixes     = subnet.address_prefixes
                service_endpoints    = subnet.service_endpoints
                tags                 = subnet.tags
              }
            ]
          }
        ]
      ]
    ]
  ])
  depends_on = [module.rg]
}

