# QA Environment Configuration Reference

**Last Updated:** November 14, 2025  
**Purpose:** Single source of truth for all QA environment configuration  
**Use:** Copy/paste these values for SMX and HP2 deployments

---

## 🔑 Quick Deploy Commands

### SMX QA - Complete Configuration

```bash
# Set all environment variables at once
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --replace-env-vars \
    "ASPNETCORE_ENVIRONMENT=Production" \
    "AzureAd__Instance=https://rhcqa.ciamlogin.com/" \
    "AzureAd__Domain=rhcqa.onmicrosoft.com" \
    "AzureAd__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2" \
    "AzureAd__ClientId=f5c66c2e-400c-4af7-b397-c1c841504371" \
    "AzureAd__ClientSecret=JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK" \
    "AzureAd__CallbackPath=/signin-oidc" \
    "DatabaseServer=rhcdb-qa-sqlsvr.database.windows.net" \
    "DatabaseName=qa_corp_db" \
    "DatabaseTenantId=4ed17c8b-26b0-4be9-a189-768c67fd03f5" \
    "KeyVaultUri=https://rhc-smx-qa-kv-2025.vault.azure.net/" \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=8649e36e-eade-469f-920e-ea658ca187a6;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/" \
    "StorageSettings__ConnectionString=$(az storage account show-connection-string --name rhcsmxqastorage --resource-group rhc-smx-qa-rg --query connectionString -o tsv)" \
    "DataProtection__BlobUri=https://rhcsmxqastorage.blob.core.windows.net/dataprotection-keys/keys.xml" \
    "DataProtection__KeyVaultUri=https://rhc-smx-qa-kv-2025.vault.azure.net/" \
    "DataProtection__KeyId=https://rhc-smx-qa-kv-2025.vault.azure.net/keys/dataprotection-keys" \
    "ConnectionStrings__CorpDatabase=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "SMXCORE_CORP_DB_CONNECTION_STRING=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__DefaultConnection=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-smx-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "EntraExternalId__Instance=https://rhcqa.ciamlogin.com/" \
    "EntraExternalId__Domain=rhcqa.onmicrosoft.com" \
    "EntraExternalId__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2" \
    "EntraExternalId__ClientId=f5c66c2e-400c-4af7-b397-c1c841504371" \
    "EntraExternalId__ClientSecret=JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK" \
    "CommunicationServices__ConnectionString=$(az communication list-key --name rhc-smx-qa-comms --resource-group rhc-smx-qa-rg --query primaryConnectionString -o tsv)" \
    "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net" \
    "CsysUserMgmt__Invitation__BaseUrl=https://smx-qa.recalibratex.net"
```

### HP2 QA - Complete Configuration

```bash
# Set all environment variables at once
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --replace-env-vars \
    "ASPNETCORE_ENVIRONMENT=Production" \
    "AzureAd__Instance=https://rhcqa.ciamlogin.com/" \
    "AzureAd__Domain=rhcqa.onmicrosoft.com" \
    "AzureAd__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2" \
    "AzureAd__ClientId=cfdc3d4b-dfe3-4414-a09d-a11a568187de" \
    "AzureAd__ClientSecret=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name hp2-qa-client-secret --query value -o tsv)" \
    "AzureAd__CallbackPath=/signin-oidc" \
    "EntraExternalId__Instance=https://rhcqa.ciamlogin.com/" \
    "EntraExternalId__Domain=rhcqa.onmicrosoft.com" \
    "EntraExternalId__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2" \
    "EntraExternalId__ClientId=cfdc3d4b-dfe3-4414-a09d-a11a568187de" \
    "EntraExternalId__ClientSecret=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name hp2-qa-client-secret --query value -o tsv)" \
    "DatabaseServer=rhcdb-qa-sqlsvr.database.windows.net" \
    "DatabaseName=qa_corp_db" \
    "DatabaseNameHP2=qa_hp2_db" \
    "DatabaseTenantId=4ed17c8b-26b0-4be9-a189-768c67fd03f5" \
    "KeyVaultUri=https://rhc-hp2-qa-kv-2025.vault.azure.net/" \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=2d95180d-9339-4103-b084-c20da27aa655;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/" \
    "ConnectionStrings__CorpDatabase=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__HealthProvidersDatabase=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_hp2_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__DefaultConnection=Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name rhc-hp2-qa-kv-2025 --name db-qa-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "CommunicationServices__ConnectionString=$(az communication list-key --name rhc-hp2-qa-comms --resource-group rhc-hp2-qa-rg --query primaryConnectionString -o tsv)" \
    "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net" \
    "CsysUserMgmt__Invitation__BaseUrl=https://hp2-qa.recalibratex.net"
```

