terraform {
  required_version = ">1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "rg-bongiorno-nit-001"
      storage_account_name = "tfstatedevops01"
      container_name       = "tfstatedevgenops"
      key                  = "terraform.tfstate"
      use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}
