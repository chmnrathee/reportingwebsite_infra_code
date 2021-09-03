
### Variables -----------------------------------------------------------------

variable "app_service_plan_name" {
  type        = string
  description = "Name of App Service Plan"
  default = "reportinwebitePlan"
}

variable "web_app_name" {
  type        = string
  description = "Name of Web App"
  default = "reportingwebsite"
}

### Resource Group Creation ------------------------------------------------------------

resource "azurerm_resource_group" "appservice-rg" {    
  name = "reportingweb-appservice-rg"
  location = "eastus"    
}   

### Resources -----------------------------------------------------------------
### App Service Plan 
resource "azurerm_app_service_plan" "app_svc_plan" {  
  name                = var.app_service_plan_name
  location            = "eastus"  
  resource_group_name = azurerm_resource_group.appservice-rg.name  
  
  sku {  
    tier = "Standard"  
    size = "S1"
  }  
}  

### App Service 
resource "azurerm_app_service" "web_app" {  
  name                = var.web_app_name 
  location            = "eastus"  
  resource_group_name = azurerm_resource_group.appservice-rg.name  
  app_service_plan_id = azurerm_app_service_plan.app_svc_plan.id  
  
  app_settings = {  
    "DeviceName" = "SampleDevice",  
    "DeviceId" = "2"  
  }  
}  

### Outputs -------------------------------------------------------------------

output "app_service" {
  value = azurerm_app_service.web_app
}