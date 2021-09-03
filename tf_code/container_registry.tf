### Variables -----------------------------------------------------------------

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
    type    = string
    description = "SKU Size"
    default     = "S1"
}

### Resource Group Creation ------------------

resource "azurerm_resource_group" "container-rg" {
  name     = "reportingweb-containerreg-rg"
  location = "westus"
}

### Resources ------------------

resource "azurerm_container_registry" "acr" {
  name                     = var.registry-name
  resource_group_name      = azurerm_resource_group.container-rg.name
  location                 = azurerm_resource_group.container-rg.location
  sku                      = var.sku_tier
  admin_enabled            = true

}

### Outputs ------------------

output "admin_password" {
  value       = azurerm_container_registry.acr.name
}