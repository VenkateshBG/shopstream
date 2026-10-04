output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}

output "acr_login_server" {
  value = module.acr.login_server
}