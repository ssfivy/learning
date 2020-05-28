
# Create resources for storing our terraform states
#
# Probably not good practice to commit these in the open....

# Configure the Azure provider
provider "azurerm" {
  version = "~>1.44.0"
}

resource "azurerm_resource_group" "rgstate" {
  name     = "FZ-tfstate"
  location = "australiaeast"
}

# Set up azurerm storage account for storing terraform state
resource "azurerm_storage_account" "storageac_tfstate" {
  name                     = "fz079429763storactfst"
  resource_group_name      = azurerm_resource_group.rgstate.name
  location                 = azurerm_resource_group.rgstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Configure storage container
resource "azurerm_storage_container" "storagecnt_tfstate" {
  name                     = "terraform-state"
  storage_account_name  = azurerm_storage_account.storageac_tfstate.name
  container_access_type = "private" # Don't expose this to the world!
}

# This is added after all the above storage resources are created
# Accessed through Azure CLi
terraform {
  backend "azurerm" {
    resource_group_name  = "FZ-tfstate"
    storage_account_name = "fz079429763storactfst"
    container_name       = "terraform-state"
    key                  = "remotestate.terraform.tfstate"
  }
}
