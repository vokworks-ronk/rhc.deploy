# 📦 Phase 5: Resource Groups and Services Setup

**Status:** ⏳ Waiting for Phases 1-4  
**Prerequisites:** B2C QA tenant and subscription ready  
**Estimated Time:** 90-120 minutes

---

## 📋 Overview

This phase creates all Azure resources for HP2 and SMX applications in the QA environment:

**HP2 QA Stack:**
- Resource Group
- Container App & Environment
- Key Vault
- Application Insights
- Log Analytics Workspace
- Communication Services (Email)
- Storage Account (if needed)

**SMX QA Stack:**
- Resource Group
- Container App & Environment  
- Container Registry
- Key Vault
- Application Insights
- Communication Services (Email)
- Storage Account

**Key Principles:**
- Separate resource groups for HP2 and SMX
- Managed Identity enabled for database access
- All secrets in Key Vault
- Monitoring and logging configured

---

## 🎯 Checklist

### Pre-Configuration
- [ ] Verify B2C QA tenant and subscription ready
- [ ] Document B2C App IDs and secrets from Phase 4
- [ ] Have database connection details from Phase 3

### HP2 QA Resources
- [ ] Create HP2 QA resource group (`rhc-hp2-qa-rg`)
- [ ] Create Container Apps Environment
- [ ] Create Container App with Managed Identity
- [ ] Create Key Vault
- [ ] Create Application Insights
- [ ] Create Log Analytics Workspace
- [ ] Create Communication Services
- [ ] Configure custom domain

### SMX QA Resources
- [ ] Create SMX QA resource group (`rhc-smx-qa-rg`)
- [ ] Create Container Registry
- [ ] Create Container Apps Environment
- [ ] Create Container App with Managed Identity
- [ ] Create Key Vault
- [ ] Create Application Insights
- [ ] Create Communication Services
- [ ] Create Storage Account
- [ ] Configure custom domain

### Cross-Tenant Configuration
- [ ] Grant Managed Identity access to databases
- [ ] Store B2C secrets in Key Vault
- [ ] Configure app settings
- [ ] Test connectivity

### Verification
- [ ] Test Managed Identity database access
- [ ] Verify Key Vault access
- [ ] Test Application Insights logging
- [ ] Update deployment-log.md

---

## 📝 Resource Information (Fill in after creation)

### HP2 QA Resources

| Resource Type | Resource Name | Purpose | Status |
|---------------|---------------|---------|--------|
| Resource Group | `rhc-hp2-qa-rg` | HP2 QA resources | ⬜ |
| Container Apps Environment | `rhc-hp2-qa-env` | Container hosting | ⬜ |
| Container App | `rhc-hp2-qa-app` | HP2 application | ⬜ |
| Key Vault | `rhc-hp2-qa-kv` | Secrets storage | ⬜ |
| Application Insights | `rhc-hp2-qa-insights` | Monitoring | ⬜ |
| Log Analytics | `rhc-hp2-qa-logs` | Logging | ⬜ |
| Communication Services | `rhc-hp2-qa-comms` | Email services | ⬜ |

### SMX QA Resources

| Resource Type | Resource Name | Purpose | Status |
|---------------|---------------|---------|--------|
| Resource Group | `rhc-smx-qa-rg` | SMX QA resources | ⬜ |
| Container Registry | `rhcsmxqaacr` | Container images | ⬜ |
| Container Apps Environment | `rhc-smx-qa-env` | Container hosting | ⬜ |
| Container App | `rhc-smx-qa-app` | SMX application | ⬜ |
| Key Vault | `rhc-smx-qa-kv` | Secrets storage | ⬜ |
| Application Insights | `rhc-smx-qa-insights` | Monitoring | ⬜ |
| Communication Services | `rhc-smx-qa-comms` | Email services | ⬜ |
| Storage Account | `rhcsmxqastorage` | File storage | ⬜ |

---

## 🔧 Part 1: HP2 QA Infrastructure

