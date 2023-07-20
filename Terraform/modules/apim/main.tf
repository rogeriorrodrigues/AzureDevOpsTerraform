resource "azurerm_api_management" "apim_service" {
  count              = length(var.apim)
  name                = local.create_apim[count.index]
  location            = var.apim[count.index].location
  resource_group_name = var.apim[count.index].resource_group_name
  publisher_name      = var.apim[count.index].publisher_name
  publisher_email     = var.apim[count.index].publisher_email
  sku_name            = var.apim[count.index].sku_name
  tags = var.apim[count.index].tags

  policy {
    xml_content = var.apim[count.index].policy

  }

}

resource "azurerm_api_management_api" "api" {
  count               = length(var.apim)
  name                = local.create_apim[count.index]
  resource_group_name = var.apim[count.index].resource_group_name
  api_management_name = local.create_apim[count.index]
  revision            = local.revision[count.index]
  display_name        = local.create_apim[count.index]
  path                = var.apim[count.index].path
  protocols           = var.apim[count.index].protocols
  description         = var.apim[count.index].description
  import {
    content_format = var.apim[count.index].import.content_format
    content_value  = var.apim[count.index].import.content_value
  }
}
