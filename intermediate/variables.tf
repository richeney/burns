locals {
  images = {
    "Ubuntu18.04LTS" = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    },
    "Ubuntu20.04LTS" = {
      publisher = "canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    }
  }

  accelerated_networking = {
    "Standard_B1ms"   = false
    "Standard_B2s"    = false
    "Standard_D2s_v3" = true
    "Standard_D8s_v3" = true
  }
}

variable "resource_group_name" {
  description = "Name for the resource group."
  type        = string
  default     = "example"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "West Europe"
}

variable "set1" {
  description = "First set of servers."
  type = object({
    prefix = string
    number = number
    sku    = string
    image  = string
  })

  validation {
    condition     = contains(["Ubuntu18.04LTS", "Ubuntu20.04LTS"], var.set1.image)
    error_message = "Must be \"Ubuntu18.04LTS\" or \"Ubuntu20.04LTS\"."
  }
}

variable "set2" {
  description = "Second set of servers."
  type = object({
    prefix = string
    number = number
    sku    = string
    image  = string
  })
}

variable "admin_username" {
  description = "VM admin username."
  default     = "azureadmin"
}

variable "admin_ssh_public_key_file" {
  description = "Public key file to use."
  default     = "~/.ssh/id_rsa.pub"
}

variable "windows_server_admin_password" {
  description = "Valid password for the Windows server."
  type        = string
  default     = "ChooseSomethingSensible!"
}

variable "virtual_network_name" {
  description = "Name for the virtual network."
  type        = string
  default     = "vnet"
}

variable "address_space" {
  description = "Valid virtual network address space."
  type        = string
  default     = "172.19.76.0/25"

  validation {
    condition     = split("/", var.address_space)[1] < 26
    error_message = "The address_space value must be a valid CIDR with a subnet of at least /25."
  }
}

variable "subnet_name" {
  description = "Name of an existing subnet for the virtual machine(s)."
  type        = string
  default     = "vms"
}
