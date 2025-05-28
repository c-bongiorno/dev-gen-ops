resource "azurerm_storage_account" "sa" {
  name                          = "sastestdevops001"
  resource_group_name           = "rg-bongiorno-nit-001"
  location                      = "italynorth"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  https_traffic_only_enabled    = false
}


resource "azurerm_storage_account" "test-ai" {
  name                          = "sastestdevops002"
  resource_group_name           = "rg-bongiorno-nit-001"
  location                      = "italynorth"
  account_tier                  = "TEST"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  https_traffic_only_enabled    = false
}
