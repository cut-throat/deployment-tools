variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type    = string
  default = "rg_unir-CP2"
}
variable "location" {
  description = "localizacion entorno azure"
  type    = string
  default = "NorthEurope"
}
variable "vnet_name" {
  description = "nombre del vnet para unircp2"
  type    = string
  default = "vnet_unir-CP2"
}
variable "subnet_name" {
  description = "Nombre subnet unbircp2"
  type    = string
  default = "subnet_unir-CP2"
}

variable "acr_name" {
  description = "Container Registry Azure"
  type    = string
  default = "acrunirCP2"
}

variable "network_interface_name" {
  description = "Interface de red Unir"
  type    = string
  default = "network_interface_unir-CP2"
}

variable "virtual_machine_name" {
  description = "VM Unir"
  type    = string
  default = "vmunircp"
}

variable "cluster_name" {
  description = "Nombre del grupo de recursos"
  type    = string
  default = "aksunircp2"
}
variable "kubernetes_version" {
  description = "Nombre del grupo de recursos"
  type    = string
  default = "1.29.2"
}

variable "subnet_address_prefix" {
  description = "Nombre del grupo de recursos"
  type    = list(string)
  default = ["172.16.0.0/22"]
}

