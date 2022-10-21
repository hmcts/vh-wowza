data "azurerm_key_vault" "vhcoreinfra" {
  name                = "vhcoreinfra${var.environment}"
  resource_group_name = "vh-core-infra-${var.environment}"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault_access_policy" "kv_user" {
  key_vault_id = data.azurerm_key_vault.vhcoreinfra.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_user_assigned_identity.kv_user.object_id
  
  certificate_permissions = [
    "Get",
  ]
}