---

## 📋 QA Infrastructure Resources

### Tenants

| Name | Domain | Tenant ID | Type |
|------|--------|-----------|------|
| QA (CIAM) | `rhcqa.onmicrosoft.com` | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` | CIAM |
| Database | `rhcdbase.onmicrosoft.com` | `4ed17c8b-26b0-4be9-a189-768c67fd03f5` | Azure AD |

### Subscriptions

| Name | Subscription ID |
|------|-----------------|
| QA | `3991b88f-785e-4e03-bac3-e6721b76140b` |
| Database | `a73a2d39-598b-4671-a3a6-2028c59f3d40` |

### SMX QA Resources

| Resource | Name | Details |
|----------|------|---------|
| Resource Group | `rhc-smx-qa-rg` | East US 2 |
| Container App | `rhc-smx-qa-app` | https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io |
| Container Environment | `rhc-smx-qa-env` | |
| Container Registry | `rhcsmxqaacr` | rhcsmxqaacr.azurecr.io |
| Key Vault | `rhc-smx-qa-kv-2025` | https://rhc-smx-qa-kv-2025.vault.azure.net/ |
| Storage Account | `rhcsmxqastorage` | https://rhcsmxqastorage.blob.core.windows.net/ |
| Application Insights | `rhc-smx-qa-insights` | Instrumentation Key: 8649e36e-eade-469f-920e-ea658ca187a6 |
| Log Analytics | `rhc-smx-qa-logs` | |
| Communication Services | `rhc-smx-qa-comm` | ⚠️ Base service only |
| Email Communication Service | `rhc-smx-qa-email` | ❌ **MISSING - Need to create** |
| Azure Managed Email Domain | (auto-generated) | ❌ **MISSING - Created with Email Service** |
| Storage Container: dataprotection-keys | `rhcsmxqastorage/dataprotection-keys` | ✅ Created Nov 14, 2025 |
| Managed Identity | System-assigned | 803e1c43-2245-49be-8463-a33df9bace0d |

### HP2 QA Resources

| Resource | Name | Details |
|----------|------|---------|
| Resource Group | `rhc-hp2-qa-rg` | East US 2 |
| Container App | `rhc-hp2-qa-app` | https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io |
| Container Environment | `rhc-hp2-qa-env` | |
| Key Vault | `rhc-hp2-qa-kv-2025` | https://rhc-hp2-qa-kv-2025.vault.azure.net/ |
| Application Insights | `rhc-hp2-qa-insights` | Instrumentation Key: 2d95180d-9339-4103-b084-c20da27aa655 |
| Log Analytics | `rhc-hp2-qa-logs` | |
| Communication Services | `rhc-hp2-qa-comm` | |
| Managed Identity | System-assigned | 79266d50-2220-4237-bc2a-588f83c39d54 |

### Database Resources (Cross-Tenant)

| Resource | Name | Details |
|----------|------|---------|
| SQL Server | `rhcdb-qa-sqlsvr.database.windows.net` | Tenant: rhcdbase |
| Corp Database | `qa_corp_db` | Shared data |
| HP2 Database | `qa_hp2_db` | HP2-specific data |

---

## 🔐 Authentication & Authorization

### CIAM Authentication (QA Tenant)

**Critical:** QA tenant is CIAM type - use `https://rhcqa.ciamlogin.com/` NOT `https://login.microsoftonline.com/`

