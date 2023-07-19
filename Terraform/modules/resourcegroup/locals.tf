locals {
  existing_resourcegroups = [for rg in var.resourcegroup : rg.name if rg.name != ""]
  create_resourcegroup    = [for rg in var.resourcegroup : rg.name if rg.name != ""]
  resourcegroup_count     = length(local.create_resourcegroup)
}