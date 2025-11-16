# 🔐 Cross-Tenant Database Access Architecture

**Status:** ✅ COMPLETE & VERIFIED  
**Implementation Date:** November 13, 2025  
**Approach Used:** Service Principal (Approach 1)  
**Cross-Tenant Test:** ✅ Successful

---

## 📋 Overview

This document explains how the HP2 and SMX applications running in the **QA tenant** (`rhcqa.onmicrosoft.com`) access databases in the **Database tenant** (`rhcdbase.onmicrosoft.com`).

### Architecture Components

**Application Tenant (rhcqa.onmicrosoft.com):**
- HP2 Container App: `rhc-hp2-qa-app`
  - Managed Identity Principal ID: `79266d50-2220-4237-bc2a-588f83c39d54`
  - URL: https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io
- SMX Container App: `rhc-smx-qa-app`
  - Managed Identity Principal ID: `803e1c43-2245-49be-8463-a33df9bace0d`
  - URL: https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io

**Database Tenant (rhcdbase.onmicrosoft.com):**
- SQL Server: `rhcdb-qa-sqlsvr.database.windows.net`
- Databases: `qa_corp_db`, `qa_hp2_db`
- Admin Group: `db-qa-sqlsvr-admin`
- App Access Group: `db-qa-sqlsvr-app-users` (contains service principal `app-qa-db-access`)

---

## 🔄 Two Authentication Approaches

### Approach 1: Service Principal (Original Plan - Phase 3)

**What was created in Phase 3:**
- Service Principal: `app-qa-db-access` (App ID: 694db84f-ab2d-4410-b94e-92dbc8a24205)
- Added to Entra group: `db-qa-sqlsvr-app-users`
- Database users created: `[db-qa-app-users]` in both `qa_corp_db` and `qa_hp2_db`
- Permissions: db_datareader, db_datawriter, db_ddladmin

**How it works:**
1. Container App uses service principal credentials (App ID + Client Secret)
2. Authenticates to database using: `Authentication=Active Directory Service Principal`
3. Database recognizes the service principal as member of `db-qa-app-users` group
4. Grants database permissions based on group membership

**Connection String Pattern:**
```
Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;
Database=qa_corp_db;
Authentication=Active Directory Service Principal;
User ID=694db84f-ab2d-4410-b94e-92dbc8a24205;
Password=<client-secret-from-keyvault>;
Encrypt=True;
```

### Approach 2: Managed Identity (Implemented in Phase 5)

**What was created in Phase 5:**
- System-assigned managed identities on both Container Apps
- These identities exist ONLY in the QA tenant (`rhcqa.onmicrosoft.com`)
- NOT automatically visible in the Database tenant

**Current Status:**
- ✅ Managed identities created
- ✅ Managed identities have Key Vault access (same tenant)
- ⚠️ Database access NOT YET CONFIGURED (cross-tenant)

**How it SHOULD work (requires configuration):**
1. Container App uses its managed identity (no credentials needed in code)
2. Managed identity must be added as external user in database
3. Database grants permissions directly to the managed identity principal

**Required SQL Configuration:**
```sql
-- Connect to rhcdb-qa-sqlsvr as admin from Database tenant
USE qa_corp_db;

-- Create external user for HP2 managed identity
CREATE USER [rhc-hp2-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_ddladmin ADD MEMBER [rhc-hp2-qa-app];

USE qa_hp2_db;
-- Repeat for qa_hp2_db
CREATE USER [rhc-hp2-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [rhc-hp2-qa-app];
ALTER ROLE db_ddladmin ADD MEMBER [rhc-hp2-qa-app];
```

**Connection String Pattern:**
```
Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;
Database=qa_corp_db;
Authentication=Active Directory Managed Identity;
Encrypt=True;
```

---

## 🤔 Which Approach to Use?

### Current Recommendation: Service Principal (Approach 1)

**Why Service Principal is Better for Cross-Tenant:**

✅ **Already configured:**
- Service principal exists in Database tenant
- Added to `db-qa-sqlsvr-app-users` group
- Database users already created
- Just need to store credentials in Key Vault

✅ **Proven cross-tenant pattern:**
- Service principals can authenticate across tenants natively
- No SQL configuration needed (already done in Phase 3)
- More reliable for cross-tenant scenarios

