terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


module "myapp-aks" {
  source                        = "./modules/aks"
  resource_group_location       = var.resource_group_location
  resource_group_name           = var.resource_group_name
  aks_cluster_name              = var.aks_cluster_name
  aks_cluster_dns_prefix        = var.aks_cluster_dns_prefix
  client_id                     = var.client_id
  client_secret                 = var.client_secret
  virtual_network_name          = var.virtual_network_name
  virtual_network_address_space = var.virtual_network_address_space
  subnet_name                   = var.subnet_name
  subnet_address                = var.subnet_address
  environment                   = var.environment
}

module "myapp-sqldb" {
  source                        = "./modules/sql"
  resource_group_location       = var.resource_group_location
  resource_group_name           = var.resource_group_name
  virtual_network_name          = "sql${var.sql_virtual_network_name}"
  virtual_network_address_space = var.virtual_network_address_space
  subnet_name                   = "sql${var.sql_subnet_name}"
  subnet_address                = var.subnet_address
  environment                   = var.environment
  administrator_login_password  = var.administrator_login_password
  administrator_login           = var.administrator_login
  sql_firewall_rule_name        = var.sql_firewall_rule_name
  start_ip_address              = var.start_ip_address
  end_ip_address                = var.end_ip_address
  sql_server_name               = var.sql_server_name
}