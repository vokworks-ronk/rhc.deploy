# 🗄️ Phase 3: Database Tenant Setup

**Status:** ⏳ Waiting for Phases 1 & 2  
**Prerequisites:** Database tenant and subscription created  
**Estimated Time:** 45-60 minutes

---

## 📋 Overview

This phase sets up the isolated Database tenant with:
- QA SQL Server and databases
- Secure authentication (Managed Identity support)
- Network configuration
- Service principal for cross-tenant access
- Future production database infrastructure (placeholder)

**Key Security Principles:**
- ✅ Isolated tenant (no B2C identities)
- ✅ No SQL authentication (Managed Identity or Service Principal only)
- ✅ Entra ID admin configured
- ✅ Audit logging enabled
- ✅ Encrypted in transit and at rest

---

## 🎯 Checklist

### Pre-Configuration
- [ ] Verify database tenant created (`rhc-db-core.onmicrosoft.com`)
- [ ] Verify database subscription created (`rhc-db-core-sub`)
- [ ] Document tenant ID and subscription ID

### Resource Group Creation
- [ ] Create QA database resource group (`rhc-db-qa-rg`)
- [ ] Create Production database resource group (`rhc-db-prod-rg`) - placeholder

### QA SQL Server Setup
- [ ] Create SQL Server (`rhc-qa-sqlsvr`)
- [ ] Configure Entra ID admin (Ron)
- [ ] Disable SQL authentication
- [ ] Configure firewall rules
- [ ] Enable Microsoft Entra authentication only

### QA Database Creation
- [ ] Create `corp_db` database
- [ ] Create `hp2_db` database
- [ ] Configure database settings (tier, backup, etc.)

### Security Configuration
- [ ] Enable Advanced Data Security
- [ ] Configure audit logging
- [ ] Set up Log Analytics workspace
- [ ] Enable Microsoft Defender for SQL

### Service Principal Setup
- [ ] Create service principals for HP2 QA
- [ ] Create service principals for SMX QA
- [ ] Grant database access to service principals
- [ ] Document client IDs and secrets (Key Vault)

### Verification
- [ ] Test connection from Portal
- [ ] Verify Entra authentication works
- [ ] Verify SQL authentication blocked
- [ ] Update deployment-log.md

---

## 📝 Resource Information (Fill in after creation)

### Resource Groups

| Name | Location | Purpose | Status |
|------|----------|---------|--------|
| `rhc-db-qa-rg` | East US 2 | QA databases | ⬜ |
| `rhc-db-prod-rg` | East US 2 | Production databases (future) | ⬜ |

### SQL Servers

| Name | FQDN | Admin | Status |
|------|------|-------|--------|
| `rhc-qa-sqlsvr` | `rhc-qa-sqlsvr.database.windows.net` | Ron (Entra ID) | ⬜ |
| `rhc-prod-sqlsvr` | `rhc-prod-sqlsvr.database.windows.net` | Ron (Entra ID) | ⬜ Future |

### Databases

| Server | Database Name | Tier | Size | Purpose | Status |
|--------|---------------|------|------|---------|--------|
| `rhc-qa-sqlsvr` | `corp_db` | Standard S0 | 10 DTU | Shared/Corporate data | ⬜ |
| `rhc-qa-sqlsvr` | `hp2_db` | Standard S0 | 10 DTU | HP2 application data | ⬜ |

---

## 🔧 Step 1: Create Resource Groups

### Via Azure Portal

1. **Switch to Database Tenant**
   - Click profile icon → Switch directory
   - Select `rhc-db-core.onmicrosoft.com`

2. **Create QA Resource Group**
   - Search for "Resource groups"
   - Click **"+ Create"**
   - **Subscription:** `rhc-db-core-sub`
   - **Resource group name:** `rhc-db-qa-rg`
   - **Region:** `East US 2`
   - Click **"Review + create"** → **"Create"**

3. **Create Production Resource Group (Placeholder)**
   - Click **"+ Create"**
   - **Subscription:** `rhc-db-core-sub`
   - **Resource group name:** `rhc-db-prod-rg`
   - **Region:** `East US 2`
   - Click **"Review + create"** → **"Create"**

### Via Azure CLI

