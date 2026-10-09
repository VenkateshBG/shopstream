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

module "budget" {
  source          = "../../modules/budget"
  name            = "budget-${var.project}"
  subscription_id = var.subscription_id
  amount          = var.budget_amount
  start_date      = var.budget_start_date
  contact_emails  = var.alert_emails
}

module "aks" {
  source              = "../../modules/aks"
  name                = local.name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.aks_subnet_id
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  tags                = local.tags
}