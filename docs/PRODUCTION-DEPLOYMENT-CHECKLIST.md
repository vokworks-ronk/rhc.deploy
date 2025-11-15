# Production Deployment Checklist

**Date:** November 15, 2025 (Tomorrow)  
**Purpose:** Complete checklist for deploying SMX and HP2 to production  
**Based on:** Successful QA deployment (November 14, 2025)

---

## 🎯 Pre-Deployment Requirements

### Infrastructure (Must exist before deployment)
- [ ] Production tenant created and configured
- [ ] Production subscription active
- [ ] Database server and databases created
- [ ] Service principal for database access created and configured
- [ ] App registrations created in production tenant
- [ ] All resource groups created
- [ ] Container registries created
- [ ] Key Vaults created with access policies
- [ ] Application Insights created
- [ ] Container Apps Environments created
- [ ] Container Apps created (can be empty initially)

### Secrets (Must be stored in Key Vault)
- [ ] SMX client secret (`smx-prod-client-secret`)
- [ ] HP2 client secret (`hp2-prod-client-secret`)
- [ ] Database service principal ID (`db-prod-app-id`)
- [ ] Database service principal secret (`db-prod-app-secret`)

### GitHub Actions
- [ ] Production branch created
- [ ] GitHub secrets configured
- [ ] Workflow files created for production
- [ ] Service principal for deployments has permissions

---

## 📋 Deployment Steps (Based on QA Success)

### Step 1: Create DataProtection Infrastructure

**For SMX:**
```bash
# Create Key Vault key for DataProtection
az keyvault key create \
  --vault-name "<smx-prod-kv-name>" \
  --name "dataprotection-keys" \
  --kty RSA \
  --size 2048

# Create blob container
az storage container create \
  --name "dataprotection-keys" \
  --account-name "<smx-prod-storage>" \
  --auth-mode login

# Grant managed identity Key Vault permissions
az keyvault set-policy \
  --name "<smx-prod-kv-name>" \
  --object-id "<smx-managed-identity-id>" \
  --key-permissions get unwrapKey wrapKey

# Grant managed identity Storage permissions
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee "<smx-managed-identity-id>" \
  --scope "/subscriptions/<prod-subscription-id>/resourceGroups/<smx-prod-rg>/providers/Microsoft.Storage/storageAccounts/<smx-prod-storage>"
```

**For HP2 (if needed):**
```bash
# Same pattern as SMX, replace with HP2 resource names
```

---

### Step 2: Configure SMX Production Environment Variables

**Critical: Use EntraExternalId AND AzureAd for compatibility**

```bash
az containerapp update \
  --name "<smx-prod-app-name>" \
  --resource-group "<smx-prod-rg>" \
  --replace-env-vars \
    "ASPNETCORE_ENVIRONMENT=Production" \
    "AzureAd__Instance=https://<prod-tenant-name>.ciamlogin.com/" \
    "AzureAd__Domain=<prod-tenant-name>.onmicrosoft.com" \
    "AzureAd__TenantId=<prod-tenant-id>" \
    "AzureAd__ClientId=<smx-prod-client-id>" \
    "AzureAd__ClientSecret=<smx-prod-client-secret>" \
    "AzureAd__CallbackPath=/signin-oidc" \
    "EntraExternalId__Instance=https://<prod-tenant-name>.ciamlogin.com/" \
    "EntraExternalId__Domain=<prod-tenant-name>.onmicrosoft.com" \
    "EntraExternalId__TenantId=<prod-tenant-id>" \
    "EntraExternalId__ClientId=<smx-prod-client-id>" \
    "EntraExternalId__ClientSecret=<smx-prod-client-secret>" \
    "DatabaseServer=<prod-sql-server>.database.windows.net" \
    "DatabaseName=<prod-corp-db-name>" \
    "DatabaseTenantId=<database-tenant-id>" \
    "KeyVaultUri=https://<smx-prod-kv-name>.vault.azure.net/" \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=<smx-prod-insights-connection-string>" \
    "StorageSettings__ConnectionString=$(az storage account show-connection-string --name <smx-prod-storage> --resource-group <smx-prod-rg> --query connectionString -o tsv)" \
    "DataProtection__BlobUri=https://<smx-prod-storage>.blob.core.windows.net/dataprotection-keys/keys.xml" \
    "DataProtection__KeyVaultUri=https://<smx-prod-kv-name>.vault.azure.net/" \
    "DataProtection__KeyId=https://<smx-prod-kv-name>.vault.azure.net/keys/dataprotection-keys" \
    "ConnectionStrings__CorpDatabase=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-corp-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "SMXCORE_CORP_DB_CONNECTION_STRING=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-corp-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__DefaultConnection=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-corp-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <smx-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "CommunicationServices__ConnectionString=$(az communication list-key --name <smx-prod-comms-name> --resource-group <smx-prod-rg> --query primaryConnectionString -o tsv)" \
    "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net" \
    "CsysUserMgmt__Invitation__BaseUrl=https://smx.recalibratex.net"
```

