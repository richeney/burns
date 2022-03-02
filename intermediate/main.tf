data "azurerm_client_config" "current" {}

locals {
  vm_subnet_address_prefix = cidrsubnet(var.address_space, 26 - split("/", var.address_space)[1], 0)
  uniq                     = substr(md5(azurerm_resource_group.example.id), 0, 8)
}

// Resource group and virtual network

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = [var.address_space]
}

resource "azurerm_subnet" "vms" {
  name                 = var.subnet_name
  address_prefixes     = [local.vm_subnet_address_prefix]
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.example.name
}

// Virtual Machines

module "set1_vm_example" {
  source     = "./modules/linux"
  depends_on = [azurerm_subnet.vms]

  for_each = toset([
    for suffix in range(var.set1.number) : format("%s-%02d", var.set1["prefix"], suffix)
  ])

  name                = each.value
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  subnet_id                 = azurerm_subnet.vms.id
  image                     = local.images[var.set1.image]
  size                      = var.set1["sku"]
  admin_username            = var.admin_username
  admin_ssh_public_key_file = var.admin_ssh_public_key_file
}

resource "azurerm_linux_virtual_machine_scale_set" "set2_vmss_example" {
  name                = var.set2["prefix"]
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = var.set2["sku"]
  instances           = var.set2["number"]
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.admin_ssh_public_key_file)
  }

  source_image_reference {
    publisher = local.images[var.set2.image].publisher
    offer     = local.images[var.set2.image].offer
    sku       = local.images[var.set2.image].sku
    version   = local.images[var.set2.image].version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "my_nic"
    primary                       = true
    enable_accelerated_networking = lookup(local.accelerated_networking, var.set2.sku, false)

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vms.id
    }
  }
}