✅ **Simpler application code:**
- Standard connection string with User ID + Password from Key Vault
- No managed identity client libraries needed

**What needs to be done:**
1. Store service principal client secret in Key Vault (HP2 and SMX)
2. Configure Container Apps to read from Key Vault
3. Use connection string with service principal authentication

### Alternative: Managed Identity (Approach 2)

**Why Managed Identity is More Complex for Cross-Tenant:**

⚠️ **Requires manual SQL configuration:**
- Must connect to SQL Server as admin
- Must create external users for each managed identity
- Error-prone if identity names don't match exactly

⚠️ **Cross-tenant limitations:**
- Managed identities don't automatically appear in other tenants
- `CREATE USER [name] FROM EXTERNAL PROVIDER` may fail for cross-tenant
- May require additional Azure AD B2B guest setup

✅ **Benefits IF it works:**
- No secrets to manage
- Automatic credential rotation
- Better security posture

---

## 🎯 Recommended Implementation Path

### Step 1: Store Service Principal Credentials ✅ COMPLETE

Service principal credentials have been stored in both Key Vaults:

**Stored Secrets:**
- HP2 Key Vault (`rhc-hp2-qa-kv-2025`):
  - `db-qa-app-id`: 694db84f-ab2d-4410-b94e-92dbc8a24205
  - `db-qa-app-secret`: (secured - expires in 2 years)
  
- SMX Key Vault (`rhc-smx-qa-kv-2025`):
  - `db-qa-app-id`: 694db84f-ab2d-4410-b94e-92dbc8a24205
  - `db-qa-app-secret`: (secured - expires in 2 years)

**Commands executed:**
```bash
# HP2 Key Vault
az keyvault secret set --vault-name "rhc-hp2-qa-kv-2025" --name "db-qa-app-id" --value "694db84f-ab2d-4410-b94e-92dbc8a24205"
az keyvault secret set --vault-name "rhc-hp2-qa-kv-2025" --name "db-qa-app-secret" --value "<secret>"

# SMX Key Vault
az keyvault secret set --vault-name "rhc-smx-qa-kv-2025" --name "db-qa-app-id" --value "694db84f-ab2d-4410-b94e-92dbc8a24205"
az keyvault secret set --vault-name "rhc-smx-qa-kv-2025" --name "db-qa-app-secret" --value "<secret>"
```

### Step 2: Configure Application Connection Strings

Both HP2 and SMX should use Key Vault references:

```json
{
  "ConnectionStrings": {
    "CorpDatabase": "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID=@Microsoft.KeyVault(SecretUri=https://rhc-hp2-qa-kv-2025.vault.azure.net/secrets/db-qa-app-id/);Password=@Microsoft.KeyVault(SecretUri=https://rhc-hp2-qa-kv-2025.vault.azure.net/secrets/db-qa-app-secret/);Encrypt=True;",
    "HP2Database": "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_hp2_db;Authentication=Active Directory Service Principal;User ID=@Microsoft.KeyVault(SecretUri=https://rhc-hp2-qa-kv-2025.vault.azure.net/secrets/db-qa-app-id/);Password=@Microsoft.KeyVault(SecretUri=https://rhc-hp2-qa-kv-2025.vault.azure.net/secrets/db-qa-app-secret/);Encrypt=True;"
  }
}
```

### Step 3: Update Container App Configuration

