output "private_ips" {
  value = azurerm_network_interface.vm_nic[*].private_ip_address
}

output "master_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

data "azurerm_kubernetes_cluster" "node" {
  name                = azurerm_kubernetes_cluster.k8.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "node_private_ip" {
  value = data.azurerm_kubernetes_cluster.node.agent_pool_profile
}
# output "kube_config" {
#   value = azurerm_kubernetes_cluster.k8.kube_config_raw
#   sensitive = true
# }
