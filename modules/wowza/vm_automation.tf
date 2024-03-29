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
    kvName               = data.azurerm_key_vault.vhcoreinfra.name
    kvClientId           = data.azurerm_user_assigned_identity.kv_user.client_id
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