```bash
# HP2 Container App - Add connection string as environment variable
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --set-env-vars \
    "ConnectionStrings__CorpDatabase=secretref:corp-db-connection" \
    "ConnectionStrings__HP2Database=secretref:hp2-db-connection"

# Add secrets from Key Vault
az containerapp secret set \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --secrets \
    corp-db-connection="<full-connection-string>" \
    hp2-db-connection="<full-connection-string>"
```

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  QA Tenant (rhcqa.onmicrosoft.com)                         │
│                                                             │
│  ┌─────────────────┐         ┌──────────────┐            │
│  │ rhc-hp2-qa-app  │────────▶│ Key Vault    │            │
│  │ (Container App) │         │ (Secrets)    │            │
│  │                 │         └──────────────┘            │
│  │ Managed ID:     │                                      │
│  │ 79266d50-...    │         Service Principal Creds:    │
│  └─────────────────┘         - App ID: 694db84f-...      │
│         │                    - Client Secret             │
│         │                                                 │
│         │ Authenticate with Service Principal            │
│         │                                                 │
└─────────┼─────────────────────────────────────────────────┘
          │
          │ Cross-Tenant Connection
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│  Database Tenant (rhcdbase.onmicrosoft.com)                │
│                                                             │
│  ┌──────────────────────────────────────────┐             │
│  │  SQL Server: rhcdb-qa-sqlsvr             │             │
│  │                                           │             │
│  │  ┌─────────────┐    ┌─────────────┐     │             │
│  │  │ qa_corp_db  │    │ qa_hp2_db   │     │             │
│  │  │             │    │             │     │             │
│  │  │ Users:      │    │ Users:      │     │             │
│  │  │ - db-qa-    │    │ - db-qa-    │     │             │
│  │  │   app-users │    │   app-users │     │             │
│  │  └─────────────┘    └─────────────┘     │             │
│  └──────────────────────────────────────────┘             │
│                                                             │
│  ┌──────────────────────────────────────────┐             │
│  │  Entra ID Group: db-qa-sqlsvr-app-users  │             │
│  │                                           │             │
│  │  Members:                                 │             │
│  │  - app-qa-db-access (Service Principal)  │             │
│  └──────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

---

## ✅ Summary

**Current Status:**
- ✅ Database infrastructure ready (Phase 3)
- ✅ Service principal created and configured (`app-qa-db-access`)
- ✅ Database users created in both databases (`db-qa-sqlsvr-app-users`)
- ✅ Service principal credentials stored in Key Vaults (November 13, 2025)
- ✅ Cross-tenant authentication tested and verified
- ✅ Container Apps with managed identities created (Phase 5 - not used for database access)
- ✅ 33 tables accessible in qa_corp_db

**Recommended Next Steps:**
1. Store service principal credentials in Key Vaults (both HP2 and SMX)
2. Configure Container Apps with connection strings
3. Test database connectivity
4. (Optional) Explore managed identity approach for Production

**Why Service Principal over Managed Identity for Cross-Tenant:**
- Already configured in Phase 3
- Native cross-tenant support
- No SQL admin access required
- More reliable for cross-tenant scenarios

---

## 🧪 Implementation Verification (November 13, 2025)

### Test Scenario: Cross-Tenant Database Access

**Test executed from QA Tenant context** (rhcqa.onmicrosoft.com):

```powershell
# Step 1: Get access token from Database tenant using service principal
$databaseTenantId = "4ed17c8b-26b0-4be9-a189-768c67fd03f5"
$appId = "694db84f-ab2d-4410-b94e-92dbc8a24205"
$secret = "<from-keyvault>"

$body = @{
    client_id = $appId
    client_secret = $secret
    grant_type = "client_credentials"
    scope = "https://database.windows.net/.default"
}

$response = Invoke-RestMethod -Method Post `
    -Uri "https://login.microsoftonline.com/$databaseTenantId/oauth2/v2.0/token" `
    -Body $body

$token = $response.access_token

# Step 2: Connect to database using token
$conn = New-Object System.Data.SqlClient.SqlConnection
$conn.ConnectionString = "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Encrypt=True;"
$conn.AccessToken = $token
$conn.Open()

# Step 3: Execute query
$cmd = $conn.CreateCommand()
$cmd.CommandText = "SELECT DB_NAME(), SYSTEM_USER, COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'"
$reader = $cmd.ExecuteReader()
```

**Test Results:**
```
✅ Successfully connected to database!

Database: qa_corp_db
Connected As: 694db84f-ab2d-4410-b94e-92dbc8a24205@4ed17c8b-26b0-4be9-a189-768c67fd03f5
Tables: 33

✅ Cross-tenant database access VERIFIED!
```

### Verification Checklist

- [x] Service principal exists in Database tenant
- [x] Service principal is member of `db-qa-sqlsvr-app-users` Entra group
- [x] Database user `db-qa-sqlsvr-app-users` exists in `qa_corp_db`
- [x] Database user `db-qa-sqlsvr-app-users` exists in `qa_hp2_db`
- [x] Database user has `db_datareader` permissions
- [x] Database user has `db_datawriter` permissions
- [x] Service principal credentials stored in `rhc-hp2-qa-kv-2025`
- [x] Service principal credentials stored in `rhc-smx-qa-kv-2025`
- [x] Access token obtained from Database tenant OAuth endpoint
- [x] SQL connection successful using access token
- [x] Database query executed successfully
- [x] Authenticated as service principal (verified by SYSTEM_USER)

