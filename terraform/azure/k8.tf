# AKS

resource "azurerm_kubernetes_cluster" "k8" {
  name                = join("-", [var.resource_group_name, "k8"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # node_resource_group = azurerm_resource_group.rg.name
  dns_prefix         = join("-", [var.resource_group_name, "dns"])
  kubernetes_version = var.kubernetes_version

  linux_profile {
    admin_username = var.vm_admin_username
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name            = "poolstandard"
    node_count      = var.aks_vm_count_ondemand
    vm_size         = var.aks_node_size
    os_sku          = "Ubuntu"
    os_disk_size_gb = 50
    vnet_subnet_id  = azurerm_subnet.subnet.id
    max_pods        = 100
    type            = "VirtualMachineScaleSets"
    # enable_auto_scaling = true
    # min_count           = 1
    # max_count           = 3
    # auto_scaling_profile {
    #   expander  =  "least-waste" 
    # }
    node_labels = {
      "pool" = "agentpool-standard"
    }
  }

  network_profile {
    network_plugin = "none"
    # network_policy     = "calico"
    # network_mode       = "transparent"
    load_balancer_sku  = "standard"
    service_cidr       = "10.0.2.0/24"
    docker_bridge_cidr = "10.1.2.0/24"
    dns_service_ip     = "10.0.2.7"
  }

  # identity {
  #   type = "UserAssigned"
  # }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  #tags = var.tags
}


resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "poolspot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8.id
  vm_size               = var.aks_node_size_spot
  node_count            = var.aks_min_node_count
  os_sku                = "Ubuntu"
  os_disk_size_gb       = var.agent_pool_os_disk_size_gb
  vnet_subnet_id        = azurerm_subnet.subnet.id
  max_pods              = 50
  enable_auto_scaling   = true
  min_count             = var.aks_min_node_count
  max_count             = var.aks_max_node_count
  priority              = "Spot"
  eviction_policy       = "Delete"
  mode                  = "User"
  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]

  node_labels = {
    "pool" = "agentpool-spot"
  }

}

resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.k8]
  filename   = "./kubeconfig"
  content    = azurerm_kubernetes_cluster.k8.kube_config_raw
}