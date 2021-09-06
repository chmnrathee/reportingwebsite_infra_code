# Configuratipon details

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.31.1"
    }
  }
}

provider "azurerm" {
  features {}
}

### Variables -----------------------------------------------------------------

#AppService
variable "app_service_plan_name" {
  type        = string
  description = "Name of App Service Plan"
  default     = "reportinwebitePlan"
}

variable "web_app_name" {
  type        = string
  description = "Name of Web App"
  default     = "reportingwebsite"
}

#PostgreDB
variable "postgresql-admin-user" {
  type        = string
  description = "Login Username"
  default     = "Samplechaman"
}
variable "postgresql-admin-password" {
  type        = string
  description = "Login Password"
  default     = "SamplePass"
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

#ContainerRegistry
variable "registry-name" {
  type        = string
  description = "Registry Name"
  default     = "test_registry"
}

variable "sku_tier" {
  type        = string
  description = "SKU Tier"
  default     = "Standard"
}

variable "sku_size" {
  type        = string
  description = "SKU Size"
  default     = "S1"
}

### Resource Group Creation ------------------------------------------------------------

resource "azurerm_resource_group" "webservice-rg" {
  name     = "reporting-webservice-rg"
  location = "eastus"
  tags = {
    environment = "prod"
    source      = "terraform"
  }
}

### Resources -----------------------------------------------------------------

### App Service Plan 
resource "azurerm_app_service_plan" "app_svc_plan" {
  name                = var.app_service_plan_name
  location            = "eastus"
  resource_group_name = azurerm_resource_group.webservice-rg.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

### App Service 
resource "azurerm_app_service" "web_app" {
  name                = var.web_app_name
  location            = "eastus"
  resource_group_name = azurerm_resource_group.webservice-rg.name
  app_service_plan_id = azurerm_app_service_plan.app_svc_plan.id

  app_settings = {
    "DeviceName" = "SampleDevice",
    "DeviceId"   = "2"
  }
}

### PostgreSQL 

### Server --------------
resource "azurerm_postgresql_server" "postgresql-server" {
  name                = "reportingweb-postgresql-server"
  location            = azurerm_resource_group.webservice-rg.location
  resource_group_name = azurerm_resource_group.webservice-rg.name

  administrator_login          = var.postgresql-admin-user
  administrator_login_password = var.postgresql-admin-password

  sku_name = var.postgresql-sku-name
  version  = var.postgresql-version

  storage_mb        = var.postgresql-storage
  auto_grow_enabled = true

  backup_retention_days            = 7
  geo_redundant_backup_enabled     = false
  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

### PostgreSQL DB  --------------
resource "azurerm_postgresql_database" "postgresql-db" {
  name                = "reportingwebdb"
  resource_group_name = azurerm_resource_group.webservice-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  charset             = "utf8"
  collation           = "English_United States.1252"
}

### FireWall Configuration  --------------

resource "azurerm_postgresql_firewall_rule" "postgresql-fw-rule" {
  name                = "PostgreSQL_Access"
  resource_group_name = azurerm_resource_group.webservice-rg.name
  server_name         = azurerm_postgresql_server.postgresql-server.name
  start_ip_address    = "103.55.105.72"
  end_ip_address      = "103.55.105.72"
}

### Container_Registry Resources ------------------
resource "azurerm_container_registry" "acr" {
  name                = var.registry-name
  resource_group_name = azurerm_resource_group.webservice-rg.name
  location            = azurerm_resource_group.webservice-rg.location
  sku                 = var.sku_tier
  admin_enabled       = true

}

### Outputs -------------------------------------------------------------------

output "app_service" {
  value = azurerm_app_service.web_app
}

output "postgresql_server" {
  value = azurerm_postgresql_server.postgresql-server
}

output "admin_password" {
  value = azurerm_container_registry.acr.name
}