```bash
# Login to database tenant
az login --tenant rhc-db-core.onmicrosoft.com

# Set subscription context
az account set --subscription "rhc-db-core-sub"

# Create QA resource group
az group create \
  --name "rhc-db-qa-rg" \
  --location "eastus2" \
  --tags Environment=QA Purpose=Database Project=RHC

# Create Production resource group (placeholder)
az group create \
  --name "rhc-db-prod-rg" \
  --location "eastus2" \
  --tags Environment=Production Purpose=Database Project=RHC

# Verify
az group list --output table
```

### Via PowerShell

```powershell
# Connect to Azure
Connect-AzAccount -Tenant "rhc-db-core.onmicrosoft.com"

# Set subscription context
Set-AzContext -Subscription "rhc-db-core-sub"

# Create QA resource group
New-AzResourceGroup `
  -Name "rhc-db-qa-rg" `
  -Location "EastUS2" `
  -Tag @{Environment="QA"; Purpose="Database"; Project="RHC"}

# Create Production resource group
New-AzResourceGroup `
  -Name "rhc-db-prod-rg" `
  -Location "EastUS2" `
  -Tag @{Environment="Production"; Purpose="Database"; Project="RHC"}

# Verify
Get-AzResourceGroup | Format-Table
```

---

## 🔧 Step 2: Create QA SQL Server

### Via Azure Portal

1. **Navigate to SQL Servers**
   - Search for "SQL servers"
   - Click **"+ Create"**

2. **Basics Tab**
   - **Subscription:** `rhc-db-core-sub`
   - **Resource group:** `rhc-db-qa-rg`
   - **Server name:** `rhc-qa-sqlsvr`
   - **Location:** `East US 2`
   - **Authentication method:** Select **"Use Microsoft Entra-only authentication"**
   - **Set Entra admin:** Click "Set admin"
     - Search for your account (Ron)
     - Select and click "Select"
   - ⚠️ **Important:** Do NOT create SQL authentication login

3. **Networking Tab**
   - **Connectivity method:** Public endpoint (for now, can restrict later)
   - **Firewall rules:**
     - ✅ Allow Azure services and resources to access this server
     - ✅ Add your current client IP address (for testing)
   - **Connection policy:** Default
   - **Minimum TLS version:** 1.2

4. **Security Tab**
   - **Microsoft Defender for SQL:** Enable (for production-grade security)
   - **Ledger:** Off (unless you need immutable audit trail)

5. **Additional Settings Tab**
   - Leave defaults

6. **Tags**
   - Environment: `QA`
   - Purpose: `Database`
   - Project: `RHC`

7. **Review + Create**
   - Review all settings
   - Click **"Create"**
   - ⏳ Wait 3-5 minutes for deployment

### Via Azure CLI

```bash
# Get your Entra ID user object ID
$adminObjectId = az ad signed-in-user show --query id -o tsv

# Create SQL Server with Entra-only authentication
az sql server create \
  --name "rhc-qa-sqlsvr" \
  --resource-group "rhc-db-qa-rg" \
  --location "eastus2" \
  --enable-ad-only-auth \
  --external-admin-principal-type "User" \
  --external-admin-name "Ron" \
  --external-admin-sid $adminObjectId \
  --tags Environment=QA Purpose=Database Project=RHC

# Configure firewall to allow Azure services
az sql server firewall-rule create \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --name "AllowAzureServices" \
  --start-ip-address "0.0.0.0" \
  --end-ip-address "0.0.0.0"

# Add your current IP for testing
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
az sql server firewall-rule create \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --name "MyClientIP" \
  --start-ip-address $myIp \
  --end-ip-address $myIp

# Verify
az sql server show --name "rhc-qa-sqlsvr" --resource-group "rhc-db-qa-rg"
```

### Via PowerShell

```powershell
# Get your Entra ID object ID
$adminObjectId = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account).Id

# Create SQL Server
New-AzSqlServer `
  -ServerName "rhc-qa-sqlsvr" `
  -ResourceGroupName "rhc-db-qa-rg" `
  -Location "EastUS2" `
  -ExternalAdminName "Ron" `
  -ExternalAdminSID $adminObjectId `
  -EnableActiveDirectoryOnlyAuthentication `
  -Tag @{Environment="QA"; Purpose="Database"; Project="RHC"}

