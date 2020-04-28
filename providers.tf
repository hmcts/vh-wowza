provider "azurerm" {
  version = ">= 2.7.0"
  features {}
}

provider "azurerm" {
  version = ">= 2.7.0"
  alias   = "dns"

  features {}

  tenant_id     = var.dns_tenant_id
  client_id     = var.dns_client_id
  client_secret = var.dns_client_secret

  subscription_id = var.dns_subscription_id
}