---

### Step 3: Configure HP2 Production Environment Variables

```bash
az containerapp update \
  --name "<hp2-prod-app-name>" \
  --resource-group "<hp2-prod-rg>" \
  --replace-env-vars \
    "ASPNETCORE_ENVIRONMENT=Production" \
    "AzureAd__Instance=https://<prod-tenant-name>.ciamlogin.com/" \
    "AzureAd__Domain=<prod-tenant-name>.onmicrosoft.com" \
    "AzureAd__TenantId=<prod-tenant-id>" \
    "AzureAd__ClientId=<hp2-prod-client-id>" \
    "AzureAd__ClientSecret=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name hp2-prod-client-secret --query value -o tsv)" \
    "AzureAd__CallbackPath=/signin-oidc" \
    "EntraExternalId__Instance=https://<prod-tenant-name>.ciamlogin.com/" \
    "EntraExternalId__Domain=<prod-tenant-name>.onmicrosoft.com" \
    "EntraExternalId__TenantId=<prod-tenant-id>" \
    "EntraExternalId__ClientId=<hp2-prod-client-id>" \
    "EntraExternalId__ClientSecret=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name hp2-prod-client-secret --query value -o tsv)" \
    "DatabaseServer=<prod-sql-server>.database.windows.net" \
    "DatabaseName=<prod-corp-db-name>" \
    "DatabaseNameHP2=<prod-hp2-db-name>" \
    "DatabaseTenantId=<database-tenant-id>" \
    "KeyVaultUri=https://<hp2-prod-kv-name>.vault.azure.net/" \
    "APPLICATIONINSIGHTS_CONNECTION_STRING=<hp2-prod-insights-connection-string>" \
    "ConnectionStrings__CorpDatabase=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-corp-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__HealthProvidersDatabase=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-hp2-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "ConnectionStrings__DefaultConnection=Server=tcp:<prod-sql-server>.database.windows.net,1433;Database=<prod-corp-db-name>;Authentication=Active Directory Service Principal;User ID=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-id --query value -o tsv);Password=$(az keyvault secret show --vault-name <hp2-prod-kv-name> --name db-prod-app-secret --query value -o tsv);Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" \
    "CommunicationServices__ConnectionString=$(az communication list-key --name <hp2-prod-comms-name> --resource-group <hp2-prod-rg> --query primaryConnectionString -o tsv)" \
    "CommunicationServices__FromAddress=DoNotReply@<azure-managed-domain>.azurecomm.net" \
    "CsysUserMgmt__Invitation__BaseUrl=https://hp2.recalibratex.net"
```

---

## ✅ Verification Steps

### 1. Check Application Startup
```bash
# SMX
az containerapp logs show --name "<smx-prod-app-name>" --resource-group "<smx-prod-rg>" --tail 30

# HP2
az containerapp logs show --name "<hp2-prod-app-name>" --resource-group "<hp2-prod-rg>" --tail 30
```

**Look for:**
- ✅ "Now listening on: http://[::]:80"
- ✅ "Application started"
- ❌ No DataProtection errors
- ❌ No authentication errors
- ❌ No database connection errors

### 2. Test Authentication
- [ ] Navigate to app URL
- [ ] Click Sign In
- [ ] Verify redirects to correct tenant (prod CIAM)
- [ ] Verify can sign in with production account
- [ ] Verify redirects back to app after login

### 3. Test Database Connectivity
- [ ] Login to app with authenticated user
- [ ] Navigate to `/system-diags`
- [ ] Verify all databases show as "Provisioned" (not "Not Provisioned")
- [ ] Click "Test Database Connectivity" button
- [ ] Verify all tests pass

### 4. Test Application Functionality
- [ ] Navigate key pages (no errors)
- [ ] Verify data loads from database
- [ ] Test create/update operations
- [ ] Check Application Insights for exceptions

### 5. Configure Custom Domains (Optional but Recommended)

**See CUSTOM-DOMAINS-SETUP.md for detailed instructions**

**SMX:**
```bash
# Add and bind custom domain
az containerapp hostname add --hostname "smx.recalibratex.net" --name "<smx-prod-app>" --resource-group "<smx-prod-rg>"
az containerapp hostname bind --hostname "smx.recalibratex.net" --name "<smx-prod-app>" --resource-group "<smx-prod-rg>" --environment "<smx-prod-env>" --validation-method CNAME

# Update app registration redirect URI
az ad app update --id "<smx-prod-client-id>" --web-redirect-uris "https://<default-hostname>/signin-oidc" "https://smx.recalibratex.net/signin-oidc"
```

**HP2:**
```bash
# Add and bind custom domain
az containerapp hostname add --hostname "hp2.recalibratex.net" --name "<hp2-prod-app>" --resource-group "<hp2-prod-rg>"
az containerapp hostname bind --hostname "hp2.recalibratex.net" --name "<hp2-prod-app>" --resource-group "<hp2-prod-rg>" --environment "<hp2-prod-env>" --validation-method CNAME

# Update app registration redirect URI
az ad app update --id "<hp2-prod-client-id>" --web-redirect-uris "https://<default-hostname>/signin-oidc" "https://hp2.recalibratex.net/signin-oidc"
```

