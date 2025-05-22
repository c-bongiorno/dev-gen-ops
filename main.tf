resource "azurerm_storage_account" "example" {
 for_each = var.storage_accounts
 name                     = "testdevops"
 resource_group_name      = "rg-bongiorno-nit-001"
 location                 = "italynorth"
 account_tier             = "Standard"
 account_replication_type = "GRS"
}