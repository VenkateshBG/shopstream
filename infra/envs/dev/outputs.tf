output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "aks_name" {
  value = module.aks.name
}

output "get_credentials_cmd" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.name} --overwrite-existing"
}