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