| Setting | Value |
|---------|-------|
| Instance | `https://rhcqa.ciamlogin.com/` |
| Domain | `rhcqa.onmicrosoft.com` |
| Tenant ID | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` |
| Callback Path | `/signin-oidc` |

### SMX App Registration

| Setting | Value |
|---------|-------|
| Client ID | `f5c66c2e-400c-4af7-b397-c1c841504371` |
| Client Secret | `JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK` |
| Redirect URIs | https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io/signin-oidc<br>https://smx-qa.recalibratex.net/signin-oidc |

### HP2 App Registration

| Setting | Value |
|---------|-------|
| Client ID | `cfdc3d4b-dfe3-4414-a09d-a11a568187de` |
| Client Secret | (Stored in `rhc-hp2-qa-kv-2025` as `hp2-qa-client-secret`) |
| Redirect URIs | https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io/signin-oidc<br>https://hp2-qa.recalibratex.net/signin-oidc |

---

## 🗄️ Database Configuration

### Cross-Tenant Database Access

**Important:** Databases are in `rhcdbase` tenant, apps are in `rhcqa` tenant.

| Setting | Value |
|---------|-------|
| Server | `rhcdb-qa-sqlsvr.database.windows.net` |
| Corp Database | `qa_corp_db` |
| HP2 Database | `qa_hp2_db` |
| Database Tenant ID | `4ed17c8b-26b0-4be9-a189-768c67fd03f5` |

### Service Principal for Database Access

Service principal credentials stored in Key Vaults:
- `db-qa-app-id` - Service principal application ID
- `db-qa-app-secret` - Service principal secret

Apps use managed identity to retrieve these from Key Vault, then use them to authenticate to database tenant.

---

## 🔧 Environment Variables - Complete List

### SMX QA Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `ASPNETCORE_ENVIRONMENT` | `Production` | ASP.NET environment |
| `AzureAd__Instance` | `https://rhcqa.ciamlogin.com/` | **CIAM authentication endpoint** |
| `AzureAd__Domain` | `rhcqa.onmicrosoft.com` | Tenant domain |
| `AzureAd__TenantId` | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` | QA tenant ID |
| `AzureAd__ClientId` | `f5c66c2e-400c-4af7-b397-c1c841504371` | SMX app registration |
| `AzureAd__ClientSecret` | `JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK` | SMX client secret |
| `AzureAd__CallbackPath` | `/signin-oidc` | OAuth callback |
| `DatabaseServer` | `rhcdb-qa-sqlsvr.database.windows.net` | SQL Server endpoint |
| `DatabaseName` | `qa_corp_db` | Corporate database |
| `DatabaseTenantId` | `4ed17c8b-26b0-4be9-a189-768c67fd03f5` | Database tenant for auth |
| `KeyVaultUri` | `https://rhc-smx-qa-kv-2025.vault.azure.net/` | Key Vault endpoint |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | `InstrumentationKey=8649e36e-eade-469f-920e-ea658ca187a6;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/` | Application Insights |
| `StorageSettings__ConnectionString` | (Retrieved from storage account) | Azure Storage for data |
| `DataProtection__BlobUri` | `https://rhcsmxqastorage.blob.core.windows.net/dataprotection-keys/keys.xml` | DataProtection keys storage |
| `DataProtection__KeyVaultUri` | `https://rhc-smx-qa-kv-2025.vault.azure.net/` | Key Vault for encryption |
| `DataProtection__KeyId` | `https://rhc-smx-qa-kv-2025.vault.azure.net/keys/dataprotection-keys` | Encryption key |
| `CommunicationServices__ConnectionString` | (Retrieved from Communication Services) | Azure Communication Services connection |
| `CommunicationServices__FromAddress` | `DoNotReply@<azure-managed-domain>.azurecomm.net` | **REQUIRED**: Sender email from linked domain |
| `CsysUserMgmt__Invitation__BaseUrl` | `https://smx-qa.recalibratex.net` | **REQUIRED**: Base URL for invitation links (use custom domain) |

### HP2 QA Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `ASPNETCORE_ENVIRONMENT` | `Production` | ASP.NET environment |
| `AzureAd__Instance` | `https://rhcqa.ciamlogin.com/` | **CIAM authentication endpoint** |
| `AzureAd__Domain` | `rhcqa.onmicrosoft.com` | Tenant domain |
| `AzureAd__TenantId` | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` | QA tenant ID |
| `AzureAd__ClientId` | `cfdc3d4b-dfe3-4414-a09d-a11a568187de` | HP2 app registration |
| `AzureAd__ClientSecret` | (From Key Vault: `hp2-qa-client-secret`) | HP2 client secret |
| `AzureAd__CallbackPath` | `/signin-oidc` | OAuth callback |
| `DatabaseServer` | `rhcdb-qa-sqlsvr.database.windows.net` | SQL Server endpoint |
| `DatabaseName` | `qa_corp_db` | Corporate database |
| `DatabaseNameHP2` | `qa_hp2_db` | HP2-specific database |
| `DatabaseTenantId` | `4ed17c8b-26b0-4be9-a189-768c67fd03f5` | Database tenant for auth |
| `KeyVaultUri` | `https://rhc-hp2-qa-kv-2025.vault.azure.net/` | Key Vault endpoint |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | `InstrumentationKey=2d95180d-9339-4103-b084-c20da27aa655;IngestionEndpoint=https://eastus2-3.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus2.livediagnostics.monitor.azure.com/` | Application Insights |
| `CommunicationServices__ConnectionString` | (Retrieved from Communication Services) | Azure Communication Services connection |
| `CommunicationServices__FromAddress` | `DoNotReply@<azure-managed-domain>.azurecomm.net` | **REQUIRED**: Sender email from linked domain |
| `CsysUserMgmt__Invitation__BaseUrl` | `https://hp2-qa.recalibratex.net` | **REQUIRED**: Base URL for invitation links (use custom domain) |

