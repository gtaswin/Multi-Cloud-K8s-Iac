# Configure the Azure provider

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create network interfaces for virtual machines
resource "azurerm_network_interface" "vm_nic" {
  count = var.vm_count

  name                = join("-", [var.resource_group_name, "vm_nic${count.index + 1}"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.${count.index + 100}"
    public_ip_address_id          = count.index == 0 ? azurerm_public_ip.public_ip.id : null
  }
}

# Create a subnet for virtual machines
resource "azurerm_subnet" "subnet" {
  name                 = join("-", [var.resource_group_name, "vm-subnet"])
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a virtual network for virtual machines
resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [var.resource_group_name, "vmvnet"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create a public IP for the first VM
resource "azurerm_public_ip" "public_ip" {
  name                = join("-", [var.resource_group_name, "vm1-pip"])
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Security Group
resource "azurerm_network_security_group" "ssh" {
  name                = "ssh"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "22"
    destination_address_prefix = azurerm_network_interface.vm_nic[0].private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.vm_nic[0].id
  network_security_group_id = azurerm_network_security_group.ssh.id
}