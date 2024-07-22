terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "unir-CP2"
      storage_account_name = "sastatestf"
      container_name       = "unircp2states"
      key                  = "XyF2AUwYVI40wTQgzgDT/33VMLLLkOmN5LP+3jomoZjzKJ0m011J28it35HeyuhMaQvEMT5jTPMp+AStS3INiw=="
  }

}
provider "azurerm" {
  features {}
}