### Step 1: Create HP2 QA Resource Group

#### Via Azure CLI

```bash
# Login to B2C QA tenant
az login --tenant rhc-b2c-qa.onmicrosoft.com

# Set subscription
az account set --subscription "rhc-b2c-qa-sub"

# Create resource group
az group create \
  --name "rhc-hp2-qa-rg" \
  --location "eastus2" \
  --tags Environment=QA Application=HP2 Project=RHC
```

### Step 2: Create Log Analytics Workspace

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group "rhc-hp2-qa-rg" \
  --workspace-name "rhc-hp2-qa-logs" \
  --location "eastus2" \
  --tags Environment=QA Application=HP2

# Get workspace ID (save for later)
$workspaceId = az monitor log-analytics workspace show \
  --resource-group "rhc-hp2-qa-rg" \
  --workspace-name "rhc-hp2-qa-logs" \
  --query customerId -o tsv

$workspaceKey = az monitor log-analytics workspace get-shared-keys \
  --resource-group "rhc-hp2-qa-rg" \
  --workspace-name "rhc-hp2-qa-logs" \
  --query primarySharedKey -o tsv
```

### Step 3: Create Application Insights

```bash
# Create Application Insights
az monitor app-insights component create \
  --app "rhc-hp2-qa-insights" \
  --location "eastus2" \
  --resource-group "rhc-hp2-qa-rg" \
  --workspace "/subscriptions/<subscription-id>/resourceGroups/rhc-hp2-qa-rg/providers/Microsoft.OperationalInsights/workspaces/rhc-hp2-qa-logs" \
  --tags Environment=QA Application=HP2

# Get instrumentation key
$instrumentationKey = az monitor app-insights component show \
  --app "rhc-hp2-qa-insights" \
  --resource-group "rhc-hp2-qa-rg" \
  --query instrumentationKey -o tsv
```

### Step 4: Create Container Apps Environment

```bash
# Create Container Apps Environment
az containerapp env create \
  --name "rhc-hp2-qa-env" \
  --resource-group "rhc-hp2-qa-rg" \
  --location "eastus2" \
  --logs-workspace-id $workspaceId \
  --logs-workspace-key $workspaceKey \
  --tags Environment=QA Application=HP2
```

### Step 5: Create Key Vault

```bash
# Create Key Vault
az keyvault create \
  --name "rhc-hp2-qa-kv" \
  --resource-group "rhc-hp2-qa-rg" \
  --location "eastus2" \
  --enable-rbac-authorization true \
  --tags Environment=QA Application=HP2

# Grant yourself access (for configuration)
$currentUserId = az ad signed-in-user show --query id -o tsv

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee $currentUserId \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rhc-hp2-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-hp2-qa-kv"
```

### Step 6: Store B2C Secrets in Key Vault

```bash
# Store HP2 B2C Client ID
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv" \
  --name "B2C-ClientId" \
  --value "<hp2-app-id-from-phase-4>"

# Store HP2 B2C Client Secret
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv" \
  --name "B2C-ClientSecret" \
  --value "<hp2-client-secret-from-phase-4>"

# Store B2C Tenant ID
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv" \
  --name "B2C-TenantId" \
  --value "<b2c-qa-tenant-id>"

# Store Application Insights key
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv" \
  --name "ApplicationInsights-InstrumentationKey" \
  --value $instrumentationKey
```

### Step 7: Create Container App with Managed Identity

```bash
# Create Container App with placeholder image
# We'll update with real image from GitHub Actions later
az containerapp create \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --environment "rhc-hp2-qa-env" \
  --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" \
  --target-port 80 \
  --ingress external \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --system-assigned \
  --tags Environment=QA Application=HP2

# Get the Managed Identity Principal ID
$hp2ManagedIdentityId = az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query identity.principalId -o tsv

