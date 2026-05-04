# Azure DevOps Pipeline Setup Guide

This guide explains how to set up the Azure DevOps pipeline for deploying the Flask Portfolio App to Azure Container Apps.

## Current Configuration

Based on your `azure-pipelines.yml`, the following values are configured:

| Setting | Value |
|---------|-------|
| **Container Registry** | `zlacr2026.azurecr.io` |
| **Image Repository** | `flask-portfolio` |
| **Resource Group** | `flask-portfolio-rg` |
| **Container App Name** | `flask-portfolio-app` |
| **Python Version** | `3.12` |

## Prerequisites

1. **Azure DevOps Organization** - Create one at [dev.azure.com](https://dev.azure.com)
2. **Azure Subscription** - Active Azure subscription
3. **Azure Resources** (create these first):
   - Resource Group: `flask-portfolio-rg`
   - Azure Container Registry: `zlacr2026`
   - Azure Container Apps Environment

## Setup Steps

### 1. Create Azure Resources

Run these Azure CLI commands:

```bash
# Login to Azure
az login

# Create resource group (if not exists)
az group create --name flask-portfolio-rg --location eastus

# Create Azure Container Registry
az acr create --resource-group flask-portfolio-rg \
  --name zlacr2026 \
  --sku Basic \
  --admin-enabled true

# Create Container Apps Environment
az containerapp env create --name flask-portfolio-env \
  --resource-group flask-portfolio-rg \
  --location eastus
```

### 2. Get ACR Credentials

```bash
# Get ACR admin credentials
az acr credential show --name zlacr2026 --resource-group flask-portfolio-rg
```

Save the **username** and **password** for later use in pipeline variables.

### 3. Configure Azure DevOps Service Connections

#### A. Azure Container Registry Service Connection

1. Go to **Project Settings** → **Service connections** → **New service connection**
2. Select **Docker Registry**
3. Choose **Azure Container Registry**
4. Fill in:
   - **Subscription**: Your Azure subscription
   - **Azure container registry**: `zlacr2026`
   - **Service connection name**: `zlacr2026-connection` (or your preferred name)
5. Click **Save**

#### B. Azure Resource Manager Service Connection

1. Go to **Project Settings** → **Service connections** → **New service connection**
2. Select **Azure Resource Manager**
3. Choose **Service principal (automatic)**
4. Fill in:
   - **Scope level**: Subscription
   - **Subscription**: Your Azure subscription
   - **Service connection name**: `zl-azure-connection` (or your preferred name)
5. Click **Save**

### 4. Update Pipeline with Service Connection Names

Edit `azure-pipelines.yml` and replace the placeholder service connection names:

```yaml
# Replace 'your-acr-service-connection' with your actual ACR service connection name
containerRegistry: 'zlacr2026-connection'

# Replace 'your-azure-service-connection' with your actual Azure service connection name
azureSubscription: 'zl-azure-connection'
```

### 5. Configure Pipeline Variables

Go to **Pipelines** → **Library** → **+ Variable group**:

Create a variable group named `flask-portfolio-secrets` with these variables:

| Variable Name | Value | Secret? |
|--------------|-------|---------|
| `SECRET_KEY` | A long random string for Flask | ✓ Yes |
| `ACR_USERNAME` | Your ACR admin username | ✓ Yes |
| `ACR_PASSWORD` | Your ACR admin password | ✓ Yes |

**To mark as secret:** Click the lock icon next to each sensitive value.

### 6. Link Variable Group to Pipeline

Add this to your `azure-pipelines.yml` at the top of the `variables` section:

```yaml
variables:
  - group: flask-portfolio-secrets
  - name: containerRegistry
    value: 'zlacr2026.azurecr.io'
  # ... rest of variables
```

### 7. Create and Run Pipeline

1. Push the `azure-pipelines.yml` file to your repository
2. In Azure DevOps, go to **Pipelines** → **Create Pipeline**
3. Select **Azure Repos Git** → Your repository
4. Select **Existing Azure Pipelines YAML file**
5. Choose `/azure-pipelines.yml`
6. Click **Continue** → **Run**

## Pipeline Stages

The pipeline consists of 3 stages:

| Stage | Description |
|-------|-------------|
| **1. Build and Test** | Sets up Python 3.12, installs dependencies, runs tests, performs linting |
| **2. Build and Push** | Builds Docker image, tags with build ID and `latest`, pushes to ACR |
| **3. Deploy** | Creates or updates Azure Container App with the new image |

## Verification After Deployment

Once the pipeline completes successfully:

```bash
# Get the Container App URL
az containerapp show \
  --name flask-portfolio-app \
  --resource-group flask-portfolio-rg \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv
```

The app will be accessible at: `https://<fqdn>`

## Troubleshooting

### Pipeline fails at Docker login
- Verify the ACR service connection has correct permissions
- Ensure ACR admin account is enabled (`--admin-enabled true`)
- Check that the service connection name matches in the pipeline

### Container App creation fails
- Verify resource group `flask-portfolio-rg` exists
- Ensure Container Apps Environment exists: `flask-portfolio-env`
- Check Azure CLI is available in the pipeline (using `ubuntu-latest`)

### App not accessible after deployment
- Check ingress is set to `external` in the deployment
- Verify target port is `5004` (matches Gunicorn in Dockerfile)
- Review Container App logs in Azure Portal → Container Apps → flask-portfolio-app → Log stream

### Image pull errors
- Verify ACR credentials are correct in the variable group
- Check the image exists in ACR: `az acr repository list --name zlacr2026`

## Security Best Practices

1. **Use Managed Identity** instead of admin credentials for production
2. **Store secrets** in Azure Key Vault and reference in pipeline variables
3. **Enable HTTPS only** for Container App ingress
4. **Use private networking** for production workloads
5. **Scan images** for vulnerabilities using Azure Security Center

## Alternative: Deploy to Azure App Service

If you prefer Azure App Service instead of Container Apps, replace the Deploy stage with:

```yaml
- task: AzureWebAppContainer@1
  displayName: 'Deploy to Azure Web App'
  inputs:
    azureSubscription: 'zl-azure-connection'
    appName: 'flask-portfolio-webapp'
    containers: 'zlacr2026.azurecr.io/flask-portfolio:$(tag)'
```

## Additional Resources

- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Azure DevOps Pipelines Documentation](https://docs.microsoft.com/azure/devops/pipelines/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)

## Quick Reference Commands

```bash
# View ACR repositories
az acr repository list --name zlacr2026

# View Container Apps
az containerapp list --resource-group flask-portfolio-rg --output table

# View Container App logs
az containerapp logs show --name flask-portfolio-app \
  --resource-group flask-portfolio-rg --follow

# Delete and recreate Container App (if needed)
az containerapp delete --name flask-portfolio-app \
  --resource-group flask-portfolio-rg --yes
```