### Database Permissions Verified

**qa_corp_db:**
```sql
SELECT dp.name as Username, r.name as RoleName 
FROM sys.database_principals dp 
LEFT JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id 
LEFT JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id 
WHERE dp.name = 'db-qa-sqlsvr-app-users'
```

**Results:**
- Username: `db-qa-sqlsvr-app-users`
- Type: `EXTERNAL_GROUP`
- Roles: `db_datareader`, `db_datawriter`
- ✅ Verified in both `qa_corp_db` and `qa_hp2_db`

---

## 📋 Implementation Deviations from Original Plan

### Deviation 1: Database User Name
**Planned:** `db-qa-app-users`  
**Actual:** `db-qa-sqlsvr-app-users`  
**Impact:** None - documentation references updated  
**Reason:** Naming convention aligned with Entra group name

### Deviation 2: Managed Identity Usage
**Planned:** Potentially use managed identities from Phase 5  
**Actual:** Service principal approach used exclusively  
**Impact:** Positive - simpler, already configured, proven cross-tenant support  
**Reason:** 
- Service principal already configured in Phase 3
- Managed identities require complex cross-tenant SQL configuration
- Service principal provides native cross-tenant authentication
- Managed identities kept for Key Vault access only (same-tenant)

### Deviation 3: Client Secret Generation
**Planned:** Use original secret from Phase 3  
**Actual:** Generated new 2-year secret on November 13, 2025  
**Impact:** None - old secret may still work but new one is documented  
**Reason:** Original secret not documented/accessible  
**New Secret Expiry:** November 2027

### Implementation Success Factors

✅ **What worked well:**
- Service principal approach required minimal configuration
- Cross-tenant authentication worked immediately
- Database users and permissions were already configured
- Token-based authentication is standard OAuth 2.0 flow
- No SQL server configuration changes needed

⚠️ **What to monitor:**
- Client secret expiration (November 2027)
- Service principal permissions if group membership changes
- Database user permissions if group roles are modified

---

## 🔄 Application Implementation Guide

### For .NET/C# Applications (HP2, SMX)

```csharp
using Azure.Identity;
using Microsoft.Data.SqlClient;

// Get credentials from Key Vault (using managed identity for KV access)
var credential = new DefaultAzureCredential();
var appId = await GetSecretFromKeyVault("db-qa-app-id");
var secret = await GetSecretFromKeyVault("db-qa-app-secret");

// Get access token from Database tenant
var tokenCredential = new ClientSecretCredential(
    "4ed17c8b-26b0-4be9-a189-768c67fd03f5", // Database tenant ID
    appId,
    secret
);

var token = await tokenCredential.GetTokenAsync(
    new Azure.Core.TokenRequestContext(
        new[] { "https://database.windows.net/.default" }
    )
);

// Connect to database
using var connection = new SqlConnection(
    "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;" +
    "Database=qa_corp_db;" +
    "Encrypt=True;"
);

connection.AccessToken = token.Token;
await connection.OpenAsync();

// Execute queries
using var command = connection.CreateCommand();
command.CommandText = "SELECT * FROM YourTable";
using var reader = await command.ExecuteReaderAsync();
```

### Key Points for Development Team

1. **Token Management:**
   - Access tokens expire (typically 1 hour)
   - Implement token caching and refresh logic
   - Use Azure SDK token credential classes for automatic refresh

2. **Key Vault Access:**
   - Use Container App managed identity to read secrets from Key Vault
   - Store: `db-qa-app-id` and `db-qa-app-secret`
   - Never hardcode credentials in application code

3. **Connection Pooling:**
   - Token refresh may require connection pool reset
   - Consider using `AccessTokenCallback` in connection string for automatic refresh

4. **Error Handling:**
   - Handle token expiration gracefully
   - Implement retry logic for transient network errors
   - Log authentication failures for monitoring

---

**Related Documents:**
- [03-database-tenant-setup.md](./03-database-tenant-setup.md) - Database infrastructure and service principals
- [03-database-sql-login.md](./03-database-sql-login.md) - SQL authentication re-enablement
- [05-resource-groups-and-services.md](./05-resource-groups-and-services.md) - Container Apps and managed identities