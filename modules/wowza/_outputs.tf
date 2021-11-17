output "vnet_id" {
  description = ""
  value       = azurerm_virtual_network.wowza.id
}

output "rest_password" {
  description = ""
  value       = random_password.restPassword.result
  sensitive = true
}

output "stream_password" {
  description = ""
  value       = random_password.streamPassword.result
  sensitive = true
}

output "public_ip_address" {
  value = azurerm_public_ip.wowza.ip_address
}