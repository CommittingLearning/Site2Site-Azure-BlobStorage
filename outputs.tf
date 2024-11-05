output "resource_group_name" {
    description = "The name of the resource group"
    value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
    description = "the name of the storage acount"
    value       = azurerm_storage_account.storage_account.name 
}

output "container_name" {
    description = "The name of the blob container"
    value       = azurerm_storage_container.terraform_state_container.name
}