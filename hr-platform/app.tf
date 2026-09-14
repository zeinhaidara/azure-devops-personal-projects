resource "azurerm_service_plan" "hr" {
  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "hr" {
  name                      = var.webapp_name_prefix
  resource_group_name       = data.azurerm_resource_group.existing.name
  location                  = data.azurerm_resource_group.existing.location
  service_plan_id           = azurerm_service_plan.hr.id
  virtual_network_subnet_id = azurerm_subnet.app.id
  https_only                = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "DOCUMENTS_STORAGE_ENDPOINT" = azurerm_storage_account.documents.primary_blob_endpoint
    "COSMOS_ENDPOINT"            = azurerm_cosmosdb_account.hr.endpoint
    "COSMOS_KEY"                 = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.hr.vault_uri}secrets/${var.cosmos_account_name}-key)"
  }

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_role_assignment" "webapp_blob_reader" {
  scope                = azurerm_storage_account.documents.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_linux_web_app.hr.identity[0].principal_id
}

resource "azurerm_role_assignment" "webapp_key_vault_secrets_user" {
  scope                = azurerm_key_vault.hr.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_web_app.hr.identity[0].principal_id
}
