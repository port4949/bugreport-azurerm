provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

variable "name" {
  type    = string
  default = "bugreport"
}

# Create a resource group
resource "azurerm_resource_group" "rg-bugreport" {
  name     = "rg-${var.name}"
  location = "westeurope"
}

# Create a service plan
resource "azurerm_app_service_plan" "plan-bugreport" {
  name                = "plan-${var.name}"
  location            = azurerm_resource_group.rg-bugreport.location
  resource_group_name = azurerm_resource_group.rg-bugreport.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"

  }
}

resource "azurerm_key_vault" "kv-bugreport" {
  name                = "kv-${var.name}"
  location            = azurerm_resource_group.rg-bugreport.location
  resource_group_name = azurerm_resource_group.rg-bugreport.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

}

resource "azurerm_key_vault_access_policy" "policy-bugreport" {
  key_vault_id = azurerm_key_vault.kv-bugreport.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}

resource "azurerm_key_vault_secret" "secret-bugreport" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.kv-bugreport.id
}

resource "azurerm_app_service" "app-bugreport" {
  name                = "app-${var.name}"
  location            = azurerm_resource_group.rg-bugreport.location
  resource_group_name = azurerm_resource_group.rg-bugreport.name
  app_service_plan_id = azurerm_app_service_plan.plan-bugreport.id
  https_only          = true

  site_config {
    linux_fx_version          = "DOCKER|docker.io/nginx:1.21"
    use_32_bit_worker_process = true
  }

/*
  identity {
    type = "SystemAssigned"
  }
*/

  app_settings = {
    NORMAL            = "This is not a secret",
    MY_SECRET_SETTING = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv-bugreport.name};SecretName=secret-sauce)"
  }
}

/*
resource "azurerm_key_vault_access_policy" "policy-bugreport-app" {
  key_vault_id = azurerm_key_vault.kv-bugreport.id
  tenant_id    = azurerm_app_service.app-bugreport.identity[0].tenant_id
  object_id    = azurerm_app_service.app-bugreport.identity[0].principal_id

  secret_permissions = [
    "Get",
  ]
}
*/
