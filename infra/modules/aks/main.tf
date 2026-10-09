resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.name}"
  sku_tier            = "Free"
  tags                = var.tags

  default_node_pool {
    name            = "system"
    vm_size         = var.vm_size
    node_count      = var.node_count
    os_disk_size_gb = 32
    os_disk_type    = "Managed"
    vnet_subnet_id  = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }
}