terraform {
  backend "azurerm" {
  }

  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 2.7.0"
  }
}
