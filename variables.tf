variable "workspace_to_address_space_map" {
  type = map(string)
  default = {
    prod    = "10.50.10.0/28"
    preprod = "10.50.10.16/28"
    dev     = "10.50.10.32/28"
    demo    = "10.50.10.48/28"
    test    = "10.0.0.0/28"
  }
}

variable "workspace_to_storage_msi_map" {
  type = map(string)
  default = {
    prod    = "/subscriptions/4bb049c8-33f3-4860-91b4-9ee45375cc18/resourceGroups/managed-identities-vh-vh-pilot-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/wowza-storage-prod"
    preprod = "/subscriptions/4bb049c8-33f3-4860-91b4-9ee45375cc18/resourceGroups/managed-identities-vh-vh-pilot-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/wowza-storage-preprod"
    dev     = "/subscriptions/705b2731-0e0b-4df7-8630-95f157f0a347/resourceGroups/managed-identities-vh-vh-dev-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/wowza-storage-dev"
    test    = "/subscriptions/705b2731-0e0b-4df7-8630-95f157f0a347/resourceGroups/managed-identities-vh-vh-dev-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/wowza-storage-test"
    demo    = "/subscriptions/705b2731-0e0b-4df7-8630-95f157f0a347/resourceGroups/managed-identities-vh-vh-dev-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/wowza-storage-demo"
  }
}

variable "workspace_to_boot_diag_storage_map"{
    type = map(string)
  default = {
    prod    = "https://vhcoreinfrapreprod.blob.core.windows.net/"
    preprod = "https://vhcoreinfrapreprod.blob.core.windows.net/"
    dev     = "https://vhcoreinfradev.blob.core.windows.net/"
    test    = "https://vhcoreinfradev.blob.core.windows.net/"
    demo    = "https://vhcoreinfradev.blob.core.windows.net/"
  }
}
