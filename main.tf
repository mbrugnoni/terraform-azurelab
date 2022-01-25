terraform {

  #  required_version = ">=0.12"
  backend "azure" {}
  
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

# Create resource group if it doesn't exist
resource "azurerm_resource_group" "rg-mbrugnon-lab" {
  name      = "rg-mbrugnon-lab"
  location  = var.resource_group_location
}

# Create NSG
resource "azurerm_network_security_group" "mbrugnonlab-nsg" {
  name                = "mbrugnonlab-nsg"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-mbrugnon-lab.name
}

# Create virtual network - with subnet included(could be done separately)
resource "azurerm_virtual_network" "mbrugnonlab-vnet" {
  name                = "mbrugnonlab-vnet"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-mbrugnon-lab.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "mbrugnonlab-snet1" {
  name           = "mbrugnonlab-snet1"
  address_prefix = "10.0.1.0/24"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-mbrugnon-lab.name
  virtual_network_name = azurerm_virtual_network.mbrugnonlab-vnet.name
}

# Create network interface for VM
resource "azurerm_network_interface" "mbrugnonlab-nic" {
    name                      = "mbrugnonlab-nic"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.rg-mbrugnon-lab.name

    ip_configuration {
        name                          = "mbrugnonlab-nic-cfg"
        subnet_id                     = azurerm_subnet.mbrugnonlab-snet1.id
        private_ip_address_allocation = "Dynamic"
    }
}

# Connect the security group to the network interface
#resource "azurerm_network_interface_security_group_association" "nsg-assoc1" {
#    network_interface_id      = azurerm_network_interface.mbrugnonlab-nic.id
#    network_security_group_id = azurerm_network_security_group.mbrugnonlab-nsg.id
#}

# Create virtual machine
#resource "azurerm_linux_virtual_machine" "mikesVM" {
#    name                  = "mikesVM"
#    #    depends_on = [
#    #  azurerm_virtual_network.mbrugnonlab-vnet.subnet.mbrugnonlab-snet1.id
#    #]
#    location              = "eastus"
#    resource_group_name   = azurerm_resource_group.rg-mbrugnon-lab.name
#    network_interface_ids = azurerm_network_interface.mbrugnonlab-nic.id
#    size                  = "Standard_DS1_v2"
#
#    os_disk {
#        name              = "myOsDisk"
#        caching           = "ReadWrite"
#        storage_account_type = "Premium_LRS"
#    }
#
#    source_image_reference {
#        publisher = "Canonical"
#        offer     = "UbuntuServer"
#        sku       = "18.04-LTS"
#        version   = "latest"
#    }
#
#    computer_name  = "mikesVM"
#    admin_username = "mbrugnon"
#    admin_password = "Temp12341234"
#    disable_password_authentication = true

#}
