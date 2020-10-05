terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "wowza/vh-wowza.tfstate"
  }

  required_version = ">= 0.13"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.7.0"
    }
  }
}