**DNS Records Required (create before running above):**
- TXT: `asuid.smx` → `<verification-id>`
- CNAME: `smx` → `<container-app-default-hostname>`
- TXT: `asuid.hp2` → `<verification-id>`
- CNAME: `hp2` → `<container-app-default-hostname>`

---

## 🚨 Critical Lessons from QA Deployment

### 1. **Authentication Configuration**
- ✅ **MUST configure BOTH** `AzureAd__*` AND `EntraExternalId__*` variables
- ✅ **Use CIAM endpoint:** `https://<tenant>.ciamlogin.com/` (NOT `login.microsoftonline.com`)
- ❌ **Don't forget** CallbackPath: `/signin-oidc`

### 2. **DataProtection Configuration**
- ✅ **Three required components:**
  1. Blob container: `dataprotection-keys`
  2. Key Vault key: `dataprotection-keys`
  3. Three environment variables: `DataProtection__BlobUri`, `DataProtection__KeyVaultUri`, `DataProtection__KeyId`
- ✅ **BlobUri must include full path:** `/dataprotection-keys/keys.xml`
- ✅ **Managed identity needs Key Vault crypto permissions:** get, unwrapKey, wrapKey

### 3. **Database Configuration**
- ✅ **Use service principal authentication** (Active Directory Service Principal)
- ✅ **Three connection string variables needed:**
  - `ConnectionStrings__CorpDatabase`
  - `SMXCORE_CORP_DB_CONNECTION_STRING`
  - `ConnectionStrings__DefaultConnection`
- ✅ **For HP2 add:** `ConnectionStrings__HealthProvidersDatabase`
- ✅ **Service principal credentials from Key Vault:** `db-prod-app-id`, `db-prod-app-secret`

### 4. **Storage Configuration**
- ✅ **Enable Shared Key Access** on storage account
- ✅ **Grant managed identity:** Storage Blob Data Contributor role
- ✅ **Create containers BEFORE deployment**

### 5. Communication Services Configuration

**Three required environment variables:**
1. `CommunicationServices__ConnectionString` - Connection to Azure Communication Service
2. `CommunicationServices__FromAddress` - Sender email from linked domain (e.g., DoNotReply@domain.azurecomm.net)
3. `CsysUserMgmt__Invitation__BaseUrl` - Base URL for invitation links (e.g., https://smx.recalibratex.net)

**Service Creation Order:**
1. Create Communication Service
2. Create Email Service
3. Link Azure Managed Domain to Email Service
4. Link Domain to Communication Service
5. Get connection string and configure app

**⚠️ Don't forget these configurations:**
- **FromAddress** - Without it, emails will fail with "DomainNotLinked" error even if infrastructure is correct
- **BaseUrl** - Without it, invitation emails will contain wrong URLs (dev environment URLs instead of production)

**Reference:** See CsysUserMgmt README.md for configuration details.

### 6. **Common Gotchas**
- ❌ Don't use `DataProtection__BlobStorageUri` (wrong variable name)
- ❌ Don't forget to create blob containers (app won't create them)
- ❌ Don't mix dev/qa/prod tenant IDs in config
- ❌ Don't deploy without testing system-diags page
- ❌ Don't forget `CommunicationServices__FromAddress` environment variable
- ❌ Don't forget `CsysUserMgmt__Invitation__BaseUrl` environment variable (invitation emails will have wrong URLs)

---

## 📝 Post-Deployment Documentation

After successful deployment, update these documents:

1. **PRODUCTION-CONFIGURATION-REFERENCE.md** (create new)
   - All production resource names and IDs
   - All environment variable values
   - Quick deployment commands

2. **Update Phase docs:**
   - Production tenant info
   - Production app registration details
   - Production resource IDs

3. **Create PRODUCTION-TROUBLESHOOTING.md**
   - Common issues and fixes
   - Log查询 commands
   - Emergency rollback procedures

---

## 🎉 Success Criteria

**SMX Production Ready:**
- [ ] App starts without errors
- [ ] Authentication redirects to production CIAM tenant
- [ ] Users can sign in successfully
- [ ] System-diags shows all databases provisioned
- [ ] Database connectivity test passes
- [ ] No exceptions in Application Insights
- [ ] DataProtection keys stored successfully

**HP2 Production Ready:**
- [ ] App starts without errors
- [ ] Authentication redirects to production CIAM tenant
- [ ] Users can sign in successfully
- [ ] System-diags shows all databases provisioned (including HP2 database)
- [ ] Database connectivity test passes
- [ ] No exceptions in Application Insights

---

**Document Version:** 1.0  
**Created:** November 14, 2025  
**Based on:** Successful QA deployment  
**Status:** Ready for production deployment tomorrow
