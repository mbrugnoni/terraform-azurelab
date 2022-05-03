terraform {

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "rg-temp-lab" {
  name      = var.rg_name 
  location  = var.resource_group_location
}

# Create NSG
resource "azurerm_network_security_group" "nsg-temp-lab" {
  name                = "nsg-temp-lab"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-temp-lab.name
}

# Create virtual network
resource "azurerm_virtual_network" "vnet-temp-lab" {
  name                = "vnet-temp-lab"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-temp-lab.name
  address_space       = ["172.1.0.0/16"]
}

# Create subnet
resource "azurerm_subnet" "snet-temp-lab" {
  name           = "snet1-temp-lab"
  address_prefix = "172.1.1.0/24"
  resource_group_name = azurerm_resource_group.rg-temp-lab.name
  virtual_network_name = azurerm_virtual_network.vnet-temp-lab.name
}

# Create network interface for VM
resource "azurerm_network_interface" "nic1-temp-lab" {
    name                      = "nic1-temp-lab"
    location                  = var.resource_group_location
    resource_group_name       = azurerm_resource_group.rg-temp-lab.name

    ip_configuration {
        name                          = "ip-temp-lab"
        subnet_id                     = azurerm_subnet.snet-temp-lab.id
        private_ip_address_allocation = "Dynamic"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsgassoc-temp-lab" {
    network_interface_id      = azurerm_network_interface.nic1-temp-lab.id
    network_security_group_id = azurerm_network_security_group.nsg-temp-lab.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "labVM1" {
    name                  = "labVM1"
    location              = azurerm_resource_group.rg-temp-lab.location
    resource_group_name   = azurerm_resource_group.rg-temp-lab.name
    admin_username = "tform"
    network_interface_ids =  [ 
      azurerm_network_interface.nic1-temp-lab.id,
    ]

    admin_ssh_key {
      username   = "tform"
      public_key = file("id_rsa.pub")
    }

    size           = "Standard_B1"

    os_disk {
        caching           = "None"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

}
