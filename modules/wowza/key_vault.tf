data "azurerm_key_vault" "vhcoreinfra" {
  name                = "vhcoreinfra${var.environment}"
  resource_group_name = "vh-core-infra-${var.environment}"
}