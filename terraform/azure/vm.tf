# Create virtual machines
resource "azurerm_linux_virtual_machine" "vm" {
  count = var.vm_count

  name                  = join("-", [var.resource_group_name, "vm${count.index + 1}"])
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]
  size                  = count.index == 0 ? var.vm_size_master : var.vm_size_slave

  source_image_reference {
    publisher = var.storage_image_publisher
    offer     = var.storage_image_offer
    sku       = var.storage_image_sku
    version   = var.storage_image_version
  }

  os_disk {
    name                 = join("-", [var.resource_group_name, "storage_os_disk${count.index + 1}"])
    caching              = var.storage_os_disk_caching
    storage_account_type = var.storage_os_disk_managed_disk_type
    disk_size_gb         = count.index == 0 ? var.vm_disk_size_gb_master : var.vm_disk_size_gb_slave
  }

  admin_username = var.vm_admin_username

  # encryption_at_host_enabled  = true

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = var.ssh_public_key
  }

  disable_password_authentication = true
}
