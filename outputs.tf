output "rest_password" {
  description = ""
  value       = module.wowza.rest_password
  sensitive = true
}

output "stream_password" {
  description = ""
  value       = module.wowza.stream_password
  sensitive = true
}
