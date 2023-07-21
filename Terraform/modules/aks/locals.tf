locals {
  existing_aks = [for aks in var.aks : aks.name if aks.name != ""]
  create_aks    = [for aks in var.aks : aks.name if aks.name != ""]
  aks_count     = length(local.create_aks)
  create_aks_identity = [for aks in var.aks : aks.name if aks.name != ""]
  ## dns prefix com condicional para cluster privado ou publico
  dns_prefix_private = try(var.aks[0].dns_prefix_private_cluster != null && var.aks[0].is_private_cluster ? var.aks[0].dns_prefix_private_cluster : var.aks[0].dns_prefix, null)
  dns_prefix_public = try(var.aks.dns_prefix, null)
}