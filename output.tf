
   
data "azurerm_public_ip" "vault-ip" {
  depends_on          = [azurerm_virtual_machine.vault-vm]
  name                = azurerm_public_ip.vault-ip.name
  resource_group_name = azurerm_virtual_machine.vault-vm.resource_group_name
}

output "vault_ip" {
  value = data.azurerm_public_ip.vault-ip.ip_address
}
output "vault_addr" {
  value = "http://${data.azurerm_public_ip.vault-ip.ip_address}:8200"
}


output "ssh-addr" {
  value = <<SSH
    Connect to your virtual machine via SSH:
    $ ssh azureuser@${data.azurerm_public_ip.vault-ip.ip_address}
SSH

}

