terraform {
  required_version = ">= 1.0.0"

required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.78.0"
    }
   azuread = {
      source = "hashicorp/azuread"
      version = ">=2.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
provider "azuread" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}
resource "azurerm_resource_group" "vault-rg" {
  name     = "${var.prefix}-vault-rg"
  location = var.location

  tags = {
    owner = var.owner
  }
}

resource "azurerm_virtual_network" "vault-vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  tags = {
    owner = var.owner
  }
}

resource "azurerm_subnet" "vault-subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.vault-rg.name
  virtual_network_name = azurerm_virtual_network.vault-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "vault-ip" {
  name                = "${var.prefix}-vault-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  allocation_method   = "Dynamic"

  tags = {
    owner = var.owner
  }
}

resource "azurerm_storage_account" "vault-storageaccount" {
  name                     = "sa${random_id.keyvault.hex}"
  resource_group_name      = azurerm_resource_group.vault-rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    owner = var.owner
  }
}