---

## 🔐 DataProtection Setup (REQUIRED)

### Create Key Vault Key and Blob Container

```bash
# SMX QA - Create DataProtection key and container
az keyvault key create \
  --vault-name "rhc-smx-qa-kv-2025" \
  --name "dataprotection-keys" \
  --kty RSA \
  --size 2048

az storage container create \
  --name "dataprotection-keys" \
  --account-name "rhcsmxqastorage" \
  --auth-mode login

# Grant managed identity Key Vault crypto permissions
az keyvault set-policy \
  --name "rhc-smx-qa-kv-2025" \
  --object-id "803e1c43-2245-49be-8463-a33df9bace0d" \
  --key-permissions get unwrapKey wrapKey
```

### HP2 QA - Create DataProtection key (if HP2 needs storage)

```bash
# Only if HP2 requires DataProtection with blob storage
az keyvault key create \
  --vault-name "rhc-hp2-qa-kv-2025" \
  --name "dataprotection-keys" \
  --kty RSA \
  --size 2048

# Grant managed identity Key Vault crypto permissions
az keyvault set-policy \
  --name "rhc-hp2-qa-kv-2025" \
  --object-id "79266d50-2220-4237-bc2a-588f83c39d54" \
  --key-permissions get unwrapKey wrapKey
```

---

## 📧 Communication Services Setup (REQUIRED)

### Create Email Communication Service for SMX

**✅ COMPLETED for SMX QA (November 14, 2025)**

```bash
# Create Communication Service with Email Service and Domain linked at creation
az communication create \
  --name "rhc-smx-qa-comms" \
  --location "global" \
  --resource-group "rhc-smx-qa-rg" \
  --data-location "UnitedStates"

# Create Email Communication Service
az communication email create \
  --name "rhc-smx-qa-email-svc" \
  --location "global" \
  --resource-group "rhc-smx-qa-rg" \
  --data-location "UnitedStates"

# Get the auto-generated Azure Managed Domain
# Example: c511a1a3-dd76-435c-a567-43a552a784c0.azurecomm.net
az communication email domain list \
  --email-service-name "rhc-smx-qa-email-svc" \
  --resource-group "rhc-smx-qa-rg"

# Link domain to Communication Service
az communication email domain link \
  --communication-service-name "rhc-smx-qa-comms" \
  --resource-group "rhc-smx-qa-rg" \
  --email-service-name "rhc-smx-qa-email-svc" \
  --domain-name "<azure-managed-domain>.azurecomm.net"

# Get connection string
az communication list-key \
  --name "rhc-smx-qa-comms" \
  --resource-group "rhc-smx-qa-rg" \
  --query primaryConnectionString -o tsv
```

**⚠️ CRITICAL: Configure sender email address**

```bash
# Add REQUIRED environment variable with sender from linked domain
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --set-env-vars "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net"
```

