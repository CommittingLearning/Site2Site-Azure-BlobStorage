resource "azurerm_resource_group" "rg" {
    name = "${var.rg_name}_${var.environment}"
    location = var.location
}

resource "azurerm_storage_account" "storage_account" {
    name = "${var.storage_account_name}${var.environment}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = var.account_tier
    account_replication_type = var.account_replication_type

    tags = {
        environment = var.environment
    }

    network_rules {
        default_action = "Deny"
        ip_rules       = [var.allowed_ip]
        bypass         = ["AzureServices"]
    }
}

# Create the Blob Container
resource "azurerm_storage_container" "terraform_state_container" {
    name = var.container_name
    storage_account_name = azurerm_storage_account.storage_account.name
    container_access_type = var.access_type
}

# Define the Storage Management Policy (Lifecycle Policy)
resource "azurerm_storage_management_policy" "Lifecycle_policy" {
    storage_account_id = azurerm_storage_account.storage_account.id

    rule {
        name    = "delete-contents-after-1-day"
        enabled = true

        filters {
            blob_types = ["blockBlob"]
        }

        actions {
            snapshot {
                delete_after_days_since_creation_greater_than = 1 #Delete blobs after 1 day
            }
        }
    }
}