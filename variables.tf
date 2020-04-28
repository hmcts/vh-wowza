variable "workspace_to_address_space_map" {
  type = map(string)
  default = {
    prod    = "10.50.10.0/28"
    preprod = "10.50.10.16/28"
    dev     = "10.50.10.32/28"
    demo    = "10.50.10.48/28"
  }
}
