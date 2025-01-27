resource "azurerm_kubernetes_cluster" "managed_clusters_cluster" {
  name                = "${var.test_prefix}-${var.test_suffix}-aks"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "${var.test_prefix}${var.test_suffix}"

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    max_count           = 2
    node_count          = 2
    min_count           = 2
    vm_size             = "Standard_B2s"
    node_labels         = { "node-type" = "system" }
    vnet_subnet_id      = azurerm_subnet.internal.id
    tags = {
      test = "test"
    }
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "172.17.0.0/16"
    dns_service_ip     = "172.17.0.12"
    docker_bridge_cidr = "172.18.0.12/16"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    test = "test"
  }
}

resource "azurerm_container_registry" "managed_clusters_registry" {
  name                = "${var.test_suffix}reg"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Standard"
  admin_enabled       = false
}

# Allows Kubernetes to Pull ACR images
resource "azurerm_role_assignment" "managed_clusters_role_acr" {
  scope                = azurerm_container_registry.managed_clusters_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.managed_clusters_cluster.kubelet_identity[0].object_id
}

# Creates An Identity to Pod
resource "azurerm_user_assigned_identity" "managed_clusters_pod_identity_queue_contributor" {
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  name                = "${var.test_prefix}${var.test_suffix}queuecontributoraksidentity"
}

# Allows Kubernetes to Manage Identity Created on AKS Nodes
resource "azurerm_role_assignment" "managed_clusters_identity_operator" {
  scope                = azurerm_user_assigned_identity.managed_clusters_pod_identity_queue_contributor.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.managed_clusters_cluster.kubelet_identity[0].object_id
}

# Allows Kubernetes to Manage VMs on AKS Nodes
resource "azurerm_role_assignment" "managed_clusters_vm_contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourcegroups/${azurerm_kubernetes_cluster.managed_clusters_cluster.node_resource_group}"
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.managed_clusters_cluster.kubelet_identity[0].object_id
}