**Why this is required:**
- CsysUserMgmt.Infrastructure.Services.EmailService requires `CommunicationServices:FromAddress` configuration
- Without it, email sending will fail (app doesn't know what sender email to use)
- Must use the `DoNotReply@` address from the linked Azure Managed Domain
- See CsysUserMgmt README.md for details

### Create Email Communication Service for HP2

```bash
# Create Communication Service
az communication create \
  --name "rhc-hp2-qa-comms" \
  --location "global" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates"

# Create Email Communication Service
az communication email create \
  --name "rhc-hp2-qa-email-svc" \
  --location "global" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates"

# Get the auto-generated Azure Managed Domain
az communication email domain list \
  --email-service-name "rhc-hp2-qa-email-svc" \
  --resource-group "rhc-hp2-qa-rg"

# Link domain to Communication Service
az communication email domain link \
  --communication-service-name "rhc-hp2-qa-comms" \
  --resource-group "rhc-hp2-qa-rg" \
  --email-service-name "rhc-hp2-qa-email-svc" \
  --domain-name "<azure-managed-domain>.azurecomm.net"

# Get connection string
az communication list-key \
  --name "rhc-hp2-qa-comms" \
  --resource-group "rhc-hp2-qa-rg" \
  --query primaryConnectionString -o tsv

# ⚠️ CRITICAL: Add sender email address
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --set-env-vars "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net"
```

---

## 🔐 Required Permissions

### SMX Managed Identity Permissions

```bash
# Grant Key Vault access
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee 803e1c43-2245-49be-8463-a33df9bace0d \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-smx-qa-kv-2025"

# Grant ACR pull access
az role assignment create \
  --role "AcrPull" \
  --assignee 803e1c43-2245-49be-8463-a33df9bace0d \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.ContainerRegistry/registries/rhcsmxqaacr"

# Grant Storage access
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee 803e1c43-2245-49be-8463-a33df9bace0d \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.Storage/storageAccounts/rhcsmxqastorage"
```

### HP2 Managed Identity Permissions

```bash
# Grant Key Vault access
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee 79266d50-2220-4237-bc2a-588f83c39d54 \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-hp2-qa-rg/providers/Microsoft.KeyVault/vaults/rhc-hp2-qa-kv-2025"
```

---

## 🚀 GitHub Actions Configuration

### GitHub Secrets Required

**For SMX Repository (smx25):**

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS_QA` | Service principal JSON (see below) |
| `AZURE_SUBSCRIPTION_ID` | `3991b88f-785e-4e03-bac3-e6721b76140b` |
| `SMX_QA_RG` | `rhc-smx-qa-rg` |
| `SMX_QA_APP_NAME` | `rhc-smx-qa-app` |
| `SMX_QA_ENV_NAME` | `rhc-smx-qa-env` |
| `ACR_NAME` | `rhcsmxqaacr` |
| `SMX_QA_KV_NAME` | `rhc-smx-qa-kv-2025` |
| `DB_SERVER` | `rhcdb-qa-sqlsvr.database.windows.net` |
| `DB_NAME` | `qa_corp_db` |

**For HP2 Repository (hp225):**

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS_QA` | Service principal JSON (same as SMX) |
| `AZURE_SUBSCRIPTION_ID` | `3991b88f-785e-4e03-bac3-e6721b76140b` |
| `HP2_QA_RG` | `rhc-hp2-qa-rg` |
| `HP2_QA_APP_NAME` | `rhc-hp2-qa-app` |
| `HP2_QA_ENV_NAME` | `rhc-hp2-qa-env` |
| `HP2_QA_KV_NAME` | `rhc-hp2-qa-kv-2025` |
| `DB_SERVER` | `rhcdb-qa-sqlsvr.database.windows.net` |
| `DB_NAME` | `qa_corp_db` |
| `DB_NAME_HP2` | `qa_hp2_db` |

### Service Principal for GitHub Actions

**Principal ID:** `f2f4c74d-6739-408f-b941-76f658712b16`  
**Name:** `github-actions-qa-deployer`

**AZURE_CREDENTIALS_QA value:**
```json
{
  "clientId": "f2f4c74d-6739-408f-b941-76f658712b16",
  "clientSecret": "RL08Q~aJteN9PF.YuDCHjbd~XJL7XiGgeiCNaceD",
  "tenantId": "2604fd9a-93a6-448e-bdc9-25e3c2d671a2",
  "subscriptionId": "3991b88f-785e-4e03-bac3-e6721b76140b"
}
```

---

## 📝 Key Vault Secrets

### SMX QA Key Vault (`rhc-smx-qa-kv-2025`)

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `smx-qa-client-secret` | `JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK` | SMX app registration |
| `db-qa-app-id` | (Service principal ID for DB access) | Cross-tenant DB auth |
| `db-qa-app-secret` | (Service principal secret for DB access) | Cross-tenant DB auth |

### HP2 QA Key Vault (`rhc-hp2-qa-kv-2025`)

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `hp2-qa-client-secret` | (HP2 app registration secret) | HP2 app registration |
| `db-qa-app-id` | (Service principal ID for DB access) | Cross-tenant DB auth |
| `db-qa-app-secret` | (Service principal secret for DB access) | Cross-tenant DB auth |

---

## ⚡ Quick Deployment Checklist

### Before Deploying Any App

- [ ] Verify GitHub Secrets are configured
- [ ] Verify managed identity has required permissions
- [ ] Verify app registration redirect URIs are correct
- [ ] Verify Key Vault secrets exist
- [ ] **Create Email Communication Service and Azure Managed Domain** (see section above)
- [ ] **Create Storage Blob Containers** (e.g., dataprotection-keys)

### Deploy SMX

```bash
# 1. Configure all environment variables (use command from top of doc)
# 2. Push to qa branch
cd /path/to/smx25
git checkout qa
git push origin qa

# 3. Watch deployment
gh run watch

# 4. Verify
curl -I https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io
```

### Deploy HP2

```bash
# 1. Grant service principal access to HP2 resource group
az role assignment create \
  --role "Contributor" \
  --assignee f2f4c74d-6739-408f-b941-76f658712b16 \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-hp2-qa-rg"

# 2. Configure GitHub Secrets in hp225 repository

# 3. Create workflow file (copy from smx25, update resource names)

# 4. Configure all environment variables (use command from top of doc)

# 5. Push to qa branch
cd /path/to/hp225
git checkout qa
git push origin qa

# 6. Watch deployment
gh run watch

# 7. Verify
curl -I https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io
```

---

## 🔍 Troubleshooting

### Authentication Not Working

**Check CIAM endpoint:**
```bash
az containerapp show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" \
  --query "properties.template.containers[0].env[?name=='AzureAd__Instance'].value" -o tsv
```
Should return: `https://rhcqa.ciamlogin.com/`

### Database Connection Failing

**Check cross-tenant configuration:**
```bash
az containerapp show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" \
  --query "properties.template.containers[0].env[?name=='DatabaseTenantId'].value" -o tsv
```
Should return: `4ed17c8b-26b0-4be9-a189-768c67fd03f5`

### Storage Errors

**Check storage connection:**
```bash
az containerapp show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" \
  --query "properties.template.containers[0].env[?name=='StorageSettings__ConnectionString']"
```
Should have a value.

**Check managed identity permissions:**
```bash
az role assignment list \
  --assignee 803e1c43-2245-49be-8463-a33df9bace0d \
  --scope "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.Storage/storageAccounts/rhcsmxqastorage" \
  --query "[].roleDefinitionName" -o table
```
Should include: `Storage Blob Data Contributor`

---

## 🔄 Common Operations

### Container App Scaling

**Default Configuration**: `minReplicas = 0` (scales to zero when idle to save costs)

#### Check Current Scaling
```bash
# SMX QA
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.template.scale" -o json

# HP2 QA
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.template.scale" -o json
```

#### Scale to Zero (Save Costs - Default)
```bash
# SMX QA
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --min-replicas 0 \
  --max-replicas 10

# HP2 QA
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --min-replicas 0 \
  --max-replicas 10
```

#### Keep Warm (Active Testing)
Set to 1 during testing to avoid cold starts (~$39/month per app):
```bash
# SMX QA
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --min-replicas 1 \
  --max-replicas 10

# HP2 QA
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --min-replicas 1 \
  --max-replicas 10
```

**See `CONTAINER-APP-SCALING.md` for detailed cost analysis and scheduling strategies.**

### Restart Container Apps

```bash
# SMX QA
az containerapp revision restart \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg"

# HP2 QA
az containerapp revision restart \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg"
```

---

## 📚 Related Documentation

- **Container App Scaling:** `docs/CONTAINER-APP-SCALING.md` - Scaling strategies and cost analysis
- **CIAM Authentication Fix:** `docs/CIAM-AUTHENTICATION-FIX.md`
- **Email Invitation Fix:** `docs/EMAIL-INVITATION-FIX.md`
- **Monitoring Guide:** `docs/MONITORING-GUIDE.md`
- **Phase 5 - Resources:** `docs/05-resource-groups-and-services.md`
- **Phase 6 - GitHub Actions:** `docs/06-github-actions-qa.md`
- **Quick Reference:** `docs/QUICK-REFERENCE.md`

---

**Document Version:** 1.1  
**Last Updated:** November 15, 2025  
**Status:** ✅ Complete - Ready for use
