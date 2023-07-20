locals {
  existing_apim = [for apim in var.apim : apim.name if apim.name != ""]
  create_apim    = [for apim in var.apim : apim.name if apim.name != ""]
  apim_count     = length(local.create_apim)
  revision = length(local.create_apim) > 1 ? [for i in range(1, length(local.create_apim)) : i] : [1]
}