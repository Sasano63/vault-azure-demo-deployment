resource "random_id" "keyvault" {
  byte_length = 6
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "vault" {
  name                = "${var.prefix}-vault-keyvault"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  # enable virtual machines to access this key vault.
  # NB this identity is used in the example /tmp/azure_auth.sh file.
  #    vault is actually using the vault service principal.
  enabled_for_deployment = true
    enabled_for_disk_encryption = true

  sku_name = "standard"

  tags = {
    owner = var.owner
  }

  # access policy for the hashicorp vault service principal.
  access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id

    #object_id = var.object_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
      "list",
      "create",
      "delete",
      "update",
      "wrapKey",
      "unwrapKey",
      "purge",
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
  depends_on   = [azurerm_key_vault.vault]
  name         = "${var.prefix}-key"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

output "key_vault_name" {
  value = azurerm_key_vault.vault.name
}