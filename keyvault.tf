resource "random_id" "keyvault" {
  byte_length = 6
}

data "azurerm_client_config" "current" {
}

data "azuread_service_principal" "vault" {
  application_id = var.client_id
}

resource "azurerm_key_vault" "vault" {
  name                = "${var.prefix}-vault-${random_id.keyvault.hex}"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  tenant_id           = var.tenant_id

  # enable virtual machines to access this key vault.
  # NB this identity is used in the example /tmp/azure_auth.sh file.
  #    vault is actually using the vault service principal.
  enabled_for_deployment = true

  sku_name = "standard"

  tags = {
    owner = var.owner
  }

  # access policy for the hashicorp vault service principal.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azuread_service_principal.vault.object_id

    key_permissions = [
      "get",
      "wrapKey",
      "unwrapKey",
    ]
  }

  # access policy for the user that is currently running terraform.
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
    ]
  }

  # TODO does this really need to be so broad? can it be limited to the vault vm?
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}


# hashicorp vault will use this azurerm_key_vault_key to wrap/encrypt its master key.
resource "azurerm_key_vault_key" "vault-key" {
  name         = var.key_name
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]
}

output "key_vault_name" {
  value = azurerm_key_vault.vault.name
}