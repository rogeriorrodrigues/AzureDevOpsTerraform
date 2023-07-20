# terraform {
#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~>3.0"
#     }
#   }
#   backend "azurerm" {
#     resource_group_name  = "tfstate"
#     storage_account_name = "tfstate14577"
#     container_name       = "tfstate"
#     key                  = "$(echo $ARM_ACCESS_KEY)"
#   }
# }

provider "azurerm" {
  #version = "~> 2.0"
  features {}
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
          service_principal                 = map(string)
          node_count                        = string
          node_type                         = string
          environment                       = string
          is_private_cluster                = string
          dns_prefix                        = string
          dns_prefix_private_cluster        = string
          network_profile                   = map(string)
        }))
      }))
    }))
  }))
  default = {

  }
}

module "rg" {
  source = "../../modules/resourcegroup"
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
  source = "../../modules/apim"
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
          }
        ]
      ]
    ]
  ])
  depends_on = [ module.rg ]

  #location            = "eastus"
  #resource_group_name = "piloto-rg"
  #apim_name           = "piloto-apim"
  #publisher_name      = "piloto"
  #publisher_email     = "rrodrigues@microsoft.com"
  #sku                 = "Developer_1"
  #tags = {
  #  environment = "dev"
  #}
}


module "aks" {
  source = "../../modules/aks"
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
            service_principal                 = aks.service_principal
            node_count                        = aks.node_count
            node_type                         = aks.node_type
            environment                       = aks.environment
            is_private_cluster                = aks.is_private_cluster
            dns_prefix_private_cluster       = aks.dns_prefix_private_cluster
            network_profile                   = aks.network_profile
          }
        ]
      ]
    ]
  ])
  #   aks = flatten([
  #     for ambiente in var.ambientes : [
  #       for resourcegroup in ambiente.resourcegroup : [
  #         for computer in resourcegroup.computer : [
  #           for aks in computer.aks : {
  #             name                = aks.name
  #             environment         = aks.environment
  #             location            = aks.location
  #             resource_group_name = aks.resource_group_name
  #             node_count          = aks.node_count
  #             node_type           = aks.node_type
  #             dns_prefix          = aks.dns_prefix
  #           }
  #         ]
  #       ]
  #     ]
  #   ])
  depends_on = [ module.rg ]
}