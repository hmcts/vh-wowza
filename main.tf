module "wowza" {
  source                         = "./modules/wowza"
  service_name                   = "vh-wowza-${terraform.workspace}"
  admin_ssh_key_path             = var.admin_ssh_key_path
  service_certificate_kv_url     = var.service_certificate_kv_url
  service_certificate_thumbprint = var.service_certificate_thumbprint
  key_vault_id                   = var.key_vault_id
  address_space = lookup(var.workspace_to_address_space_map, terraform.workspace, "")
}

resource "azurerm_dns_a_record" "wowza" {
  provider = azurerm.dns

  name                = "vh-wowza-${terraform.workspace}"
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group
  ttl                 = 300
  records             = [module.wowza.public_ip_address]
}