# Save this ID for database access configuration
```

### Step 8: Grant Managed Identity Key Vault Access

```bash
# Grant Container App access to Key Vault
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $hp2ManagedIdentityId \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rhc-hp2-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-hp2-qa-kv"
```

### Step 9: Create Communication Services

```bash
# Create Communication Services resource
az communication create \
  --name "rhc-hp2-qa-comms" \
  --location "global" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates" \
  --tags Environment=QA Application=HP2

# Create Email Communication Service
az communication email create \
  --name "rhc-hp2-qa-email" \
  --location "global" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates" \
  --tags Environment=QA Application=HP2

# Get connection string
$commsConnectionString = az communication list-key \
  --name "rhc-hp2-qa-comms" \
  --resource-group "rhc-hp2-qa-rg" \
  --query primaryConnectionString -o tsv

# Store in Key Vault
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv" \
  --name "CommunicationServices-ConnectionString" \
  --value $commsConnectionString
```

### Step 10: Configure Custom Domain (Later)

Custom domain configuration will be done after deployment. For now, document the default URL:

```bash
# Get the default URL
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query properties.configuration.ingress.fqdn -o tsv

# URL will be something like: rhc-hp2-qa-app.niceriver-12345.eastus2.azurecontainerapps.io
```

---

## 🔧 Part 2: SMX QA Infrastructure

### Step 1: Create SMX QA Resource Group

```bash
# Create resource group
az group create \
  --name "rhc-smx-qa-rg" \
  --location "eastus2" \
  --tags Environment=QA Application=SMX Project=RHC
```

### Step 2: Create Container Registry

```bash
# Create Azure Container Registry
az acr create \
  --resource-group "rhc-smx-qa-rg" \
  --name "rhcsmxqaacr" \
  --sku Basic \
  --admin-enabled false \
  --tags Environment=QA Application=SMX

# Enable admin (for GitHub Actions, will use service principal later)
az acr update \
  --name "rhcsmxqaacr" \
  --resource-group "rhc-smx-qa-rg" \
  --admin-enabled true

# Get ACR credentials (for GitHub Actions)
az acr credential show \
  --name "rhcsmxqaacr" \
  --resource-group "rhc-smx-qa-rg"
```

### Step 3: Create Log Analytics and Application Insights

```bash
# Create Log Analytics
az monitor log-analytics workspace create \
  --resource-group "rhc-smx-qa-rg" \
  --workspace-name "rhc-smx-qa-logs" \
  --location "eastus2"

$workspaceId = az monitor log-analytics workspace show \
  --resource-group "rhc-smx-qa-rg" \
  --workspace-name "rhc-smx-qa-logs" \
  --query customerId -o tsv

$workspaceKey = az monitor log-analytics workspace get-shared-keys \
  --resource-group "rhc-smx-qa-rg" \
  --workspace-name "rhc-smx-qa-logs" \
  --query primarySharedKey -o tsv

# Create Application Insights
az monitor app-insights component create \
  --app "rhc-smx-qa-insights" \
  --location "eastus2" \
  --resource-group "rhc-smx-qa-rg" \
  --workspace "/subscriptions/<subscription-id>/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.OperationalInsights/workspaces/rhc-smx-qa-logs"

$instrumentationKey = az monitor app-insights component show \
  --app "rhc-smx-qa-insights" \
  --resource-group "rhc-smx-qa-rg" \
  --query instrumentationKey -o tsv
```

### Step 4: Create Container Apps Environment

```bash
az containerapp env create \
  --name "rhc-smx-qa-env" \
  --resource-group "rhc-smx-qa-rg" \
  --location "eastus2" \
  --logs-workspace-id $workspaceId \
  --logs-workspace-key $workspaceKey
```

### Step 5: Create Key Vault

```bash
az keyvault create \
  --name "rhc-smx-qa-kv" \
  --resource-group "rhc-smx-qa-rg" \
  --location "eastus2" \
  --enable-rbac-authorization true

# Grant yourself access
$currentUserId = az ad signed-in-user show --query id -o tsv

