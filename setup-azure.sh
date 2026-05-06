#!/bin/bash
# Quick setup script for Azure resources
# Run this after creating the resource group

echo "=== Flask Portfolio App - Azure Setup ==="
echo ""

# Configuration - UPDATE THESE VALUES
RESOURCE_GROUP="zl-resource-group"  # CHANGE THIS
LOCATION="southeastasia"
ACR_NAME="zaidbacr"  # CHANGE THIS - must be globally unique
CONTAINER_APP_NAME="flask-portfolio-app"
ENVIRONMENT_NAME="flask-portfolio-env"

# Check if logged in
echo "Checking Azure login..."
az account show > /dev/null 2>&1 || { echo "Please run 'az login' first"; exit 1; }

# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription: $SUBSCRIPTION_ID"
echo ""

# Create Resource Group
echo "Creating Resource Group: $RESOURCE_GROUP..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Container Registry
echo "Creating Container Registry: $ACR_NAME..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Get ACR credentials
echo ""
echo "=== ACR Credentials ==="
az acr credential show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "{username:username, password:passwords[0].value}"

# Create Service Principal for GitHub Actions
echo ""
echo "Creating Service Principal for GitHub Actions..."
az ad sp create-for-rbac \
  --name "GitHubActions-FlaskPortfolio" \
  --role contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --sdk-auth

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Copy the JSON output above (AZURE_CREDENTIALS)"
echo "2. Get ACR credentials from above"
echo "3. Add these as GitHub Secrets (see DEPLOYMENT_GUIDE.md)"
echo "4. Deploy the Bicep template:"
echo ""
echo "az deployment group create \\"
echo "  --resource-group $RESOURCE_GROUP \\"
echo "  --template-file infrastructure/main.bicep \\"
echo "  --parameters \\"
echo "    containerRegistryName=$ACR_NAME \\"
echo "    containerAppName=$CONTAINER_APP_NAME \\"
echo "    environmentName=$ENVIRONMENT_NAME \\"
echo "    flaskSecretKey=\$(openssl rand -base64 32)"
