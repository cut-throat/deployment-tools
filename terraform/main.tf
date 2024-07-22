resource "azurerm_resource_group" "unir-CP2" {
  name     = var.resource_group_name
  location = var.location

}
resource "azurerm_virtual_network" "vnet_unir-CP2" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["172.16.0.0/22"]
  depends_on = [
    azurerm_resource_group.unir-CP2
  ]

}
resource "azurerm_subnet" "subnet_unir-CP2" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefix
  depends_on = [
    azurerm_virtual_network.vnet_unir-CP2
  ]
}

resource "azurerm_container_registry" "acr_unir-CP2" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
  depends_on = [
    azurerm_resource_group.unir-CP2
  ]
}


resource "azurerm_network_interface" "network_interface_unir-CP2" {
  name                = var.network_interface_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "name_ip_conf"
    subnet_id                     = azurerm_subnet.subnet_unir-CP2.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm-unir-CP2" {
  name                  = var.virtual_machine_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.network_interface_unir-CP2.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

# Create AKS cluster

resource "azurerm_kubernetes_cluster" "aks_unir-cp2" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  private_cluster_enabled   = false
  dns_prefix                = var.cluster_name
  automatic_channel_upgrade = "patch"
  depends_on = [
    azurerm_subnet.subnet_unir-CP2
  ]


  default_node_pool {
    name                         = "agentpool"
    node_count                   = 1
    vm_size                      = "Standard_B2s"
    zones                        = ["1"]
    enable_auto_scaling          = false
    enable_node_public_ip        = false
    max_pods                     = 70
    only_critical_addons_enabled = false
    orchestrator_version         = var.kubernetes_version
    type                         = "VirtualMachineScaleSets"
    scale_down_mode              = "Delete"
    os_sku                       = "AzureLinux"
    os_disk_type                 = "Managed"
    temporary_name_for_rotation  = "tempagent"
    vnet_subnet_id               = azurerm_subnet.subnet_unir-CP2.id
    upgrade_settings {
      max_surge = "1"
    }
  }

  sku_tier = "Free"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    create_before_destroy = true
  }

  http_application_routing_enabled = false

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 24

  kubernetes_version = var.kubernetes_version

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "calico"
    outbound_type     = "loadBalancer"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"

    load_balancer_profile {
      idle_timeout_in_minutes = 4
    }
  }

  azure_policy_enabled = false

  role_based_access_control_enabled = true

  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    disk_driver_version         = "v1"
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
}