# Configure firewall
New-AzSqlServerFirewallRule `
  -ResourceGroupName "rhc-db-qa-rg" `
  -ServerName "rhc-qa-sqlsvr" `
  -FirewallRuleName "AllowAzureServices" `
  -StartIpAddress "0.0.0.0" `
  -EndIpAddress "0.0.0.0"

# Add your IP
$myIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
New-AzSqlServerFirewallRule `
  -ResourceGroupName "rhc-db-qa-rg" `
  -ServerName "rhc-qa-sqlsvr" `
  -FirewallRuleName "MyClientIP" `
  -StartIpAddress $myIp `
  -EndIpAddress $myIp
```

---

## 🔧 Step 3: Create QA Databases

### Create corp_db (Corporate/Shared Database)

#### Via Azure Portal

1. Navigate to the SQL Server (`rhc-qa-sqlsvr`)
2. Click **"+ Create database"**
3. **Basics:**
   - **Database name:** `corp_db`
   - **Compute + storage:** Click "Configure database"
     - Service tier: **Standard**
     - DTUs: **10 DTUs (S0)**
     - Data max size: **250 GB** (default)
     - Click **Apply**
   - **Backup storage redundancy:** Locally-redundant (cheaper for QA)
4. **Networking:** Inherited from server (public endpoint)
5. **Security:** Leave defaults
6. **Additional settings:**
   - **Use existing data:** None
   - **Collation:** SQL_Latin1_General_CP1_CI_AS (default)
7. **Tags:** Environment=QA, Purpose=Corporate, Project=RHC
8. **Review + create** → **Create**

#### Via Azure CLI

```bash
# Create corp_db
az sql db create \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --name "corp_db" \
  --edition "Standard" \
  --capacity 10 \
  --max-size 250GB \
  --backup-storage-redundancy "Local" \
  --tags Environment=QA Purpose=Corporate Project=RHC

# Verify
az sql db show \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --name "corp_db"
```

#### Via PowerShell

```powershell
# Create corp_db
New-AzSqlDatabase `
  -ResourceGroupName "rhc-db-qa-rg" `
  -ServerName "rhc-qa-sqlsvr" `
  -DatabaseName "corp_db" `
  -Edition "Standard" `
  -RequestedServiceObjectiveName "S0" `
  -MaxSizeBytes 250GB `
  -BackupStorageRedundancy "Local" `
  -Tag @{Environment="QA"; Purpose="Corporate"; Project="RHC"}
```

---

### Create hp2_db (HP2 Application Database)

Repeat the same process for the HP2 database:

#### Via Azure CLI

```bash
# Create hp2_db
az sql db create \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --name "hp2_db" \
  --edition "Standard" \
  --capacity 10 \
  --max-size 250GB \
  --backup-storage-redundancy "Local" \
  --tags Environment=QA Purpose=HP2 Project=RHC
```

#### Via PowerShell

```powershell
# Create hp2_db
New-AzSqlDatabase `
  -ResourceGroupName "rhc-db-qa-rg" `
  -ServerName "rhc-qa-sqlsvr" `
  -DatabaseName "hp2_db" `
  -Edition "Standard" `
  -RequestedServiceObjectiveName "S0" `
  -MaxSizeBytes 250GB `
  -BackupStorageRedundancy "Local" `
  -Tag @{Environment="QA"; Purpose="HP2"; Project="RHC"}
```

---

## 🔧 Step 4: Configure Audit Logging

### Create Log Analytics Workspace

#### Via Azure CLI

```bash
# Create Log Analytics workspace for audit logs
az monitor log-analytics workspace create \
  --resource-group "rhc-db-qa-rg" \
  --workspace-name "rhc-qa-db-logs" \
  --location "eastus2" \
  --tags Environment=QA Purpose=Auditing Project=RHC

# Get workspace ID
$workspaceId = az monitor log-analytics workspace show \
  --resource-group "rhc-db-qa-rg" \
  --workspace-name "rhc-qa-db-logs" \
  --query id -o tsv
```

### Enable SQL Auditing

#### Via Azure Portal

1. Navigate to SQL Server (`rhc-qa-sqlsvr`)
2. Click **"Auditing"** under Security
3. Toggle **"Enable Azure SQL Auditing"** to **ON**
4. **Audit log destination:**
   - ✅ Log Analytics
   - Select the workspace: `rhc-qa-db-logs`
5. **Audited event types:** Select all (default)
6. Click **"Save"**

#### Via Azure CLI

```bash
# Enable server-level auditing
az sql server audit-policy update \
  --resource-group "rhc-db-qa-rg" \
  --name "rhc-qa-sqlsvr" \
  --state Enabled \
  --log-analytics-target-state Enabled \
  --log-analytics-workspace-resource-id $workspaceId
