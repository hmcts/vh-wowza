data "azurerm_key_vault" "vhcoreinfra" {
  name                = "vhcoreinfra${var.environment}"
  resource_group_name = "vh-core-infra-${var.environment}"
}

resource "azurerm_role_assignment" "kv_user" {
  scope                = data.azurerm_key_vault.vhcoreinfra.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_client_config.kv_user.object_id
}