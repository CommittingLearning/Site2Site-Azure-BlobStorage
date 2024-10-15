variable "azure_subscription_id" {
    description = "The Subscription ID for the Azure account"
    type        = string
}

variable "azure_client_id" {
    description = "The Client ID (App ID) for the Azure Service Principal"
    type        = string 
}

variable "azure_tenant_id" {
    description = "The Tenant ID for the Azure account"
    type        = string
}

variable "rg_name" {
    description = "Name of the Resource Group"
    default     = "Site2Site_rg"
}

variable "location" {
    description = "Region of Deployment"
    default     = "West US"
}

variable "environment" {
    description = "The environment (e.g., development, production) to append to the VNet name"
    type        = string
}

variable "storage_account_name" {
    description = "Name of the Storage account being created"
    type        = string
    default     = "tsblobstore11" # Must be globally unique
}

variable "account_tier" {
    description = "Account tier for the Storage account being created"
    default     = "Standard"
}

variable "account_replication_type" {
    description = "Account replication type of the Storage account"
    default     = "LRS" #Locally-redundant storage
}

variable "allowed_ip" {
    description = "The public IP address allowed to access the blob storage"
    type        = string
    default     = "98.247.36.44"
}

variable "container_name" {
    description = "Name of the blob container"
    type        = string
    default     = "terraform-state"
}

variable "access_type" {
    description = "Access type for the Blob Storage containers"
    type        = string
    default     = "private"
}

variable "tls_version" {
    description = "The minimum supported TLS version for the storage account"
    type        = string
    default     = "TLS1_2"
}