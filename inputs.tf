variable "location" {
  type    = string
  default = "ukwest"
}

variable "admin_ssh_key_path" {
  type    = string
  default = "~/.ssh/wowza.pub"
}

variable "service_certificate_kv_url" {
  type = string
}

variable "service_certificate_thumbprint" {
  type = string
}

variable "key_vault_id" {
  type = string
}

# DNS
variable "dns_zone_name" {
  type = string
}

variable "dns_resource_group" {
  type = string
}

variable "dns_tenant_id" {
  type = string
}

variable "dns_client_id" {
  type = string
}

variable "dns_client_secret" {
  type = string
}

variable "dns_subscription_id" {
  type = string
}
