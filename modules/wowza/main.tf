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
  enforce_private_link_service_network_policies = true
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

resource "azurerm_public_ip" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_lb" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.wowza.id
  }
}

resource "azurerm_lb_probe" "wowza_rtmps" {
  resource_group_name = azurerm_resource_group.wowza.name
  loadbalancer_id     = azurerm_lb.wowza.id
  name                = "rtmps-running-probe"
  port                = 443
}

resource "azurerm_lb_probe" "wowza_rest" {
  resource_group_name = azurerm_resource_group.wowza.name
  loadbalancer_id     = azurerm_lb.wowza.id
  name                = "rest-running-probe"
  port                = 8087
}

resource "azurerm_lb_rule" "wowza" {
  resource_group_name            = azurerm_resource_group.wowza.name
  loadbalancer_id                = azurerm_lb.wowza.id
  name                           = "RTMPS-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.wowza_rtmps.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wowza.id
  load_distribution              = "SourceIPProtocol"
  idle_timeout_in_minutes        = 30
}

resource "azurerm_lb_rule" "wowza_rest" {
  count = var.wowza_instance_count

  resource_group_name            = azurerm_resource_group.wowza.name
  loadbalancer_id                = azurerm_lb.wowza.id
  name                           = "REST-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = 8090 + count.index
  backend_port                   = 8087
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.wowza_rest.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.wowza_vm[count.index].id
}

# resource "azurerm_lb_rule" "wowza_rtmps_direct" {
#   count = var.wowza_instance_count

#   resource_group_name            = azurerm_resource_group.wowza.name
#   loadbalancer_id                = azurerm_lb.wowza.id
#   name                           = "RTMPS-Direct-${count.index}"
#   protocol                       = "Tcp"
#   frontend_port                  = 8010 + count.index
#   backend_port                   = 443
#   frontend_ip_configuration_name = "PublicIPAddress"
#   probe_id                       = azurerm_lb_probe.wowza_rtmps.id
#   backend_address_pool_id        = azurerm_lb_backend_address_pool.wowza_vm[count.index].id
# }

resource "azurerm_lb_backend_address_pool" "wowza" {
  resource_group_name = azurerm_resource_group.wowza.name
  loadbalancer_id     = azurerm_lb.wowza.id
  name                = "wowza"
}

resource "azurerm_lb_backend_address_pool" "wowza_vm" {
  count = var.wowza_instance_count

  resource_group_name = azurerm_resource_group.wowza.name
  loadbalancer_id     = azurerm_lb.wowza.id
  name                = "${var.service_name}-${count.index}"
}

resource "azurerm_network_security_group" "wowza" {
  name = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

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
    name                       = "RTMPS"
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
  count = var.wowza_instance_count

  name = "${var.service_name}_${count.index}"

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  ip_configuration {
    name                          = "wowzaConfiguration"
    subnet_id                     = azurerm_subnet.wowza.id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_interface_security_group_association" "wowza" {
  count = var.wowza_instance_count

  network_interface_id      = azurerm_network_interface.wowza[count.index].id
  network_security_group_id = azurerm_network_security_group.wowza.id
}

resource "azurerm_network_interface_backend_address_pool_association" "wowza" {
  count = var.wowza_instance_count

  network_interface_id    = azurerm_network_interface.wowza[count.index].id
  ip_configuration_name   = "wowzaConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wowza.id
}

resource "azurerm_network_interface_backend_address_pool_association" "wowza_vm" {
  count = var.wowza_instance_count

  network_interface_id    = azurerm_network_interface.wowza[count.index].id
  ip_configuration_name   = "wowzaConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wowza_vm[count.index].id
}

resource "azurerm_private_link_service" "wowza" {
  name                = var.service_name

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.wowza.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "primary"
    subnet_id                  = azurerm_subnet.wowza.id
    primary                    = true
  }
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
    certPassword         = random_password.certPassword.result
    certThumbprint       = upper(var.service_certificate_thumbprint)
    storageAccountName   = azurerm_storage_account.wowza_recordings.name
    storageContainerName = azurerm_storage_container.recordings.name
    msiClientId          = var.storage_msi_client_id
    restPassword         = md5("wowza:Wowza:${random_password.restPassword.result}")
    streamPassword       = md5("wowza:Wowza:${random_password.streamPassword.result}")
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
  count = var.wowza_instance_count

  name = "${var.service_name}-${count.index}"

  depends_on = [
    azurerm_private_dns_a_record.wowza_storage,
    azurerm_private_dns_zone_virtual_network_link.wowza,
    azurerm_managed_disk.wowza_data
  ]

  resource_group_name = azurerm_resource_group.wowza.name
  location            = azurerm_resource_group.wowza.location

  size           = var.vm_size
  admin_username = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.wowza[count.index].id,
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
    type = "UserAssigned"
    identity_ids = [
      var.storage_msi_client_id
    ]
  }

  lifecycle {
    ignore_changes = [
      # custom_data
    ]
  }
}

resource "azurerm_managed_disk" "wowza_data" {
  count = var.wowza_instance_count

  name = "${var.service_name}_${count.index}-wowzadata"

  resource_group_name  = azurerm_resource_group.wowza.name
  location             = azurerm_resource_group.wowza.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 512
}

resource "azurerm_virtual_machine_data_disk_attachment" "wowza_data" {
  count = var.wowza_instance_count

  managed_disk_id    = azurerm_managed_disk.wowza_data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.wowza[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}
