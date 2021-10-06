
variable "prefix" {
  default = ""
}

variable "subscription_id" {
    default = ""
}

variable "client_secret" {
  default = ""
}
variable "client_id" {
  default = ""
}

variable "tenant_id" {
  default = ""
}

variable "location" {
  default = "westeurope"
}

variable "owner" {
    default = ""
}

variable "key_name" {
  description = "Azure Key Vault key name"
  default     = "generated-key"
}

variable "vault_download_url" {
  default = "https://releases.hashicorp.com/vault/1.4.3+ent/vault_1.4.3+ent_linux_amd64.zip"
}

variable "license" {
  default=""
}
variable "vault_namespace" {
  default="root"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "public_key" {
  default = ""
}