az role assignment create \
  --role "Key Vault Administrator" \
  --assignee $currentUserId \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-smx-qa-kv"
```

### Step 6: Store Secrets in Key Vault

```bash
# Store SMX B2C credentials
az keyvault secret set --vault-name "rhc-smx-qa-kv" --name "B2C-ClientId" --value "<smx-app-id>"
az keyvault secret set --vault-name "rhc-smx-qa-kv" --name "B2C-ClientSecret" --value "<smx-client-secret>"
az keyvault secret set --vault-name "rhc-smx-qa-kv" --name "B2C-TenantId" --value "<b2c-qa-tenant-id>"
az keyvault secret set --vault-name "rhc-smx-qa-kv" --name "ApplicationInsights-InstrumentationKey" --value $instrumentationKey
```

### Step 7: Create Storage Account

```bash
# Create storage account
az storage account create \
  --name "rhcsmxqastorage" \
  --resource-group "rhc-smx-qa-rg" \
  --location "eastus2" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --tags Environment=QA Application=SMX

# Get connection string
$storageConnectionString = az storage account show-connection-string \
  --name "rhcsmxqastorage" \
  --resource-group "rhc-smx-qa-rg" \
  --query connectionString -o tsv

# Store in Key Vault
az keyvault secret set \
  --vault-name "rhc-smx-qa-kv" \
  --name "Storage-ConnectionString" \
  --value $storageConnectionString
```

### Step 8: Create Container App with Managed Identity

```bash
az containerapp create \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --environment "rhc-smx-qa-env" \
  --image "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" \
  --target-port 80 \
  --ingress external \
  --cpu 0.5 \
  --memory 1.0Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --system-assigned

# Get Managed Identity
$smxManagedIdentityId = az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query identity.principalId -o tsv

# Grant Key Vault access
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee $smxManagedIdentityId \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-smx-qa-kv"
```

### Step 9: Create Communication Services

```bash
az communication create \
  --name "rhc-smx-qa-comms" \
  --location "global" \
  --resource-group "rhc-smx-qa-rg" \
  --data-location "UnitedStates"

az communication email create \
  --name "rhc-smx-qa-email" \
  --location "global" \
  --resource-group "rhc-smx-qa-rg" \
  --data-location "UnitedStates"

$commsConnectionString = az communication list-key \
  --name "rhc-smx-qa-comms" \
  --resource-group "rhc-smx-qa-rg" \
  --query primaryConnectionString -o tsv

az keyvault secret set \
  --vault-name "rhc-smx-qa-kv" \
  --name "CommunicationServices-ConnectionString" \
  --value $commsConnectionString
```

---

## 🔧 Part 3: Grant Database Access to Managed Identities

Now we need to grant the Container Apps' Managed Identities access to the databases in the Database tenant.

### Get Managed Identity Information

```bash
# HP2 Managed Identity
echo "HP2 Managed Identity ID: $hp2ManagedIdentityId"

# SMX Managed Identity
echo "SMX Managed Identity ID: $smxManagedIdentityId"
```

### Grant Database Access via SQL

Connect to the database server (`rhc-qa-sqlsvr.database.windows.net`) using Azure Data Studio or SQL Server Management Studio, authenticated with your Entra ID account (Ron).

#### For corp_db database:

```sql
-- Connect to corp_db
USE corp_db;
GO

