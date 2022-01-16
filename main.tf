terraform {

  required_version = ">=0.12"
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

resource "azurerm_resource_group" "rg-mbrugnon-lab" {
  name      = "rg-mbrugnon-lab"
  location  = var.resource_group_location
}

resource "azurerm_network_security_group" "mbrugnonlab-nsg" {
  name                = "mbrugnonlab-nsg"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-mbrugnon-lab.name
}

resource "azurerm_virtual_network" "mbrugnonlab-vnet" {
  name                = "mbrugnonlab-vnet"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg-mbrugnon-lab.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "mbrugnonlab-snet1"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.mbrugnonlab-nsg.id
  }

}
