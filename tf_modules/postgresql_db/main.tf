
### Variables -----------------------------------------------------------------

variable "postgresql-admin-user" {
  type        = string
  description = "Login Username"
}
variable "postgresql-admin-password" {
  type        = string
  description = "Login Password"
}
variable "postgresql-version" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "11"
}
variable "postgresql-sku-name" {
  type        = string
  description = "PostgreSQL SKU Name"
  default     = "B_Gen5_1"
}
variable "postgresql-storage" {
  type        = string
  description = "PostgreSQL Storage in MB"
  default     = "5120"
}

### Resource Group Creation ------------------------------------------------------------

resource "azurerm_resource_group" "postgresql-rg" {
  name     = "reportingweb-postgresql-rg"
  location = "North Europe"
}

### Resources -----------------------------------------------------------------
### PostgreSQL server --------------

resource "azurerm_postgresql_server" "postgresql-server" {
  name = "reportingweb-postgresql-server"
  location = azurerm_resource_group.postgresql-rg.location
  resource_group_name = azurerm_resource_group.postgresql-rg.name
 
  administrator_login          = var.postgresql-admin-user
  administrator_login_password = var.postgresql-admin-password
 
  sku_name = var.postgresql-sku-name
  version  = var.postgresql-version
 
  storage_mb        = var.postgresql-storage
  auto_grow_enabled = true
  
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

### PostgreSQL database  --------------

resource "azurerm_postgresql_database" "postgresql-db" {
  name                = "reportingwebdb"
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "utf8"
  collation           = "English_United States.1252"
}

### FireWall Configuration  --------------

resource "azurerm_postgresql_firewall_rule" "postgresql-fw-rule" {
  name                = "PostgreSQL Office Access"
  resource_group_name = azurerm_resource_group.postgresql-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  start_ip_address    = "103.55.105.72"
  end_ip_address      = "103.55.105.72"
}

### Outputs -------------------------------------------------------------------

output "postgresql_server" {
  value = azurerm_postgresql_server.postgresql-server
}