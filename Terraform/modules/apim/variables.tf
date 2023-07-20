       

variable "apim" {
    description = "Azure API Management configurations"
    type = list(object({
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
    default = []

  
}




