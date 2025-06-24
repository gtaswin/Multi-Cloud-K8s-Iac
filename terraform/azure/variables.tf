variable "subscription_id" {
  type        = string
  description = "The subscription ID for the Azure account"
  default     = ""
}

variable "client_id" {
  type        = string
  description = "The client ID of the Azure service principal"
  default     = ""
}

variable "client_secret" {
  type        = string
  description = "The client secret of the Azure service principal"
  default     = ""
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID of the Azure service principal"
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = ""
}

variable "location" {
  type        = string
  description = "The location of the resource group"
  default     = "eastus"
}

variable "vm_admin_username" {
  type        = string
  description = "The username for the virtual machine administrator"
  default     = "gta"
}

variable "vm_admin_password" {
  type        = string
  description = "The password for the virtual machine administrator"
  default     = "gta"
}

variable "vm_count" {
  type        = number
  description = "The number of virtual machines to create"
  default     = 3
}

variable "aks_vm_count_ondemand" {
  type        = number
  description = "The number of Kubernetes worker virtual machines to create ondemand"
  default     = 1
}

variable "vm_size_master" {
  type        = string
  description = "The size of the virtual machines"
  default     = "Standard_D16as_v5"
}

variable "vm_size_slave" {
  type        = string
  description = "The size of the virtual machines"
  default     = "Standard_D16as_v5"
}

variable "storage_image_publisher" {
  type    = string
  default = "OpenLogic"
}

variable "storage_image_offer" {
  type    = string
  default = "CentOS"
}

variable "storage_image_sku" {
  type    = string
  default = "7.7"
}

variable "storage_image_version" {
  type    = string
  default = "latest"
}

variable "storage_os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "storage_os_disk_managed_disk_type" {
  type    = string
  default = "Standard_LRS"
}

variable "vm_disk_size_gb_master" {
  type    = number
  default = 50
}

variable "vm_disk_size_gb_slave" {
  type    = number
  default = 100
}

variable "ssh_public_key" {
  description = "The public SSH key to use for SSH authentication."
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCkXXVfyuSZMq2ATR9m4hSJiRLXRU4xKrz7f4qTRs5m9lovZoh9UTsetm2AJEmLSbl+Zqcq8QR2Ium6jI79aeobiE5LY73Y1sOPJJC/eN/RWJW+TMUBi3kKzCXeFGJoqBTdUufWTrWkveY36WbD245BKbEuRdefq8Db27WO0yfW3Rct3fbpKxHqXWbx400l1q82CuvpeWYDRM4GcKOmPw4vhJMfw2tyj1yDnx70DYiRgoWaXk7/f6v1mqQlu8Q2OQZp+g3DLP5koOrS2NVTNznEqgWnwVutOpPy7G7Z45VK+UrOooExrLGFiFMd1Okkc1Nd+euWs0ILGo21SXSBrm/J gta@hades"
}

variable "aks_node_size" {
  type        = string
  description = "The size of the AKS nodes"
  default     = "Standard_D16as_v5"
}

variable "aks_node_size_spot" {
  type        = string
  description = "The size of the AKS nodes"
  default     = "Standard_A4_v2"
}

variable "agent_pool_os_disk_size_gb" {
  type    = number
  default = 30
}

variable "aks_max_node_count" {
  type        = number
  description = "The maximum number of AKS nodes"
  default     = 5
}

variable "aks_min_node_count" {
  type        = number
  description = "The minimum number of AKS nodes"
  default     = 0
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  default     = "1.27"
}
