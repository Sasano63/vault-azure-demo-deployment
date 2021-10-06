data "template_file" "vault-setup" {
  template = file("${path.module}/vault.sh")

  vars = {
    resource_group_name = "${var.prefix}-vault-rg"
    vault_vm_name       = "${var.prefix}-vault-vm"
    vault_download_url  = var.vault_download_url
    tenant_id           = var.tenant_id
    subscription_id     = var.subscription_id
    client_id           = var.client_id
    client_secret       = var.client_secret
    vault_name          = azurerm_key_vault.vault.name
    key_name            = azurerm_key_vault_key.vault-key.name
    license             = var.license
    vault_namespace     = var.vault_namespace
  }
}

resource "azurerm_virtual_machine" "vault-vm" {

  name                  = "${var.prefix}-vault-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.vault-rg.name
  network_interface_ids = [azurerm_network_interface.vault-nic.id]
  vm_size               = var.vm_size

  identity {
    type = "SystemAssigned"
  }

  storage_os_disk {
    name              = "OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}-vault-vm"
    admin_username = "azureuser"
    custom_data    = base64encode(data.template_file.vault-setup.rendered)
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = var.public_key
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = azurerm_storage_account.vault-storageaccount.primary_blob_endpoint
  }

  tags = {
    owner = var.owner
  }
}