```

---

## 🔧 Step 5: Enable Microsoft Defender for SQL

### Via Azure Portal

1. Navigate to SQL Server (`rhc-qa-sqlsvr`)
2. Click **"Microsoft Defender for Cloud"** under Security
3. Click **"Enable Microsoft Defender for SQL"**
4. **Settings:**
   - **Vulnerability assessment:** Configure storage account (or use default)
   - **Advanced Threat Protection:** Enabled
   - **Email notifications:** Add your email
5. Click **"Save"**

### Via Azure CLI

```bash
# Enable Microsoft Defender for SQL
az security pricing create \
  --name "SqlServers" \
  --tier "Standard"

# Configure advanced threat protection
az sql server threat-policy update \
  --resource-group "rhc-db-qa-rg" \
  --server "rhc-qa-sqlsvr" \
  --state Enabled \
  --email-account-admins Enabled \
  --email-addresses "ron@recalibratehealthcare.com"
```

---

## 🔐 Step 6: Create Service Principals for Cross-Tenant Access

We need service principals in the B2C QA tenant that will access the databases.

### Create HP2 QA Service Principal

#### Via Azure CLI (in B2C QA Tenant)

```bash
# Switch to B2C QA tenant
az login --tenant rhc-b2c-qa.onmicrosoft.com

# Create service principal for HP2
az ad sp create-for-rbac \
  --name "hp2-qa-db-access" \
  --role "Contributor" \
  --scopes "/subscriptions/<qa-subscription-id>" \
  --years 2

# Save the output:
# {
#   "appId": "xxxxx-xxxxx-xxxxx-xxxxx",
#   "password": "xxxxx~xxxxx~xxxxx",
#   "tenant": "xxxxx-xxxxx-xxxxx-xxxxx"
# }

# Document the appId (Client ID) and password (Client Secret)
```

### Create SMX QA Service Principal

```bash
# Still in B2C QA tenant
az ad sp create-for-rbac \
  --name "smx-qa-db-access" \
  --role "Contributor" \
  --scopes "/subscriptions/<qa-subscription-id>" \
  --years 2

# Save the output
```

### Grant Database Access to Service Principals

Now switch to Database tenant and grant SQL access:

```sql
-- Connect to rhc-qa-sqlsvr.database.windows.net
-- Use corp_db database
-- Use Azure Data Studio or SQL Server Management Studio
-- Authenticate with your Entra ID account (Ron)

-- For HP2 service principal
CREATE USER [hp2-qa-db-access] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [hp2-qa-db-access];
ALTER ROLE db_datawriter ADD MEMBER [hp2-qa-db-access];
GO

-- For SMX service principal
CREATE USER [smx-qa-db-access] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [smx-qa-db-access];
ALTER ROLE db_datawriter ADD MEMBER [smx-qa-db-access];
GO

-- Switch to hp2_db database
USE hp2_db;
GO

