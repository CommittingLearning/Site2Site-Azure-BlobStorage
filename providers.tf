provider "azurerm" {
    features {}

    subscription_id = var.azure_subscription_id
    client_id       = var.azure_client_id
    tenant_id       = var.azure_tenant_id
}

terraform {
    backend "azurerm" {
        storage_account_name = azurerm_storage_account.storage_account.name
        container_name       = azurerm_storage_container.terraform_state_container.name
        key                  = "blobstorage.tfstate"
        resource_group_name  = azurerm_resource_group.rg.name
    }
}