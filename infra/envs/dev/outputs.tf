output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}