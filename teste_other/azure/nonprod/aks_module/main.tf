variable "location" {
  description = "The location where the AKS cluster will be created."
}

variable "tags" {
  description = "Tags to be applied to all resources."
  type        = map(string)
}

variable "apim_config" {
  description = "Configuration for the API Management service."
  type        = map(object({
    name            = string
    location        = string
    publisher_name  = string
    publisher_email = string
    sku_name        = string
    tags            = map(string)
    policy          = string
    custom_property = map(object({
      name  = string
      value = string
    }))
    identity               = map(object({
      type = string
    }))
    create_email_template  = bool
    path                   = string
    protocols              = list(string)
    description            = string
    import                 = map(object({
      content_format = string
      content_value  = string
    }))
    email_template = map(object({
      subject       = string
      template_name = string
      body          = string
    }))
  }))
}

variable "aks_config" {
  description = "Configuration for the AKS cluster."
  type        = map(object({
    name                              = string
    location                          = string
    resource_group_name               = string
    dns_prefix                        = string
    role_based_access_control_enabled = bool
    kubernetes_version                = string
    min_count                         = number
    max_count                         = number
    max_pod                           = number
    enable_auto_scaling               = bool
    default_node_pool                 = map(object({
      name            = string
      node_count      = number
      vm_size         = string
      os_disk_size_gb = number
    }))
    service_principal = map(object({
      client_id     = string
      client_secret = string
    }))
    node_count                 = number
    node_type                  = string
    environment                = string
    is_private_cluster         = bool
    dns_prefix_private_cluster = string
    network_profile = map(object({
      network_plugin     = string
      network_policy     = string
      dns_service_ip     = string
      docker_bridge_cidr = string
      pod_cidr           = string
      service_cidr       = string
    }))
    acr = map(object({
      name                = string
      resource_group_name = string
      sku                 = string
      admin_enabled       = bool
    }))
  }))
}

resource "azurerm_api_management" "apim" {
  for_each = var.apim_config

  name            = each.value.name
  location        = each.value.location
  publisher_name  = each.value.publisher_name
  publisher_email = each.value.publisher_email
  sku_name        = each.value.sku_name
  tags            = each.value.tags

  policy = each.value.policy

  custom_properties {
    name  = each.value.custom_property.name
    value = each.value.custom_property.value
  }

  identity {
    type = each.value.identity.type
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_config

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix

  role_based_access_control {
    enabled = each.value.role_based_access_control_enabled
  }

  kubernetes_version = each.value.kubernetes_version

  default_node_pool {
    name            = each.value.default_node_pool.name
    node_count      = each.value.default_node_pool.node_count
    vm_size         = each.value.default_node_pool.vm_size
    os_disk_size_gb = each.value.default_node_pool.os_disk_size_gb
  }

  service_principal {
    client_id     = each.value.service_principal.client_id
    client_secret = each.value.service_principal.client_secret
  }

  network_profile {
    network_plugin     = each.value.network_profile.network_plugin
    network_policy     = each.value.network_profile.network_policy
    dns_service_ip     = each.value.network_profile.dns_service_ip
    docker_bridge_cidr = each.value.network_profile.docker_bridge_cidr
    pod_cidr           = each.value.network_profile.pod_cidr
    service_cidr       = each.value.network_profile.service_cidr
  }

  default_node_pool {
    name            = each.value.default_node_pool.name
    node_count      = each.value.default_node_pool.node_count
    vm_size         = each.value.default_node_pool.vm_size
    os_disk_size_gb = each.value.default_node_pool.os_disk_size_gb
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_api_management_api" "apim_api" {
  for_each = var.apim_config

  api_management_name = azurerm_api_management.apim[each.key].name
  name                = each.value.name
  display_name        = each.value.name
  description         = each.value.description

  import {
    content_format = each.value.import.content_format
    content_value  = each.value.import.content_value
  }

  email_template {
    subject       = each.value.email_template.subject
    template_name = each.value.email_template.template_name
    body          = each.value.email_template.body
  }
}

resource "azurerm_api_management_api_operation" "apim_api_operation" {
  for_each = var.apim_config

  api_management_name = azurerm_api_management_api.apim_api[each.key].api_management_name
  api_name            = azurerm_api_management_api.apim_api[each.key].name
  name                = "operation1"
  display_name        = "Operation 1"
  method              = "GET"
  url_template        = "/operation1"
}

resource "azurerm_api_management_api_operation_policy" "apim_api_operation_policy" {
  for_each = var.apim_config

  api_management_name = azurerm_api_management_api_operation.apim_api_operation[each.key].api_management_name
  api_name            = azurerm_api_management_api_operation.apim_api_operation[each.key].api_name
  operation_name      = azurerm_api_management_api_operation.apim_api_operation[each.key].name

  xml_content = <<-XML
    <policies>
      <inbound>
        <base />
      </inbound>
      <backend>
        <base />
      </backend>
      <outbound>
        <base />
      </outbound>
      <on-error>
        <base />
      </on-error>
    </policies>
  XML
}