-- Create user for HP2 Managed Identity
CREATE USER [rhc-hp2-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [rhc-hp2-qa-app];
GO

-- Create user for SMX Managed Identity
CREATE USER [rhc-smx-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [rhc-smx-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [rhc-smx-qa-app];
GO
```

#### For hp2_db database:

```sql
-- Connect to hp2_db
USE hp2_db;
GO

-- Create user for HP2 Managed Identity
CREATE USER [rhc-hp2-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [rhc-hp2-qa-app];
GO
```

---

## 📊 Configure Container App Environment Variables

### HP2 QA Environment Variables

```bash
# Update HP2 container app with environment variables
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --set-env-vars \
    "ASPNETCORE_ENVIRONMENT=QA" \
    "AzureAdB2C__Instance=https://rhc-b2c-qa.b2clogin.com" \
    "AzureAdB2C__Domain=rhc-b2c-qa.onmicrosoft.com" \
    "AzureAdB2C__SignUpSignInPolicyId=B2C_1_signupsignin_qa" \
    "KeyVaultName=rhc-hp2-qa-kv" \
    "ConnectionStrings__CorpDatabase=Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=corp_db;Authentication=Active Directory Managed Identity;Encrypt=True;" \
    "ConnectionStrings__HP2Database=Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=hp2_db;Authentication=Active Directory Managed Identity;Encrypt=True;"
```

### SMX QA Environment Variables

```bash
# Update SMX container app
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --set-env-vars \
    "ASPNETCORE_ENVIRONMENT=QA" \
    "AzureAdB2C__Instance=https://rhc-b2c-qa.b2clogin.com" \
    "AzureAdB2C__Domain=rhc-b2c-qa.onmicrosoft.com" \
    "AzureAdB2C__SignUpSignInPolicyId=B2C_1_signupsignin_qa" \
    "KeyVaultName=rhc-smx-qa-kv" \
    "ConnectionStrings__CorpDatabase=Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=corp_db;Authentication=Active Directory Managed Identity;Encrypt=True;"
```

---

## 🔍 Verification Steps

### 1. Verify Resource Creation

```bash
# List HP2 resources
az resource list --resource-group "rhc-hp2-qa-rg" --output table

# List SMX resources
az resource list --resource-group "rhc-smx-qa-rg" --output table
```

### 2. Test Key Vault Access

```bash
# Test accessing secret from HP2 Key Vault
az keyvault secret show \
  --vault-name "rhc-hp2-qa-kv" \
  --name "B2C-ClientId"

# Test from SMX Key Vault
az keyvault secret show \
  --vault-name "rhc-smx-qa-kv" \
  --name "B2C-ClientId"
```

### 3. Check Container App Status

```bash
# Check HP2 app
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.runningStatus"

# Check SMX app
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.runningStatus"
```

### 4. Get Application URLs

```bash
# HP2 URL
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.configuration.ingress.fqdn" -o tsv

# SMX URL  
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.configuration.ingress.fqdn" -o tsv
```

---

## 📊 What We've Accomplished

After completing this phase:

✅ **HP2 QA Infrastructure:**
- Resource group and all Azure services created
- Managed Identity configured for secure database access
- Key Vault storing all secrets
- Monitoring and logging configured

✅ **SMX QA Infrastructure:**
- Resource group and all Azure services created
- Container Registry for Docker images
- Managed Identity configured
- Storage account for file storage

✅ **Cross-Tenant Security:**
- Managed Identities granted database access
- Secrets stored in Key Vault (not in code)
- Environment variables configured

✅ **Ready for Deployment:**
- Infrastructure ready to receive application deployments
- GitHub Actions can now deploy to these environments

---

## 📝 Update Deployment Log

```markdown
## 2025-10-XX - Phase 5: Resource Groups and Services

**Completed by:** Ron

### HP2 QA Resources Created
- [x] Resource group, Container App, Key Vault, App Insights, Communication Services
- [x] Managed Identity configured and database access granted

### SMX QA Resources Created
- [x] Resource group, Container Registry, Container App, Key Vault, Storage, Communication Services
- [x] Managed Identity configured and database access granted

**Status:** ✅ Complete
**HP2 URL:** [temp URL from Container App]
**SMX URL:** [temp URL from Container App]
**Notes:** All infrastructure ready for deployment
```

---

## ➡️ Next Steps

Once all resources are created:

**👉 Proceed to:** `06-github-actions-qa.md`

This will configure GitHub Actions to automatically deploy HP2 and SMX to the QA environment.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** ⏳ Waiting for Phases 1-4
