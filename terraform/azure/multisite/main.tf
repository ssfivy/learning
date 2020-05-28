# Create two virtual machines in two different location with one public IP each.

############ Configuration ############

# Configure the Azure provider
provider "azurerm" {
  version = "~>1.44.0"
}

# No variables in terraform backend entries: https://github.com/hashicorp/terraform/issues/13022
# which means no variables in most places here too

# Probably not good practice to commit these in the open....

# Configure terraform backend, auth using azure CLI
# The actual storage resources are setup in remotestate/main.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "FZ-tfstate"
    storage_account_name = "fz079429763storactfst"
    container_name       = "terraform-state"
    key                  = "multisite.terraform.tfstate"
  }
}


############ Infrastructure ############

# Create a new resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}FZ"
  location = "australiaeast"
  tags     = var.tags
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  for_each = var.location
  name                = "${var.prefix}TFVnet-${each.key}"
  address_space       = ["10.0.0.0/16"]
  location            = each.value
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  for_each = var.location
  name                 = "${var.prefix}TFSubnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefix       = "10.0.1.0/24"
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  for_each = var.location
  name                = "${var.prefix}TFPublicIP-${each.key}"
  location            = each.value
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags                = var.tags
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsg" {
  for_each = var.location
  name                = "${var.prefix}TFNSG-${each.key}"
  location            = each.value
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

# Create rules for Network Security Group
# They cannot be reused across network security groups though, booo:
# https://github.com/hashicorp/terraform/issues/13254
resource "azurerm_network_security_rule" "ssh"{
  for_each = var.location
  name                       = "SSH"
  priority                   = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
}

resource "azurerm_network_security_rule" "https"{
  for_each = var.location
  name                       = "https"
  priority                   = 1002
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "443"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
}

resource "azurerm_network_security_rule" "mqtt-tls"{
  for_each = var.location
  name                       = "mqtt-tls"
  priority                   = 1003
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "8883"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg[each.key].name
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  for_each = var.location
  name                      = "${var.prefix}NIC-${each.key}"
  location                  = each.value
  resource_group_name       = azurerm_resource_group.rg.name
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  tags                      = var.tags

  ip_configuration {
    name                          = "${var.prefix}NICConfg-${each.key}"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[each.key].id
  }
}

# Create OS disk separately from VM
# otherwise terraform will barf when it tries tor ecreate VM since disk already existed
# Issue: https://github.com/terraform-providers/terraform-provider-azurerm/issues/243
# Workaround: https://github.com/terraform-providers/terraform-provider-azurerm/issues/734#issuecomment-367672275
# image_reference_id is needed but those IDs have my subscription Ids in them so nah
#resource "azurerm_managed_disk" "osdisk" {
#  for_each = var.location
#  name                  = "${var.prefix}MDOsDisk-${each.key}"
#  location              = each.value
#  resource_group_name   = azurerm_resource_group.rg.name
#  create_option         = "FromImage"
#  storage_account_type  = "Standard_LRS"
#  image_reference_id    = "Canonical:UbuntuServer:18.04-LTS:latest"
#}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm" {
  for_each = var.location
  name                  = "${var.prefix}TFVM-${each.key}"
  location              = each.value
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  vm_size               = "Standard_B1ls" # 0.5GB RAM 1vCPU
  #vm_size               = "Standard_B1s" # 1GB RAM 1vCPU
  tags                  = var.tags

  delete_os_disk_on_termination = false
  storage_os_disk {
    name                = "${var.prefix}VMOsDisk-${each.key}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    #create_option       = "attach"
    #managed_disk_id     = azurerm_managed_disk.osdisk[each.key].id
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "${var.prefix}TFVM-${each.key}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    connection {
      host     = azurerm_public_ip.publicip[each.key].ip_address
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
    }

    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y ",
      "sudo apt-get install -y tree vim mosquitto"
    ]
  }
}

data "azurerm_public_ip" "ip" {
  for_each = var.location
  name                = azurerm_public_ip.publicip[each.key].name
  resource_group_name = azurerm_virtual_machine.vm[each.key].resource_group_name
}
