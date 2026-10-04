locals {
  name = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "../../modules/network"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "acr" {
  source              = "../../modules/acr"
  project             = var.project
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}