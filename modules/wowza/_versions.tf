terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 2.15.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2"
    }
  }
}
