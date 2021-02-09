// Landing Zone: SUBSCRIPTIONDISPLAYNAME
// (name when subscription was created)

/*
  This is an example landing zone Terraform template that is copied by the subscription vending machine.
  The words in CAPS are replaced by the pipeline, based on the input parameters.
  A PR is created on main branch to start the LZ deployment workflow.
*/

provider "azurerm" {
  features {}
  alias           = "lz-SUBSCRIPTIONID"
  subscription_id = "SUBSCRIPTIONID"
}

resource "azurerm_resource_group" "lz_SUBSCRIPTIONID" {
  provider = azurerm.lz-SUBSCRIPTIONID
  name     = "networking"
  location = "REGION"
}

resource "azurerm_virtual_network" "lz_SUBSCRIPTIONID" {
  provider            = azurerm.lz-SUBSCRIPTIONID
  name                = "lznet"
  address_space       = ["VNETADDRESSSPACE"]
  location            = azurerm_resource_group.lz_SUBSCRIPTIONID.location
  resource_group_name = azurerm_resource_group.lz_SUBSCRIPTIONID.name
}

resource "azurerm_subnet" "lz_SUBSCRIPTIONID_0" {
  provider             = azurerm.lz-SUBSCRIPTIONID
  name                 = "subnet0"
  resource_group_name  = azurerm_resource_group.lz_SUBSCRIPTIONID.name
  virtual_network_name = azurerm_virtual_network.lz_SUBSCRIPTIONID.name
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.lz_SUBSCRIPTIONID.address_space[0], 2, 0)
  ]
}

resource "azurerm_virtual_hub_connection" "lz_SUBSCRIPTIONID" {
  name                      = "lz-SUBSCRIPTIONID"
  virtual_hub_id            = azurerm_virtual_hub.REGION_WORKLOADENVIRONMENT.id
  remote_virtual_network_id = azurerm_virtual_network.lz_SUBSCRIPTIONID.id
}
