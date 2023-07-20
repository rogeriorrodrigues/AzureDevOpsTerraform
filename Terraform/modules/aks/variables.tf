
variable "aks" {
    description = "Azure Kubernetes Service configurations"
    type = list(object({
        name                              = string
        location                          = string
        resource_group_name               = string
        dns_prefix                        = string
        role_based_access_control_enabled = bool
        kubernetes_version              = string
        min_count                       = string
        max_count                       = string
        max_pod                      = string
        enable_auto_scaling             = string
        default_node_pool = map(string)
        #identity = map(string)
        service_principal = map(string)
        node_count = string
        node_type = string
        environment = string
        is_private_cluster = string
        dns_prefix = string
        dns_prefix_private_cluster = string
        network_profile = object({
            network_plugin = string
            network_policy = string
            dns_service_ip = string
            docker_bridge_cidr = string
            pod_cidr = string
            service_cidr = string
        })
    }))
    default = []
  
}






variable "dns_prefix" {
  type        = string
  description = "DNS Prefix"
  default     = "tfpiloto"
}