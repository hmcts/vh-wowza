resource "azurerm_resource_group" "wowza" {
  name     = var.service_name
  location = var.location
  tags     = local.common_tags
}