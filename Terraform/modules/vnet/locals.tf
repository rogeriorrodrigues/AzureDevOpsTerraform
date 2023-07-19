locals {
  vnet_list = {
    for idx, value in var.vnet :
    value.name[0] => value
  }
}