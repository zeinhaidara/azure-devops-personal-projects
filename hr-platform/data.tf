data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "documents" {
  name                            = var.storage_account_name
  resource_group_name             = data.azurerm_resource_group.existing.name
  location                        = data.azurerm_resource_group.existing.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
}

resource "azapi_resource" "documents_container" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01"
  name      = var.storage_container_name
  parent_id = "${azurerm_storage_account.documents.id}/blobServices/default"

  body = {
    properties = {
      publicAccess = "None"
    }
  }
}

resource "azurerm_private_endpoint" "storage" {
  name                = "${var.storage_account_name}-pe"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.storage_account_name}-connection"
    private_connection_resource_id = azurerm_storage_account.documents.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.storage_account_name}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
  }
}

resource "azurerm_cosmosdb_account" "hr" {
  name                          = var.cosmos_account_name
  resource_group_name           = data.azurerm_resource_group.existing.name
  location                      = data.azurerm_resource_group.existing.location
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  public_network_access_enabled = false

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = data.azurerm_resource_group.existing.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "hr" {
  name                = var.cosmos_database_name
  resource_group_name = data.azurerm_resource_group.existing.name
  account_name        = azurerm_cosmosdb_account.hr.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "documents" {
  name                = var.cosmos_container_name
  resource_group_name = data.azurerm_resource_group.existing.name
  account_name        = azurerm_cosmosdb_account.hr.name
  database_name       = azurerm_cosmosdb_sql_database.hr.name
  partition_key_paths = ["/id"]
}

resource "azurerm_private_endpoint" "cosmos" {
  name                = "${var.cosmos_account_name}-pe"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.cosmos_account_name}-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.hr.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.cosmos_account_name}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmos.id]
  }
}

resource "azurerm_key_vault" "hr" {
  name                          = var.key_vault_name
  resource_group_name           = data.azurerm_resource_group.existing.name
  location                      = data.azurerm_resource_group.existing.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  rbac_authorization_enabled    = true
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "${var.key_vault_name}-pe"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "${var.key_vault_name}-connection"
    private_connection_resource_id = azurerm_key_vault.hr.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.key_vault_name}-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
  }
}

resource "azapi_resource" "cosmos_key_secret" {
  type      = "Microsoft.KeyVault/vaults/secrets@2023-07-01"
  name      = "${var.cosmos_account_name}-key"
  parent_id = azurerm_key_vault.hr.id

  body = {
    properties = {
      value = sensitive(azurerm_cosmosdb_account.hr.primary_key)
    }
  }
}
