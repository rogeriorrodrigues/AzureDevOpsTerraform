variable "resourcegroup" {
  description = "Azure Resource Group configurations"
  type        = list(object({
    name     = string
    location = string
    tags     = map(string)
  }))
  default     = []
}