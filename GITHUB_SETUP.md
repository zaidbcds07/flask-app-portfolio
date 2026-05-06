# GitHub Actions Setup Guide

## Step 1: Add GitHub Secrets

Go to your repository: https://github.com/zaidbcds07/flask-app-portfolio

1. Click on **Settings** tab
2. In the left sidebar, click **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret below:

### Required Secrets

#### Secret 1: AZURE_CREDENTIALS
**Name:** `AZURE_CREDENTIALS`

**Value:** (Replace with your service principal JSON - check your terminal history from the Azure setup)
```json
{
  "clientId": "YOUR_CLIENT_ID",
  "clientSecret": "YOUR_CLIENT_SECRET",
  "subscriptionId": "YOUR_SUBSCRIPTION_ID",
  "tenantId": "YOUR_TENANT_ID"
}
```

#### Secret 2: ACR_USERNAME
**Name:** `ACR_USERNAME`

**Value:** `zaidbacr`

#### Secret 3: ACR_PASSWORD
**Name:** `ACR_PASSWORD`

**Value:** (Your ACR password - check your terminal history from the Azure setup)

---

## Step 2: Assign Contributor Role (Admin Required)

⚠️ **Important:** Your Azure account doesn't have permission to assign roles. You need an Azure admin to run this command:

```bash
az role assignment create \
  --assignee YOUR_SERVICE_PRINCIPAL_APP_ID \
  --role contributor \
  --resource-group zl-resource-group
```

**Or provide these details to your admin:**
- **Service Principal App ID:** (from your Azure setup)
- **Resource Group:** `zl-resource-group`
- **Role Needed:** Contributor

---

## Step 3: Trigger Deployment

After adding secrets, the workflow will run automatically on your next push to `main`. 

To trigger it manually:
1. Go to **Actions** tab in your repository
2. Click on **Build and Deploy to Azure Container Apps**
3. Click **Run workflow** → **Run workflow**

---

## Azure Resources Created

| Resource | Name | Location |
|----------|------|----------|
| Resource Group | zl-resource-group | Southeast Asia |
| Container Registry | zaidbacr.azurecr.io | Southeast Asia |
| Container App | flask-portfolio-app | Southeast Asia |
| Container App Environment | flask-portfolio-env | Southeast Asia |

---

## Troubleshooting

### If deployment fails with permission errors:
The service principal needs Contributor role on the resource group. Contact your Azure admin.

### If ACR login fails:
- Verify `ACR_USERNAME` is exactly: `zaidbacr`
- Verify `ACR_PASSWORD` is the full password string

### To check workflow status:
1. Go to **Actions** tab in your repository
2. Click on the latest workflow run
3. Check the logs for any errors

---

## Files Modified

- `.github/workflows/deploy.yml` - Updated with Azure resource values
