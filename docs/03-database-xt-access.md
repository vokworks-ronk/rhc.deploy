# 🔐 Cross-Tenant Database Access Architecture

**Status:** ✅ Infrastructure Complete | ⚠️ SQL Configuration Required  
**Last Updated:** November 12, 2025

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

### Step 1: Use Service Principal for QA (Immediate)

Store the service principal credentials:

```bash
# Get the client secret (if not already stored)
# This was generated in Phase 3

# Store in HP2 Key Vault
az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv-2025" \
  --name "db-qa-app-id" \
  --value "694db84f-ab2d-4410-b94e-92dbc8a24205"

az keyvault secret set \
  --vault-name "rhc-hp2-qa-kv-2025" \
  --name "db-qa-app-secret" \
  --value "<client-secret-from-phase-3>"

# Store in SMX Key Vault
az keyvault secret set \
  --vault-name "rhc-smx-qa-kv-2025" \
  --name "db-qa-app-id" \
  --value "694db84f-ab2d-4410-b94e-92dbc8a24205"

az keyvault secret set \
  --vault-name "rhc-smx-qa-kv-2025" \
  --name "db-qa-app-secret" \
  --value "<client-secret-from-phase-3>"
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

**Current State:**
- ✅ Database infrastructure ready (Phase 3)
- ✅ Service principal created and configured (`app-qa-db-access`)
- ✅ Database users created in both databases (`db-qa-app-users`)
- ✅ Container Apps with managed identities created (Phase 5)
- ⚠️ Database credentials not yet in Key Vault

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

**Related Documents:**
- [03-database-tenant-setup.md](./03-database-tenant-setup.md) - Database infrastructure and service principals
- [05-resource-groups-and-services.md](./05-resource-groups-and-services.md) - Container Apps and managed identities