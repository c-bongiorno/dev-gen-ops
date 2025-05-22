resource "azurerm_storage_account" "sa" {
 name                     = "testdevops"
 resource_group_name      = "rg-bongiorno-nit-001"
 location                 = "italynorth"
 account_tier             = "Standard"
 account_replication_type = "GRS"
}