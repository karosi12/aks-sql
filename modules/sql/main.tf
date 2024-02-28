resource "azurerm_resource_group" "sql_rg" {
  name     = var.resource_group_name
  location = var.resource_group_location 
}

resource "azurerm_virtual_network" "sql_vnet" {
  name                = var.virtual_network_name 
  address_space       = [var.virtual_network_address_space]
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.sql_rg.name
  virtual_network_name = azurerm_virtual_network.sql_vnet.name
  address_prefixes     = [var.subnet_address]
  service_endpoints = [ "Microsoft.Sql" ]
}

resource "azurerm_mysql_server" "sql_server" {
  name                = var.sql_server_name
  location            = azurerm_resource_group.sql_rg.location
  resource_group_name = azurerm_resource_group.sql_rg.name
  sku_name            = "GP_Gen5_2"

  storage_mb = 5120

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  version = "5.7"

  public_network_access_enabled     = true
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  ssl_enforcement_enabled    = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_mysql_firewall_rule" "sql_firewall_rule" {
  name                = var.sql_firewall_rule_name
  resource_group_name = azurerm_resource_group.sql_rg.name
  server_name         = azurerm_mysql_server.sql_server.name
  start_ip_address    = var.start_ip_address
  end_ip_address      = var.end_ip_address
}

resource "azurerm_mysql_configuration" "sql_configuration" {
  name                = "max_connections"
  resource_group_name = azurerm_resource_group.sql_rg.name
  server_name         = azurerm_mysql_server.sql_server.name
  value               = "100"
}

resource "azurerm_mysql_virtual_network_rule" "sql_vnet_rule" {
  name                = "dbVNetRule"
  resource_group_name = azurerm_resource_group.sql_rg.name
  server_name         = azurerm_mysql_server.sql_server.name
  subnet_id           = azurerm_subnet.sql_subnet.id
  depends_on = [ azurerm_subnet.sql_subnet ]
}