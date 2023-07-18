provider "azurerm" {
  #version = "~> 2.0"
  features {}
}
  


module "rg" {
  source = "../../modules/resourcegroup"
  resourcegroup = [
    {
      name     = "rg-iac-terraform-dev-01"
      location = "eastus"
      tags = {
        env        = "dev"
        project    = "terraform"
        department = "engineering"
      }
    },
    {
      name     = "rg-iac-terraform-dev-02"
      location = "eastus"
      tags = {
        env        = "dev"
        project    = "terraform"
        department = "engineering"
      }
    }
  ]
}

