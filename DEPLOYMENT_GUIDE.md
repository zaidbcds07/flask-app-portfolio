# Deployment Guide: Flask Portfolio App to Azure

This guide walks you through setting up GitHub CI/CD and deploying the Flask Portfolio App to Azure using a different Azure account.

## Prerequisites

- GitHub account
- Azure account (different from the original)
- Azure CLI installed locally (optional, for verification)
- Docker installed locally (optional, for testing)

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the **+** icon in the top right → **New repository**
3. Enter repository name: `flask-app-portfolio`
4. Choose **Public** or **Private** (Private requires Azure Container Registry credentials)
5. Do NOT initialize with README (we already have one)
6. Click **Create repository**

## Step 2: Push Code to GitHub

Open PowerShell and run:

```powershell
# Navigate to the project directory
cd "C:\Users\lazim\Documents\MyDevOpsProjects\githubcicd\zaidbgenstudent\flask-app-portfolio"

# Initialize git (if not already initialized)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Flask Portfolio App with GitHub Actions CI/CD"

# Add remote repository (replace with your actual GitHub URL)
git remote add origin https://github.com/YOUR_USERNAME/flask-app-portfolio.git

# Push to GitHub
git push -u origin main
```

## Step 3: Set Up Azure Resources

### Option A: Using Azure Portal (Manual)

1. **Create a Resource Group:**
   - Go to [Azure Portal](https://portal.azure.com)
   - Click **Resource groups** → **Create**
   - Name: `flask-portfolio-rg`
   - Region: Choose closest to your users (e.g., Southeast Asia)
   - Click **Review + create** → **Create**

2. **Create Container Registry:**
   - Search for **Container registries** → **Create**
   - Resource group: `flask-portfolio-rg`
   - Registry name: `yournameacr2026` (must be globally unique)
   - SKU: **Basic**
   - Enable Admin user: **Yes**
   - Click **Review + create** → **Create**

3. **Create Container Apps Environment:**
   - Search for **Container Apps** → **Create**
   - Resource group: `flask-portfolio-rg`
   - Container app name: `flask-portfolio-app`
   - Region: Same as resource group
   - Create new environment: `flask-portfolio-env`
   - Click **Review + create** → **Create**

### Option B: Using Azure CLI

```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "Your Subscription Name"

# Create resource group
az group create \
  --name flask-portfolio-rg \
  --location southeastasia

# Create container registry
az acr create \
  --resource-group flask-portfolio-rg \
  --name yournameacr2026 \
  --sku Basic \
  --admin-enabled true

# Create container apps environment
az containerapp env create \
  --name flask-portfolio-env \
  --resource-group flask-portfolio-rg \
  --location southeastasia
```

## Step 4: Create Azure Service Principal

The GitHub Actions workflow needs credentials to deploy to Azure. Create a service principal:

```bash
# Replace with your subscription ID
az ad sp create-for-rbac \
  --name "GitHubActions-FlaskPortfolio" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/flask-portfolio-rg \
  --sdk-auth
```

**Save the JSON output** - you'll need it for GitHub secrets.

## Step 5: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `AZURE_CREDENTIALS` | JSON from Step 4 | Service principal output |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | Azure Portal → Subscriptions |
| `AZURE_CONTAINER_REGISTRY` | `yournameacr2026.azurecr.io` | Your ACR login server |
| `ACR_NAME` | `yournameacr2026` | Your ACR name |
| `ACR_USERNAME` | ACR admin username | Azure Portal → ACR → Access keys |
| `ACR_PASSWORD` | ACR admin password | Azure Portal → ACR → Access keys |
| `CONTAINER_APP_NAME` | `flask-portfolio-app` | Your container app name |
| `CONTAINER_APP_ENV_NAME` | `flask-portfolio-env` | Your environment name |
| `RESOURCE_GROUP` | `flask-portfolio-rg` | Your resource group name |
| `AZURE_LOCATION` | `southeastasia` | Your Azure region |
| `FLASK_SECRET_KEY` | A random secret key | Generate with: `openssl rand -base64 32` |

### Getting ACR Credentials:

```bash
# Get ACR credentials
az acr credential show --name yournameacr2026 --resource-group flask-portfolio-rg
```

## Step 6: Deploy Infrastructure (First Time Only)

The first deployment needs infrastructure. You can deploy the Bicep template:

```bash
# Deploy Bicep template
az deployment group create \
  --resource-group flask-portfolio-rg \
  --template-file infrastructure/main.bicep \
  --parameters \
    containerRegistryName=yournameacr2026 \
    containerAppName=flask-portfolio-app \
    environmentName=flask-portfolio-env \
    flaskSecretKey="your-generated-secret-key"
```

## Step 7: Trigger Deployment

Push any change to the `main` branch to trigger the CI/CD pipeline:

```bash
# Make a small change
echo "# Deployment triggered" >> README.md

# Commit and push
git add .
git commit -m "Trigger deployment"
git push origin main
```

Go to your GitHub repository → **Actions** tab to see the workflow running.

## Step 8: Verify Deployment

1. Wait for the GitHub Actions workflow to complete (5-10 minutes)
2. Go to Azure Portal → Container Apps → `flask-portfolio-app`
3. Click on **Application URL** to view your deployed app

Or use Azure CLI:

```bash
# Get the app URL
az containerapp show \
  --name flask-portfolio-app \
  --resource-group flask-portfolio-rg \
  --query properties.configuration.ingress.fqdn \
  --output tsv
```

## Troubleshooting

### Workflow Fails at Build

- Check that `requirements.txt` is in the repository root
- Verify Python version compatibility

### Docker Push Fails

- Verify ACR credentials in GitHub secrets
- Check that ACR admin user is enabled

### Deployment Fails

- Verify Azure service principal has Contributor role
- Check resource group and names match in secrets
- Ensure Container Apps environment exists

### App Doesn't Start

- Check Container Apps logs in Azure Portal
- Verify SECRET_KEY environment variable is set
- Check that port 5004 is exposed in Dockerfile

## Architecture

```
GitHub Repository
       │
       ▼
GitHub Actions Workflow
   ┌─────────┬──────────┐
   │         │          │
   ▼         ▼          ▼
Build      Test    Push to ACR
   │         │          │
   └─────────┴──────────┘
              │
              ▼
    Deploy to Azure
    Container Apps
              │
              ▼
         Live Website
```

## Cost Considerations

- **Azure Container Registry (Basic)**: ~$5/month
- **Azure Container Apps**: Pay-per-use (~$0.000024/vCPU/second + $0.000003/Gi/second)
- **For low traffic**: Expect $10-20/month

## Next Steps

- Set up custom domain with SSL
- Configure Azure Monitor for logging
- Set up staging environment
- Add database (Azure SQL or Cosmos DB) for production

## Support

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Azure Container Apps Documentation](https://docs.microsoft.com/en-us/azure/container-apps/)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
