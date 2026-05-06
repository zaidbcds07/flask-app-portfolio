# GitHub Actions Secrets Setup

This file contains the list of secrets required for the GitHub Actions workflow.

## Required Secrets

Add these secrets in your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

### Azure Credentials

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AZURE_CREDENTIALS` | Service Principal JSON | `{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}` |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID | `12345678-1234-1234-1234-123456789012` |
| `AZURE_LOCATION` | Azure Region | `southeastasia` |

### Container Registry

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CONTAINER_REGISTRY` | ACR Login Server | `yournameacr2026.azurecr.io` |
| `ACR_NAME` | ACR Name | `yournameacr2026` |
| `ACR_USERNAME` | ACR Admin Username | Azure Portal → ACR → Access keys |
| `ACR_PASSWORD` | ACR Admin Password | Azure Portal → ACR → Access keys |

### Container App

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `CONTAINER_APP_NAME` | Container App Name | `flask-portfolio-app` |
| `CONTAINER_APP_ENV_NAME` | Container App Environment | `flask-portfolio-env` |
| `RESOURCE_GROUP` | Resource Group Name | `flask-portfolio-rg` |

### Application

| Secret Name | Description | How to Generate |
|-------------|-------------|-----------------|
| `FLASK_SECRET_KEY` | Flask Secret Key | `openssl rand -base64 32` |

## Commands to Get Values

### Get Azure Subscription ID
```bash
az account show --query id -o tsv
```

### Get ACR Credentials
```bash
az acr credential show --name yournameacr2026 --resource-group flask-portfolio-rg
```

### Generate Flask Secret Key
```bash
openssl rand -base64 32
```

### Create Service Principal
```bash
az ad sp create-for-rbac \
  --name "GitHubActions-FlaskPortfolio" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/flask-portfolio-rg \
  --sdk-auth
```

## Verification

After adding all secrets, verify by checking the **Actions** tab in your GitHub repository. Push a commit to trigger the workflow.
