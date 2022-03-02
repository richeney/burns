resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "East US 2"
}

resource "azurerm_ssh_public_key" "example" {
  resource_group_name = upper(azurerm_resource_group.example.name)
  location            = azurerm_resource_group.example.location

  name       = "ssh-public-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "azurerm_virtual_network" "example" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  name          = "example"
  address_space = ["172.19.0.0/22"]
}

resource "azurerm_subnet" "vms" {
  resource_group_name = azurerm_resource_group.example.name

  name                 = "vm_sets"
  address_prefixes     = ["172.19.0.0/23"]
  virtual_network_name = azurerm_virtual_network.example.name
}
resource "azurerm_linux_virtual_machine_scale_set" "set1" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  name           = "set1"
  sku            = "Standard_B1ms"
  instances      = 3
  admin_username = "azureadmin"

  admin_ssh_key {
    username   = "azureadmin"
    public_key = azurerm_ssh_public_key.example.public_key
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "my_nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vms.id
    }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "set2" {
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  name           = "set2"
  sku            = "Standard_B2ms"
  instances      = 2
  admin_username = "azureadmin"

  admin_ssh_key {
    username   = "azureadmin"
    public_key = azurerm_ssh_public_key.example.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "my_nic"
    primary                       = true
    enable_accelerated_networking = false

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.vms.id
    }
  }
}
