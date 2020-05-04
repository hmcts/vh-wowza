terraform {
  backend "azurerm" {
    container_name = "tfstate"
    key            = "wowza/vh-wowza.tfstate"
  }

  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 2.7.0"
  }
}