-- Grant HP2 service principal access
CREATE USER [hp2-qa-db-access] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [hp2-qa-db-access];
ALTER ROLE db_datawriter ADD MEMBER [hp2-qa-db-access];
GO
```

---

## 🔧 Alternative: Use Managed Identity (Preferred)

Instead of service principals, use Managed Identity:

### Steps (To be completed in Phase 5 when creating Container Apps):

1. Create Container Apps with Managed Identity enabled
2. Get the Managed Identity Object ID
3. Grant database access to Managed Identity:

```sql
-- In each database
CREATE USER [hp2-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [hp2-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [hp2-qa-app];
```

**Note:** We'll complete Managed Identity setup in Phase 5 when deploying Container Apps.

---

## 📊 Connection String Examples

### For Service Principal Authentication

```csharp
Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;
Database=corp_db;
Authentication=Active Directory Service Principal;
User ID=<client-id>@<b2c-qa-tenant-id>;
Password=<client-secret>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

### For Managed Identity Authentication (Preferred)

```csharp
Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;
Database=corp_db;
Authentication=Active Directory Managed Identity;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

---

## 🔍 Verification Steps

### 1. Test Connection from Azure Portal

1. Navigate to `corp_db` database
2. Click **"Query editor"** in left menu
3. Authenticate with your Entra ID account
4. Run a test query:
   ```sql
   SELECT @@VERSION;
   SELECT DB_NAME();
   ```
5. Should succeed ✅

### 2. Verify SQL Authentication is Disabled

Try connecting with SQL authentication (should fail):

```bash
# This should FAIL with "Login failed"
sqlcmd -S rhc-qa-sqlsvr.database.windows.net -d corp_db -U sqladmin -P password
```

### 3. Verify Audit Logging

1. Navigate to SQL Server → **Auditing**
2. Click **"View audit logs"**
3. Should see connection attempts logged

### 4. List All Resources

```bash
# Switch to database tenant
az login --tenant rhc-db-core.onmicrosoft.com
az account set --subscription "rhc-db-core-sub"

# List all resources in QA resource group
az resource list --resource-group "rhc-db-qa-rg" --output table

# Should show:
# - SQL Server: rhc-qa-sqlsvr
# - Database: corp_db
# - Database: hp2_db
# - Log Analytics: rhc-qa-db-logs
```

---

## 📝 Document Service Principal Credentials

⚠️ **CRITICAL:** Store service principal credentials securely!

### Store in Key Vault (Best Practice)

We'll create Key Vaults in Phase 5, but for now document:

**HP2 QA Service Principal:**
- Client ID: `_________________________`
- Client Secret: `_________________________`
- Tenant ID: `_________________________`

**SMX QA Service Principal:**
- Client ID: `_________________________`
- Client Secret: `_________________________`
- Tenant ID: `_________________________`

**TODO:** Move these to Azure Key Vault in Phase 5.

---

## ⚠️ Common Issues & Troubleshooting

### Issue: "Cannot connect to server"

**Solution:**
1. Check firewall rules include your IP
2. Verify "Allow Azure services" is enabled
3. Check you're using Entra authentication (not SQL auth)

### Issue: "Login failed for user"

**Solution:**
1. Verify you're an Entra admin on the server
2. Check you're in the correct tenant
3. Ensure Entra-only authentication is enabled

### Issue: "CREATE USER FROM EXTERNAL PROVIDER failed"

**Solution:**
1. Verify service principal exists in B2C tenant
2. Check service principal name exactly matches
3. Ensure you're connected with Entra admin account

### Issue: "Auditing not logging"

**Solution:**
1. Wait 5-10 minutes for logs to appear
2. Verify Log Analytics workspace is linked
3. Check audit policy is enabled at server level

---

## 📊 What We've Accomplished

After completing this phase:

✅ **Database Infrastructure Created:**
- Isolated database tenant configured
- QA SQL Server with Entra-only authentication
- Two databases: `corp_db` and `hp2_db`

✅ **Security Configured:**
- SQL authentication disabled
- Audit logging enabled
- Microsoft Defender for SQL enabled
- Firewall rules configured

✅ **Cross-Tenant Access Setup:**
- Service principals created (or Managed Identity prepared)
- Database permissions granted
- Connection strings documented

✅ **Ready for Applications:**
- Databases ready to receive connections
- Secure authentication methods in place
- Monitoring and security enabled

---

## 📝 Update Deployment Log

```markdown
## 2025-10-XX - Phase 3: Database Tenant Setup

**Completed by:** Ron

### Infrastructure Created
- [x] Resource groups: rhc-db-qa-rg, rhc-db-prod-rg
- [x] SQL Server: rhc-qa-sqlsvr.database.windows.net
- [x] Databases: corp_db, hp2_db
- [x] Log Analytics workspace for auditing

### Security Configured
- [x] Entra-only authentication enabled
- [x] SQL authentication disabled
- [x] Audit logging enabled
- [x] Microsoft Defender for SQL enabled
- [x] Service principals created and granted access

**Status:** ✅ Complete
**Issues:** None
**Notes:** All databases created and secured, ready for app deployment
```

---

## ➡️ Next Steps

Once database infrastructure is complete:

**👉 Proceed to:** `04-b2c-tenant-setup.md`

This will configure the B2C QA tenant with user flows, MFA, and authentication policies.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** ⏳ Waiting for Phases 1 & 2
