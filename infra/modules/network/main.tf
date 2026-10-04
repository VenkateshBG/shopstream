resource "azurerm_virtual_network" "this" {
  name = "vnet-${var.name}"
  location = var.location
  resource_group_name = var.resource_group_name
  address_space = ["10.10.0.0/16"]
  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  name = "snet-aks"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "jenkins" {
  name = "snet-jenkins"
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = ["10.10.2.0/24"]
}