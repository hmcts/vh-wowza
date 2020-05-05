resource "azurerm_resource_group" "wowza" {
  name     = var.service_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "wowza_recordings" {
  name                = replace(lower(var.service_name), "-", "")
  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  access_tier               = "Cool"
  account_kind              = "BlobStorage"
  account_tier              = "Standard"
  account_replication_type  = "RAGRS"
  enable_https_traffic_only = true
}

resource "azurerm_storage_container" "recordings" {
  name                  = "recordings"
  storage_account_name  = azurerm_storage_account.wowza_recordings.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "wowza" {
  name          = var.service_name
  address_space = [var.address_space]

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location
}

resource "azurerm_subnet" "wowza" {
  name                 = "wowza"
  resource_group_name  = azurerm_resource_group.wowza.name
  virtual_network_name = azurerm_virtual_network.wowza.name
  address_prefixes     = [var.address_space]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "wowza_storage" {
  name = "${azurerm_storage_account.wowza_recordings.name}-storage-endpoint"

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  subnet_id = azurerm_subnet.wowza.id

  private_service_connection {
    name                           = "${var.service_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.wowza_recordings.id
    subresource_names              = ["Blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.wowza.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "wowza" {
  name                  = var.service_name
  resource_group_name   = azurerm_resource_group.wowza.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.wowza.id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "wowza_storage" {
  name                = azurerm_storage_account.wowza_recordings.name
  zone_name           = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.wowza.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.wowza_storage.private_service_connection.0.private_ip_address]
}

# resource "azurerm_storage_account_network_rules" "wowza" {
#   resource_group_name  = azurerm_resource_group.wowza.name
#   storage_account_name = azurerm_storage_account.wowza_recordings.name

#   default_action             = "Deny"
#   ip_rules                   = []
#   virtual_network_subnet_ids = []
#   bypass                     = ["Logging", "AzureServices"]
# }

resource "azurerm_public_ip" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  allocation_method = "Static"
}

resource "azurerm_network_security_group" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  security_rule {
    name                       = "Server"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1935"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RTSP"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "554"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "REST"
    priority                   = 1030
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8087"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1040
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.wowza.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wowza.id
  }
}

resource "azurerm_network_interface_security_group_association" "wowza" {
  network_interface_id      = azurerm_network_interface.wowza.id
  network_security_group_id = azurerm_network_security_group.wowza.id
}

resource "random_password" "certPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "restPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "random_password" "streamPassword" {
  length           = 32
  special          = true
  override_special = "_%*"
}

resource "azurerm_key_vault_secret" "restPassword" {
  name         = "restPassword-${terraform.workspace}"
  value        = random_password.restPassword.result
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "streamPassword" {
  name         = "streamPassword-${terraform.workspace}"
  value        = random_password.streamPassword.result
  key_vault_id = var.key_vault_id
}

data "template_file" "cloudconfig" {
  template = file(var.cloud_init_file)
  vars = {
    certPassword       = random_password.certPassword.result
    certThumbprint     = upper(var.service_certificate_thumbprint)
    storageAccountName = azurerm_storage_account.wowza_recordings.name
    storageAccountKey  = azurerm_storage_account.wowza_recordings.primary_access_key
    restPassword       = md5(":Wowzawowza:${random_password.restPassword.result}")
    streamPassword     = md5("wowza:Wowza:${random_password.streamPassword.result}")
  }
}

data "template_cloudinit_config" "wowza_setup" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig.rendered
  }
}

resource "azurerm_linux_virtual_machine" "wowza" {
  name = var.service_name

  depends_on = [
    azurerm_private_dns_a_record.wowza_storage,
    azurerm_private_dns_zone_virtual_network_link.wowza
  ]

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.wowza.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = file(var.admin_ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
  }

  provision_vm_agent = true
  secret {
    certificate {
      url = var.service_certificate_kv_url
    }
    key_vault_id = var.key_vault_id
  }

  custom_data = data.template_cloudinit_config.wowza_setup.rendered

  source_image_reference {
    publisher = "wowza"
    offer     = "wowzastreamingengine"
    sku       = "linux-paid"
    version   = "4.7.7"
  }

  plan {
    name      = "linux-paid"
    product   = "wowzastreamingengine"
    publisher = "wowza"
  }

  identity {
    type = "SystemAssigned"
  }
}
