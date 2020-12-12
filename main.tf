terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 2.40"
    }
  }
}

provider "azurerm" {
  features {}
}
