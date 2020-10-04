output "vnet_id" {
  description = ""
  value       = azurerm_virtual_network.wowza.id
}

output "rest_password" {
  description = ""
  value       = random_password.restPassword.result
}

output "stream_password" {
  description = ""
  value       = random_password.streamPassword.result
}
