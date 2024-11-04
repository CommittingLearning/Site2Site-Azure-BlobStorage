# Azure Storage Account for Terraform State Management with CI/CD Pipeline

This repository contains Terraform configuration files for deploying an Azure Storage Account and Blob Container used for storing Terraform state files. It includes a GitHub Actions CI/CD pipeline for automated deployment, validation, and security checks.

## Table of Contents

- [Introduction](#introduction)
- [Terraform Configuration](#terraform-configuration)
  - [Resources Created](#resources-created)
  - [Variables](#variables)
  - [Outputs](#outputs)
- [CI/CD Pipeline](#cicd-pipeline)
  - [Workflow Triggers](#workflow-triggers)
  - [Pipeline Overview](#pipeline-overview)
  - [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Usage](#usage)
  - [Clone the Repository](#clone-the-repository)
  - [Set Up Azure Credentials](#set-up-azure-credentials)
  - [Configure the Terraform Backend](#configure-the-terraform-backend)
  - [Branch Strategy](#branch-strategy)
  - [Manual Approval](#manual-approval)
- [Notes](#notes)

## Introduction

This project automates the deployment of an Azure Storage Account and Blob Container specifically configured for storing Terraform state files. The storage account includes a lifecycle management policy to automatically delete blob snapshots after one day, helping to manage storage costs and maintain compliance.

The GitHub Actions CI/CD pipeline automates validation, security scanning, and deployment processes.

The CI/CD pipeline is designed to:

- Validate and test Terraform code on pull requests.
- Deploy infrastructure on pushes to specific branches.
- Perform security checks using TFSec.
- Require manual approval before deployment.

## Terraform Configuration

### Resources Created

The Terraform configuration deploys the following resources:

1. **Azure Resource Group:**

   - **Name:** `${var.rg_name}_${var.environment}`
   - **Location:** Defined by `var.location` (default is `West US`).

2. **Azure Storage Account:**

   - **Name:** `${var.storage_account_name}${var.environment}` (must be globally unique).
   - **Resource Group:** Uses the created resource group.
   - **Account Tier:** Defined by `var.account_tier` (default is `Standard`).
   - **Replication Type:** Defined by `var.account_replication_type` (default is `LRS`).
   - **Minimum TLS Version:** Defined by `var.tls_version` (default is `TLS1_2`).
   - **Tags:** Includes the `environment` tag.

3. **Azure Blob Container:**

   - **Name:** Defined by `var.container_name` (default is `terraform-state`).
   - **Access Type:** Defined by `var.access_type` (default is `private`).

4. **Azure Storage Management Policy:**

   - **Rule Name:** `delete-contents-after-1-day`
   - **Action:** Deletes blob snapshots after one day.
   - **Filters:** Applies to `blockBlob` types.

### Variables

The `variables.tf` file defines the inputs for the Terraform configuration:

- **Azure Credentials:**
  - `azure_subscription_id` (type: `string`)
  - `azure_client_id` (type: `string`)
  - `azure_tenant_id` (type: `string`)

- **Resource Group:**
  - `rg_name` (default: `"Site2Site_rg"`)

- **Location:**
  - `location` (default: `"West US"`)

- **Environment:**
  - `environment` (type: `string`)

- **Storage Account Configuration:**
  - `storage_account_name` (default: `"tsblobstore11"`)
  - `account_tier` (default: `"Standard"`)
  - `account_replication_type` (default: `"LRS"`)
  - `tls_version` (default: `"TLS1_2"`)

- **Blob Container Configuration:**
  - `container_name` (default: `"terraform-state"`)
  - `access_type` (default: `"private"`)

### Outputs

The `outputs.tf` file provides the following outputs after deployment:

- `resource_group_name`: Name of the created resource group.
- `storage_account_name`: Name of the storage account.
- `container_name`: Name of the blob container.

## CI/CD Pipeline

The CI/CD pipeline is defined in the GitHub Actions workflow file `.github/workflows/azure-terraform.yml`. It automates the deployment process and ensures code quality and security.

### Workflow Triggers

The pipeline is triggered on:

- **Pull Requests** to the following branches:
  - `development`
  - `production`
  - `testing`
- **Pushes** to the following branches:
  - `development`
  - `production`

### Pipeline Overview

The pipeline consists of two primary jobs:

1. **Validate and Test (`validate-and-test`):**

   - **Checkout Code:** Retrieves the repository code.
   - **Azure Login:** Authenticates to Azure using OpenID Connect (OIDC) with the provided credentials.
   - **Set Up Terraform:** Prepares the environment for Terraform operations.
   - **Terraform Initialization:** Initializes Terraform.
   - **Set Environment Variable:** Determines the environment (`development`, `production`, or `default`) based on the branch.
   - **Terraform Validate:** Validates the Terraform configuration syntax.
   - **Terraform Plan:** Creates an execution plan and saves it to `tfplan`.
   - **Show Terraform Plan:** Displays the plan output.
   - **Install TFSec:** Installs TFSec for security scanning.
   - **Run TFSec Security Checks:** Scans the Terraform code for potential security issues.
   - **Skip Apply in Pull Requests:** Ensures that deployment does not occur on pull requests.

2. **Deploy (`deploy`):**

   - **Depends On:** The `validate-and-test` job must succeed.
   - **Runs On:** Not triggered on pull requests.
   - **Repeat Steps:** Similar steps for checkout, authentication, environment setup, and initialization.
   - **Re-run Terraform Plan:** Ensures the plan is up-to-date before applying.
   - **Manual Approval:** Requires manual approval via GitHub Issues before proceeding with the apply step.
   - **Terraform Apply:** Applies the changes as per the plan.

### Environment Variables and Secrets

The pipeline uses the following secrets and environment variables:

- **Secrets (Stored in GitHub Secrets):**
  - `AZURE_CLIENT_ID`: Azure Service Principal Client ID.
  - `AZURE_TENANT_ID`: Azure Tenant ID.
  - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID.
  - `github_TOKEN`: Automatically provided by GitHub for authentication in workflows.

- **Environment Variables:**
  - `ENVIRONMENT`: Set based on the branch (`development`, `production`, or `default`).

## Usage

### Clone the Repository

```bash
git clone https://github.com/CommittingLearning/Site2Site-Azure-BlobStorage.git
```

### Set Up Azure Credentials

Ensure that the following secrets are added to your GitHub repository under **Settings > Secrets and variables > Actions**:

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`

These credentials should correspond to an Azure Service Principal with the necessary permissions.

### Configure the Terraform Backend

This repository does not specify a backend configuration in the `terraform` block, but the storage account and container created here are intended to be used as the backend for other Terraform projects. When configuring the backend in other projects, use the following details:

- **Storage Account Name:** `tsblobstore11{environment}`
- **Container Name:** `terraform-state`
- **Key:** Provide a unique `.tfstate` file name for each project.
- **Resource Group Name:** `Site2Site_rg_{environment}`

### Branch Strategy

- **Development Environment:** Use the `development` branch to deploy to the development environment.
- **Production Environment:** Use the `production` branch to deploy to the production environment.
- **Default Environment:** Any other branches will use the `default` environment settings.

### Manual Approval

The pipeline requires manual approval before applying changes:

- A GitHub issue will be created prompting for approval.
- Approvers need to approve the issue to proceed with deployment.

## Notes

- **Security Checks:**
  - The pipeline includes security checks using TFSec to identify potential security issues in the Terraform code.

- **State Management:**
  - Terraform state is stored locally for this project. However, the storage account and container created are intended for remote state storage in other projects.

- **Customizations:**
  - Modify the variables in `variables.tf` to change resource names, configurations, and other settings as needed.

- **Testing:**
  - Pull requests to `development`, `production`, or `testing` branches will trigger the validation and testing steps without applying changes.

---

**Disclaimer:** This repository is accessible in a read only format, and therefore, only the admin has the privileges to perform a push on the branches.