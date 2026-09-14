terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "Moulaye-Haidara-8.18-RG"
    storage_account_name = "hrlabzein"
    container_name       = "tfstate"
    key                  = "bighrapp.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
