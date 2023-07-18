variable "resourcegroup" {
  description = "Name of the Azure Resource Group"
  type        = list(object({
    name     = string
    location = string
    tags     = map(string)
  }))
}


