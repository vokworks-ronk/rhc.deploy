# 🗄️ Phase 3: Database Tenant Setup

**Status:** 🚀 Ready to Execute  
**Prerequisites:** Database tenant and subscription created ✅  
**Estimated Time:** 60-90 minutes (3 environments)

---

## 📋 Overview

This phase sets up the isolated Database tenant with **three separate environments**:

### **Environment Structure:**

1. **LAM (Large Audience Model)** - Development/Load Testing
   - Resource Group: `db-lam-rg`
   - SQL Server: `rhcdb-lam-sqlsvr`
   - Database: `lam_db`

2. **QA (Quality Assurance)** - Testing Environment
   - Resource Group: `db-qa-rg`
   - SQL Server: `rhcdb-qa-sqlsvr`
   - Databases: `qa_corp_db`, `qa_hm2_db`

3. **Production** - Live Environment
   - Resource Group: `db-prod-rg`
   - SQL Server: `rhcdb-prod-sqlsvr`
   - Databases: `prod_corp_db`, `prod_hm2_db`

**Key Security Principles:**
- ✅ Isolated tenant (no External ID identities)
- ✅ No SQL authentication (Entra ID authentication only)
- ✅ Entra ID admin configured
- ✅ Audit logging enabled
- ✅ Encrypted in transit and at rest
- ✅ Environment isolation via separate resource groups

---

## 🎯 Checklist

### Pre-Configuration
- [X] Verify database tenant created (`rhcdb.onmicrosoft.com`)
- [X] Verify database subscription created (`subs-rhcdb`)
- [X] Document tenant ID and subscription ID

### Resource Group Creation
- [ ] Create LAM resource group (`db-lam-rg`)
- [ ] Create QA resource group (`db-qa-rg`)
- [ ] Create Production resource group (`db-prod-rg`)

### LAM Environment Setup
- [ ] Create SQL Server (`rhcdb-lam-sqlsvr`)
- [ ] Configure Entra ID admin (Ron)
- [ ] Disable SQL authentication
- [ ] Configure firewall rules
- [ ] Create `lam_db` database

### QA Environment Setup
- [ ] Create SQL Server (`rhcdb-qa-sqlsvr`)
- [ ] Configure Entra ID admin (Ron)
- [ ] Disable SQL authentication
- [ ] Configure firewall rules
- [ ] Create `qa_corp_db` database
- [ ] Create `qa_hm2_db` database

### Production Environment Setup
- [ ] Create SQL Server (`rhcdb-prod-sqlsvr`)
- [ ] Configure Entra ID admin (Ron)
- [ ] Disable SQL authentication
- [ ] Configure firewall rules
- [ ] Create `prod_corp_db` database
- [ ] Create `prod_hm2_db` database

### Security Configuration (All Environments)
- [ ] Enable Advanced Data Security
- [ ] Configure audit logging
- [ ] Set up Log Analytics workspace
- [ ] Enable Microsoft Defender for SQL

### Service Principal Setup
- [ ] Create service principals for LAM apps
- [ ] Create service principals for QA apps
- [ ] Create service principals for Production apps
- [ ] Grant database access to service principals
- [ ] Document client IDs and secrets (Key Vault)

### Verification
- [ ] Test connection to all SQL Servers
- [ ] Verify Entra authentication works
- [ ] Verify SQL authentication blocked
- [ ] Update deployment-log.md

---

## 📝 Resource Information (Fill in after creation)

### Resource Groups

| Name | Location | Purpose | Status |
|------|----------|---------|--------|
| `db-lam-rg` | East US 2 | LAM (Large Audience Model) databases | ⬜ |
| `db-qa-rg` | East US 2 | QA/Testing databases | ⬜ |
| `db-prod-rg` | East US 2 | Production databases | ⬜ |

### Security Groups (Entra ID)

| Group Name | Purpose | Members | Status |
|------------|---------|---------|--------|
| `db-lam-sqlsvr-admin` | LAM SQL Server administrators | Ron, Mike, Dave, Bruce | ⬜ |
| `db-qa-sqlsvr-admin` | QA SQL Server administrators | Ron, Mike, Dave, Bruce | ⬜ |
| `db-prod-sqlsvr-admin` | Production SQL Server administrators | Ron, Mike, Dave, Bruce | ⬜ |

### SQL Servers

| Name | FQDN | Admin Group | Status |
|------|------|-------------|--------|
| `rhcdb-lam-sqlsvr` | `rhcdb-lam-sqlsvr.database.windows.net` | `db-lam-sqlsvr-admin` | ⬜ |
| `rhcdb-qa-sqlsvr` | `rhcdb-qa-sqlsvr.database.windows.net` | `db-qa-sqlsvr-admin` | ⬜ |
| `rhcdb-prod-sqlsvr` | `rhcdb-prod-sqlsvr.database.windows.net` | `db-prod-sqlsvr-admin` | ⬜ |

### Databases

| Environment | Server | Database Name | Tier | Size | Purpose | Status |
|-------------|--------|---------------|------|------|---------|--------|
| LAM | `rhcdb-lam-sqlsvr` | `lam_db` | Standard S0 | 10 DTU | Dev/Load Testing | ⬜ |
| QA | `rhcdb-qa-sqlsvr` | `qa_corp_db` | Standard S0 | 10 DTU | QA Corporate data | ⬜ |
| QA | `rhcdb-qa-sqlsvr` | `qa_hm2_db` | Standard S0 | 10 DTU | QA HM2 app data | ⬜ |
| Production | `rhcdb-prod-sqlsvr` | `prod_corp_db` | Standard S0 | 10 DTU | Prod Corporate data | ⬜ |
| Production | `rhcdb-prod-sqlsvr` | `prod_hm2_db` | Standard S0 | 10 DTU | Prod HM2 app data | ⬜ |

---

## 🔧 Step 1: Create Entra Security Groups for SQL Administration

Before creating SQL Servers, we'll create security groups to manage administrator access.

**Admin Members:**
- Ron Krueger: `ron@recalibratehealthcare.com`
- Mike McGuirk: `mmcguirk@celerasys.com`
- Dave Tuck: `dtuck@celerasys.com`
- Bruce Scott: `bruce.scott@resolutionx.ai`

---

### ⚠️ Important: External Users (Guest Accounts)

Since the Database tenant is isolated, all admin users will be **B2B guest users** from their home tenants.

**What this means:**
- Users authenticate with their **home credentials** (e.g., `ron@recalibratehealthcare.com`)
- Azure recognizes them as **guest users** in the Database tenant
- Their UPN will appear as: `ron_recalibratehealthcare.com#EXT#@rhcdb.onmicrosoft.com`
- They can still connect to SQL Servers with their normal credentials via Entra authentication

**Two approaches:**

**Option A: Invite users as guests first (Recommended for production)**
1. Invite each user via Azure Portal or B2B invitation API
2. Wait for them to accept invitation
3. Add their guest accounts to security groups
4. They can now connect to SQL Servers

**Option B: Start with one admin, add others later (Faster for initial setup)**
1. Create security groups with just yourself (Ron)
2. Set up SQL Servers and databases
3. Invite other admins when ready
4. Add them to groups after they accept

**For this guide, we'll use Option B** - start with Ron only, add others later.

---

### 1.1: Check Your Guest Account in Database Tenant

```powershell
# Verify you're logged into Database tenant
az login --tenant rhcdb.onmicrosoft.com

# Check your account details
az ad signed-in-user show --query "{Name:displayName, UPN:userPrincipalName, ID:id}" -o json

# Expected UPN format: yourname_domain.com#EXT#@rhcdb.onmicrosoft.com
```

Save your **Object ID** - you'll need it to add yourself to groups.

---

### 1.2: Create Security Groups via Azure Portal

1. **Switch to Database Tenant**
   - Click profile icon → Switch directory
   - Select `rhcdb.onmicrosoft.com`

2. **Navigate to Groups**
   - Search for "Microsoft Entra ID" or "Groups"
   - Click **"Groups"** in the left menu
   - Click **"+ New group"**

3. **Create LAM Admin Group**
   - **Group type:** Security
   - **Group name:** `db-lam-sqlsvr-admin`
   - **Group description:** "Administrators for LAM SQL Server"
   - **Owners:** Leave default (you'll be added automatically)
   - **Members:** Click "No members selected"
     - Search for your guest account (e.g., `ron_recalibratehealthcare.com#EXT#`)
     - **Note:** You won't find `ron@recalibratehealthcare.com` directly - it's your guest UPN
     - Add yourself
   - Click **"Create"**

4. **Create QA Admin Group**
   - Click **"+ New group"**
   - **Group type:** Security
   - **Group name:** `db-qa-sqlsvr-admin`
   - **Group description:** "Administrators for QA SQL Server"
   - **Members:** Add yourself (your guest account)
   - Click **"Create"**

5. **Create Production Admin Group**
   - Click **"+ New group"**
   - **Group type:** Security
   - **Group name:** `db-prod-sqlsvr-admin`
   - **Group description:** "Administrators for Production SQL Server"
   - **Members:** Add yourself (your guest account)
   - Click **"Create"**

### 1.3: Create Security Groups via Azure CLI (PowerShell)

**Quick setup with just yourself (Ron) as admin:**

```powershell
# Ensure you're in Database tenant
az login --tenant rhcdb.onmicrosoft.com

# Get your guest account Object ID
$RonId = az ad signed-in-user show --query id -o tsv
Write-Host "Your Object ID: $RonId" -ForegroundColor Cyan

# Create LAM admin group
az ad group create `
  --display-name "db-lam-sqlsvr-admin" `
  --mail-nickname "db-lam-sqlsvr-admin" `
  --description "Administrators for LAM SQL Server"

# Create QA admin group
az ad group create `
  --display-name "db-qa-sqlsvr-admin" `
  --mail-nickname "db-qa-sqlsvr-admin" `
  --description "Administrators for QA SQL Server"

# Create Production admin group
az ad group create `
  --display-name "db-prod-sqlsvr-admin" `
  --mail-nickname "db-prod-sqlsvr-admin" `
  --description "Administrators for Production SQL Server"

# Add yourself to all three groups
az ad group member add --group "db-lam-sqlsvr-admin" --member-id $RonId
az ad group member add --group "db-qa-sqlsvr-admin" --member-id $RonId
az ad group member add --group "db-prod-sqlsvr-admin" --member-id $RonId

Write-Host "`n✅ Created 3 security groups and added Ron as admin" -ForegroundColor Green

# Verify groups created
Write-Host "`nVerifying security groups..." -ForegroundColor Cyan
az ad group list | jq -r '.[] | select(.displayName | startswith("db-")) | "\(.displayName)\t\(.id)"'

# Verify members
Write-Host "`nLAM Group Members:" -ForegroundColor Cyan
az ad group member list --group "db-lam-sqlsvr-admin" --query "[].{Name:displayName, UPN:userPrincipalName}" -o table

Write-Host "`nQA Group Members:" -ForegroundColor Cyan
az ad group member list --group "db-qa-sqlsvr-admin" --query "[].{Name:displayName, UPN:userPrincipalName}" -o table

Write-Host "`nProduction Group Members:" -ForegroundColor Cyan
az ad group member list --group "db-prod-sqlsvr-admin" --query "[].{Name:displayName, UPN:userPrincipalName}" -o table
```

---

### Via PowerShell (Az.Resources Module)

If you have the Az.Resources PowerShell module installed:

```powershell
# Connect to database tenant
Connect-AzAccount -Tenant "rhcdb.onmicrosoft.com"

# Define admin members
$Admins = @(
  "ron@recalibratehealthcare.com",
  "mmcguirk@celerasys.com",
  "dtuck@celerasys.com",
  "bruce.scott@resolutionx.ai"
)

# Create LAM admin group
$GroupParams = @{
  DisplayName = "db-lam-sqlsvr-admin"
  MailNickname = "db-lam-sqlsvr-admin"
  Description = "Administrators for LAM SQL Server"
  SecurityEnabled = $true
}
$LamGroup = New-AzADGroup @GroupParams

# Add members to LAM group
foreach ($Admin in $Admins) {
  $UserId = (Get-AzADUser -UserPrincipalName $Admin).Id
  Add-AzADGroupMember -TargetGroupObjectId $LamGroup.Id -MemberObjectId $UserId
}

# Create QA admin group
$GroupParams.DisplayName = "db-qa-sqlsvr-admin"
$GroupParams.MailNickname = "db-qa-sqlsvr-admin"
$GroupParams.Description = "Administrators for QA SQL Server"
$QaGroup = New-AzADGroup @GroupParams

foreach ($Admin in $Admins) {
  $UserId = (Get-AzADUser -UserPrincipalName $Admin).Id
  Add-AzADGroupMember -TargetGroupObjectId $QaGroup.Id -MemberObjectId $UserId
}

# Create Production admin group
$GroupParams.DisplayName = "db-prod-sqlsvr-admin"
$GroupParams.MailNickname = "db-prod-sqlsvr-admin"
$GroupParams.Description = "Administrators for Production SQL Server"
$ProdGroup = New-AzADGroup @GroupParams

foreach ($Admin in $Admins) {
  $UserId = (Get-AzADUser -UserPrincipalName $Admin).Id
  Add-AzADGroupMember -TargetGroupObjectId $ProdGroup.Id -MemberObjectId $UserId
}

# Verify
Get-AzADGroup -DisplayNameStartsWith "db-" | Format-Table DisplayName, Id
```

---

## 🔧 Step 2: Create Resource Groups

### Via Azure Portal

1. **Switch to Database Tenant**
   - Click profile icon → Switch directory
   - Select `rhcdb.onmicrosoft.com`

2. **Create LAM Resource Group**
   - Search for "Resource groups"
   - Click **"+ Create"**
   - **Subscription:** `subs-rhcdb`
   - **Resource group name:** `db-lam-rg`
   - **Region:** `East US 2`
   - **Tags:** `Environment=LAM`, `Purpose=Database`
   - Click **"Review + create"** → **"Create"**

3. **Create QA Resource Group**
   - Click **"+ Create"**
   - **Subscription:** `subs-rhcdb`
   - **Resource group name:** `db-qa-rg`
   - **Region:** `East US 2`
   - **Tags:** `Environment=QA`, `Purpose=Database`
   - Click **"Review + create"** → **"Create"**

4. **Create Production Resource Group**
   - Click **"+ Create"**
   - **Subscription:** `subs-rhcdb`
   - **Resource group name:** `db-prod-rg`
   - **Region:** `East US 2`
   - **Tags:** `Environment=Production`, `Purpose=Database`
   - Click **"Review + create"** → **"Create"**

### Via PowerShell

```powershell
# Connect to Azure
Connect-AzAccount -Tenant "rhcdb.onmicrosoft.com"

# Set subscription context
Set-AzContext -Subscription "subs-rhcdb"

# Create LAM resource group
New-AzResourceGroup `
  -Name "db-lam-rg" `
  -Location "EastUS2" `
  -Tag @{Environment="LAM"; Purpose="Database"; Project="RHC"}

# Create QA resource group
New-AzResourceGroup `
  -Name "db-qa-rg" `
  -Location "EastUS2" `
  -Tag @{Environment="QA"; Purpose="Database"; Project="RHC"}

# Create Production resource group
New-AzResourceGroup `
  -Name "db-prod-rg" `
  -Location "EastUS2" `
  -Tag @{Environment="Production"; Purpose="Database"; Project="RHC"}

# Verify
Get-AzResourceGroup | Format-Table
```

---

## 🔧 Step 3: Create SQL Servers

We'll create three SQL Servers, one in each resource group.

⚠️ **IMPORTANT: SQL Admin Password Requirement**

Even though we're using **Entra-only authentication**, Azure SQL Server **requires** a SQL admin username and password during server creation. This is a mandatory Azure requirement.

**Best Practice:** Use a clearly distinct username that won't be confused with Entra users:
- **Username:** `sqlAdminNewGroot`
- **Password:** `IAmNewGroot!`

**Critical Notes:**
- ✅ This SQL admin will be created but **never used** in normal operations
- ✅ Store the credentials securely (Key Vault or password manager)
- ✅ We'll disable SQL authentication and enforce Entra-only after creation
- ✅ The SQL admin is a fallback emergency access only

---

⚠️ **IMPORTANT: System-Assigned Managed Identity**

Each SQL Server must have **System-Assigned Managed Identity** enabled. This is critical for:

**Why We Need It:**
1. **Container App Authentication** - Container Apps will connect using their Managed Identity, and the SQL Server needs its own identity to support this authentication flow
2. **Entra-Only Authentication** - Required for registering external identities (like Container Apps) as database users
3. **Azure Service Integration** - Enables SQL Server to securely interact with Key Vault, Storage, etc. without credentials

**What It Does:**
- Azure automatically creates an identity in Entra ID for the SQL Server
- No passwords or credentials to manage
- Identity lifecycle is tied to the SQL Server (auto-cleanup on deletion)
- Enables passwordless authentication for Azure services

**How to Enable:**
- **Portal:** Settings → Identity → System assigned → Status = **On**
- **CLI:** Add `--identity-type SystemAssigned` parameter
- **PowerShell:** Add `-AssignIdentity` parameter

---

⚠️ **PREREQUISITE: Register Microsoft.Sql Resource Provider**

If this is the first SQL Server in the subscription, you must register the resource provider:

```powershell
# Register Microsoft.Sql provider (one-time setup per subscription)
az provider register --namespace Microsoft.Sql --wait

# Verify registration
az provider show --namespace Microsoft.Sql --query "registrationState"
# Should return: "Registered"
```

This takes 1-2 minutes and only needs to be done once per subscription.

---

### 3.1: Create LAM SQL Server

#### Via Azure Portal

1. **Navigate to SQL Servers**
   - Ensure you're in `rhcdb.onmicrosoft.com` tenant
   - Search for "SQL servers"
   - Click **"+ Create"**

2. **Basics Tab**
   - **Subscription:** `subs-rhcdb`
   - **Resource group:** `db-lam-rg`
   - **Server name:** `rhcdb-lam-sqlsvr`
   - **Location:** `East US 2`
   - **Authentication method:** Select **"Use both SQL and Microsoft Entra authentication"** (temporarily)
     - **Server admin login:** `sqlAdminNewGroot`
     - **Password:** `IAmNewGroot!`
     - **Confirm password:** `IAmNewGroot!`
   - **Set Entra admin:** Click "Set admin"
     - Search for the security group: `db-lam-sqlsvr-admin`
     - Select and click "Select"
   - 📝 **Note:** We'll switch to Entra-only after server creation

3. **Networking Tab**
   - **Connectivity method:** Public endpoint
   - **Firewall rules:**
     - ✅ Allow Azure services and resources to access this server
     - ✅ Add your current client IP address
   - **Minimum TLS version:** 1.2

4. **Security Tab**
   - **Microsoft Defender for SQL:** Enable
   - **Ledger:** Off

5. **Identity Tab**
   - **System assigned managed identity:** ✅ **On**
   - 📝 **Critical:** This enables Container Apps to authenticate via Managed Identity

6. **Additional Settings Tab**
   - Leave defaults

7. **Tags**
   - Environment: `LAM`
   - Purpose: `Database`

8. **Review + Create** → **Create**
   - ⏳ Wait 3-5 minutes

9. **After Creation - Switch to Entra-Only Authentication**
   - Navigate to the created SQL Server (`rhcdb-lam-sqlsvr`)
   - Go to **Settings** → **Microsoft Entra ID**
   - Enable **"Microsoft Entra-only authentication"** toggle
   - Click **Save**
   - ✅ SQL authentication is now disabled!

#### Via Azure CLI (PowerShell)

Complete script that performs all 9 steps:

```powershell
# Ensure logged into Database tenant
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# Get security group Object ID
$LamAdminGroupId = az ad group show --group "db-lam-sqlsvr-admin" --query id -o tsv

# Get your client IP for firewall
$MyIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Create LAM SQL Server with all settings (Steps 1-8)
az sql server create `
  --name "rhcdb-lam-sqlsvr" `
  --resource-group "db-lam-rg" `
  --location "eastus2" `
  --admin-user "sqlAdminNewGroot" `
  --admin-password "IAmNewGroot!" `
  --enable-public-network true `
  --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-lam-sqlsvr-admin" `
  --external-admin-sid $LamAdminGroupId

# Configure firewall - Allow Azure services
az sql server firewall-rule create `
  --server "rhcdb-lam-sqlsvr" `
  --resource-group "db-lam-rg" `
  --name "AllowAzureServices" `
  --start-ip-address "0.0.0.0" `
  --end-ip-address "0.0.0.0"

# Add your current IP
az sql server firewall-rule create `
  --server "rhcdb-lam-sqlsvr" `
  --resource-group "db-lam-rg" `
  --name "MyClientIP" `
  --start-ip-address $MyIp `
  --end-ip-address $MyIp

# Enable Entra-only authentication (Step 9 - disables SQL auth)
az sql server ad-only-auth enable `
  --resource-group "db-lam-rg" `
  --name "rhcdb-lam-sqlsvr"

# Verify server creation
Write-Host "`n✅ LAM SQL Server created successfully!" -ForegroundColor Green
az sql server show --name "rhcdb-lam-sqlsvr" -g "db-lam-rg" `
  --query "{Name:name, Location:location, Identity:identity.type, EntraAdmin:administrators.login, EntraOnly:administrators.azureAdOnlyAuthentication}" `
  -o json
```

---

### 3.2: Create QA SQL Server

Repeat the process for QA:

1. Navigate to **SQL servers** → **+ Create**
2. **Basics:**
   - Subscription: `subs-rhcdb`
   - Resource group: `db-qa-rg`
   - Server name: `rhcdb-qa-sqlsvr`
   - Location: East US 2
   - **Authentication:** Both SQL and Entra (temporarily)
     - SQL admin: `sqlAdminNewGroot`
     - Password: `IAmNewGroot!`
   - **Set Entra admin:** `db-qa-sqlsvr-admin` security group
3. **Networking:** Public endpoint, Azure services allowed, add your IP
4. **Security:** Enable Defender
5. **Identity:** System assigned = **On**
6. **Tags:** Environment=QA
7. **Create**
8. **After creation:** Enable "Entra-only authentication" in settings

#### Via Azure CLI (PowerShell)

```powershell
# Get security group Object ID
$QaAdminGroupId = az ad group show --group "db-qa-sqlsvr-admin" --query id -o tsv

# Get your client IP
$MyIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Create QA SQL Server
az sql server create `
  --name "rhcdb-qa-sqlsvr" `
  --resource-group "db-qa-rg" `
  --location "eastus2" `
  --admin-user "sqlAdminNewGroot" `
  --admin-password "IAmNewGroot!" `
  --enable-public-network true `
  --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-qa-sqlsvr-admin" `
  --external-admin-sid $QaAdminGroupId

# Configure firewall
az sql server firewall-rule create `
  --server "rhcdb-qa-sqlsvr" -g "db-qa-rg" `
  --name "AllowAzureServices" `
  --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"

az sql server firewall-rule create `
  --server "rhcdb-qa-sqlsvr" -g "db-qa-rg" `
  --name "MyClientIP" `
  --start-ip-address $MyIp --end-ip-address $MyIp

# Enable Entra-only authentication
az sql server ad-only-auth enable -g "db-qa-rg" --name "rhcdb-qa-sqlsvr"

Write-Host "`n✅ QA SQL Server created!" -ForegroundColor Green
```

---

### 3.3: Create Production SQL Server

Repeat for Production:

1. Navigate to **SQL servers** → **+ Create**
2. **Basics:**
   - Subscription: `subs-rhcdb`
   - Resource group: `db-prod-rg`
   - Server name: `rhcdb-prod-sqlsvr`
   - Location: East US 2
   - **Authentication:** Both SQL and Entra (temporarily)
     - SQL admin: `sqlAdminNewGroot`
     - Password: `IAmNewGroot!`
   - **Set Entra admin:** `db-prod-sqlsvr-admin` security group
3. **Networking:** Public endpoint, Azure services allowed, add your IP
4. **Security:** Enable Defender
5. **Identity:** System assigned = **On**
6. **Tags:** Environment=Production
7. **Create**
8. **After creation:** Enable "Entra-only authentication" in settings

#### Via Azure CLI (PowerShell)

```powershell
# Get security group Object ID
$ProdAdminGroupId = az ad group show --group "db-prod-sqlsvr-admin" --query id -o tsv

# Get your client IP
$MyIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Create Production SQL Server
az sql server create `
  --name "rhcdb-prod-sqlsvr" `
  --resource-group "db-prod-rg" `
  --location "eastus2" `
  --admin-user "sqlAdminNewGroot" `
  --admin-password "IAmNewGroot!" `
  --enable-public-network true `
  --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-prod-sqlsvr-admin" `
  --external-admin-sid $ProdAdminGroupId

# Configure firewall
az sql server firewall-rule create `
  --server "rhcdb-prod-sqlsvr" -g "db-prod-rg" `
  --name "AllowAzureServices" `
  --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"

az sql server firewall-rule create `
  --server "rhcdb-prod-sqlsvr" -g "db-prod-rg" `
  --name "MyClientIP" `
  --start-ip-address $MyIp --end-ip-address $MyIp

# Enable Entra-only authentication
az sql server ad-only-auth enable -g "db-prod-rg" --name "rhcdb-prod-sqlsvr"

Write-Host "`n✅ Production SQL Server created!" -ForegroundColor Green
```

---

### Create All Three Servers (Quick Script)

Or run this single script to create all three at once:

```powershell
# Ensure logged into Database tenant
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# Get security group Object IDs
$LamAdminGroupId = az ad group show --group "db-lam-sqlsvr-admin" --query id -o tsv
$QaAdminGroupId = az ad group show --group "db-qa-sqlsvr-admin" --query id -o tsv
$ProdAdminGroupId = az ad group show --group "db-prod-sqlsvr-admin" --query id -o tsv

# Get your client IP
$MyIp = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

Write-Host "Creating LAM SQL Server..." -ForegroundColor Cyan
az sql server create `
  --name "rhcdb-lam-sqlsvr" -g "db-lam-rg" --location "eastus2" `
  --admin-user "sqlAdminNewGroot" --admin-password "IAmNewGroot!" `
  --enable-public-network true --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-lam-sqlsvr-admin" `
  --external-admin-sid $LamAdminGroupId

az sql server firewall-rule create --server "rhcdb-lam-sqlsvr" -g "db-lam-rg" `
  --name "AllowAzureServices" --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"
az sql server firewall-rule create --server "rhcdb-lam-sqlsvr" -g "db-lam-rg" `
  --name "MyClientIP" --start-ip-address $MyIp --end-ip-address $MyIp
az sql server ad-only-auth enable -g "db-lam-rg" --name "rhcdb-lam-sqlsvr"

Write-Host "Creating QA SQL Server..." -ForegroundColor Cyan
az sql server create `
  --name "rhcdb-qa-sqlsvr" -g "db-qa-rg" --location "eastus2" `
  --admin-user "sqlAdminNewGroot" --admin-password "IAmNewGroot!" `
  --enable-public-network true --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-qa-sqlsvr-admin" `
  --external-admin-sid $QaAdminGroupId

az sql server firewall-rule create --server "rhcdb-qa-sqlsvr" -g "db-qa-rg" `
  --name "AllowAzureServices" --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"
az sql server firewall-rule create --server "rhcdb-qa-sqlsvr" -g "db-qa-rg" `
  --name "MyClientIP" --start-ip-address $MyIp --end-ip-address $MyIp
az sql server ad-only-auth enable -g "db-qa-rg" --name "rhcdb-qa-sqlsvr"

Write-Host "Creating Production SQL Server..." -ForegroundColor Cyan
az sql server create `
  --name "rhcdb-prod-sqlsvr" -g "db-prod-rg" --location "eastus2" `
  --admin-user "sqlAdminNewGroot" --admin-password "IAmNewGroot!" `
  --enable-public-network true --minimal-tls-version "1.2" `
  --identity-type SystemAssigned `
  --external-admin-principal-type Group `
  --external-admin-name "db-prod-sqlsvr-admin" `
  --external-admin-sid $ProdAdminGroupId

az sql server firewall-rule create --server "rhcdb-prod-sqlsvr" -g "db-prod-rg" `
  --name "AllowAzureServices" --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"
az sql server firewall-rule create --server "rhcdb-prod-sqlsvr" -g "db-prod-rg" `
  --name "MyClientIP" --start-ip-address $MyIp --end-ip-address $MyIp
az sql server ad-only-auth enable -g "db-prod-rg" --name "rhcdb-prod-sqlsvr"

# Verify all servers
Write-Host "`n✅ All SQL Servers created successfully!" -ForegroundColor Green
az sql server list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, Identity:identity.type}" -o table
```

---

## 🔧 Step 3: Create Databases

### 3.1: Create LAM Database

#### Via Azure Portal

1. Navigate to SQL Server (`rhcdb-lam-sqlsvr`)
2. Click **"+ Create database"**
3. **Basics:**
   - Database name: `lam_db`
   - Compute + storage: **Standard S0 (10 DTU)**
   - Backup redundancy: Locally-redundant
4. **Tags:** Environment=LAM
5. **Review + create** → **Create**

---

### 3.2: Create QA Databases

#### Create qa_corp_db

#### Via Azure Portal

1. Navigate to SQL Server (`rhcdb-qa-sqlsvr`)
2. Click **"+ Create database"**
3. **Basics:**
   - Database name: `qa_corp_db`
   - Compute + storage: **Standard S0 (10 DTU)**
   - Backup redundancy: Locally-redundant
4. **Tags:** Environment=QA, Purpose=Corporate
5. **Review + create** → **Create**

---

#### Create qa_hm2_db

Repeat for the HM2 application database in Azure Portal with similar settings.

---

### 3.3: Create Production Databases

Create `prod_corp_db` and `prod_hm2_db` in Azure Portal following same pattern as QA databases.

**Note:** Production databases should use **Geo-redundant** backup storage for disaster recovery.

---

### Create All Databases (Azure CLI Script)

Complete script to create all 5 databases:

```powershell
# Ensure logged into Database tenant
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# Create LAM Database
Write-Host "Creating LAM database..." -ForegroundColor Cyan
az sql db create `
  --resource-group "db-lam-rg" `
  --server "rhcdb-lam-sqlsvr" `
  --name "lam_db" `
  --edition "Standard" `
  --capacity 10 `
  --max-size 250GB `
  --backup-storage-redundancy "Local" `
  --tags Environment=LAM Purpose=DevTesting Project=RHC

# Create QA Databases
Write-Host "Creating QA databases..." -ForegroundColor Cyan
az sql db create `
  --resource-group "db-qa-rg" `
  --server "rhcdb-qa-sqlsvr" `
  --name "qa_corp_db" `
  --edition "Standard" `
  --capacity 10 `
  --max-size 250GB `
  --backup-storage-redundancy "Local" `
  --tags Environment=QA Purpose=Corporate Project=RHC

az sql db create `
  --resource-group "db-qa-rg" `
  --server "rhcdb-qa-sqlsvr" `
  --name "qa_hm2_db" `
  --edition "Standard" `
  --capacity 10 `
  --max-size 250GB `
  --backup-storage-redundancy "Local" `
  --tags Environment=QA Purpose=HM2 Project=RHC

# Create Production Databases
Write-Host "Creating Production databases..." -ForegroundColor Cyan
az sql db create `
  --resource-group "db-prod-rg" `
  --server "rhcdb-prod-sqlsvr" `
  --name "prod_corp_db" `
  --edition "Standard" `
  --capacity 10 `
  --max-size 250GB `
  --backup-storage-redundancy "Geo" `
  --tags Environment=Production Purpose=Corporate Project=RHC

az sql db create `
  --resource-group "db-prod-rg" `
  --server "rhcdb-prod-sqlsvr" `
  --name "prod_hm2_db" `
  --edition "Standard" `
  --capacity 10 `
  --max-size 250GB `
  --backup-storage-redundancy "Geo" `
  --tags Environment=Production Purpose=HM2 Project=RHC

# Verify all databases
Write-Host "`n✅ All databases created!" -ForegroundColor Green
Write-Host "LAM Databases:" -ForegroundColor Cyan
az sql db list -g "db-lam-rg" -s "rhcdb-lam-sqlsvr" --query "[].name" -o table

Write-Host "`nQA Databases:" -ForegroundColor Cyan
az sql db list -g "db-qa-rg" -s "rhcdb-qa-sqlsvr" --query "[].name" -o table

Write-Host "`nProduction Databases:" -ForegroundColor Cyan
az sql db list -g "db-prod-rg" -s "rhcdb-prod-sqlsvr" --query "[].name" -o table
```

---

## 🔧 Step 4: Setup Cross-Tenant Database Access

**🎯 Goal:** Allow Container Apps (in QA/Prod External ID tenants) to securely access Databases (in Database tenant).

**🔒 Security Principle:** Keep customer-facing identities separate from database infrastructure.

---

### 📚 Understanding the Challenge

**The Problem:**
- **Databases live in:** `rhcdb.onmicrosoft.com` (Database tenant - highly restricted)
- **Container Apps live in:** `rhcqa.onmicrosoft.com` and `rhcprod.onmicrosoft.com` (External ID tenants - public-facing)
- **Challenge:** Container Apps need database access, but they're in different tenants!

**The Solution:**
1. Create **App Registrations** (service principals) in the Database tenant
2. Create **Security Groups** in the Database tenant (one per environment)
3. Add the App Registrations to their respective Security Groups
4. Register the Security Groups as **database users** with permissions
5. Container Apps use the App Registration credentials to authenticate

**Why This Works:**
- App Registrations can be used across tenant boundaries
- Container Apps authenticate using client credentials (app ID + secret)
- Database tenant controls all database access through its own identities
- Customer identities stay isolated in their own tenants

---

### 4.1: Create App Registrations (Service Principals)

These live in the **Database tenant** and represent your Container Apps.

#### Via Azure Portal

**For LAM Environment:**

1. **Switch to Database Tenant**
   - Ensure you're in `rhcdb.onmicrosoft.com` tenant
   - Portal → **Microsoft Entra ID**

2. **Create App Registration**
   - Click **App registrations** → **+ New registration**
   - **Name:** `app-lam-db-access`
   - **Supported account types:** Single tenant (this directory only)
   - **Redirect URI:** Leave blank
   - Click **Register**

3. **Copy Important Values** (save these!)
   - **Application (client) ID:** Copy this (e.g., `12345678-1234-1234-1234-123456789abc`)
   - **Directory (tenant) ID:** Copy this (should be Database tenant ID: `b62a8921-d524-41af-9807-1057f031ecda`)

4. **Create Client Secret**
   - Go to **Certificates & secrets** → **+ New client secret**
   - **Description:** `LAM Container App Access`
   - **Expires:** 24 months (or per your security policy)
   - Click **Add**
   - **⚠️ CRITICAL:** Copy the secret **VALUE** immediately (e.g., `abcXYZ123...`) - you cannot see it again!

**For QA Environment:**

Repeat the process:
- **Name:** `app-qa-db-access`
- **Description:** `QA Container Apps Access`
- Save: Application ID, Tenant ID, Client Secret

**For Production Environment:**

Repeat the process:
- **Name:** `app-prod-db-access`
- **Description:** `Production Container Apps Access`
- Save: Application ID, Tenant ID, Client Secret

**🔐 Security Note:** Store these credentials in Azure Key Vault (in the QA/Prod tenants) - we'll cover this in Phase 5.

#### Via Azure CLI (PowerShell)

Complete script to create all three app registrations:

```powershell
# Ensure you're in Database tenant
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# Get Database tenant ID
$DbTenantId = "b62a8921-d524-41af-9807-1057f031ecda"

Write-Host "Creating LAM App Registration..." -ForegroundColor Cyan
# Create LAM App Registration
$LamAppId = az ad app create `
  --display-name "app-lam-db-access" `
  --sign-in-audience AzureADMyOrg `
  --query appId -o tsv

# Create service principal for LAM app
az ad sp create --id $LamAppId

# Create client secret for LAM app (expires in 2 years)
$LamSecret = az ad app credential reset `
  --id $LamAppId `
  --append `
  --years 2 `
  --query password -o tsv

Write-Host "`n✅ LAM App Registration Created:" -ForegroundColor Green
Write-Host "  Application ID: $LamAppId"
Write-Host "  Tenant ID: $DbTenantId"
Write-Host "  Client Secret: $LamSecret"
Write-Host "  ⚠️  SAVE THESE VALUES SECURELY!" -ForegroundColor Yellow

Write-Host "`nCreating QA App Registration..." -ForegroundColor Cyan
# Create QA App Registration
$QaAppId = az ad app create `
  --display-name "app-qa-db-access" `
  --sign-in-audience AzureADMyOrg `
  --query appId -o tsv

az ad sp create --id $QaAppId

$QaSecret = az ad app credential reset `
  --id $QaAppId `
  --append `
  --years 2 `
  --query password -o tsv

Write-Host "`n✅ QA App Registration Created:" -ForegroundColor Green
Write-Host "  Application ID: $QaAppId"
Write-Host "  Tenant ID: $DbTenantId"
Write-Host "  Client Secret: $QaSecret"

Write-Host "`nCreating Production App Registration..." -ForegroundColor Cyan
# Create Production App Registration
$ProdAppId = az ad app create `
  --display-name "app-prod-db-access" `
  --sign-in-audience AzureADMyOrg `
  --query appId -o tsv

az ad sp create --id $ProdAppId

$ProdSecret = az ad app credential reset `
  --id $ProdAppId `
  --append `
  --years 2 `
  --query password -o tsv

Write-Host "`n✅ Production App Registration Created:" -ForegroundColor Green
Write-Host "  Application ID: $ProdAppId"
Write-Host "  Tenant ID: $DbTenantId"
Write-Host "  Client Secret: $ProdSecret"

Write-Host "`n📋 Summary - Save These Credentials:" -ForegroundColor Cyan
Write-Host "================================================"
Write-Host "LAM:"
Write-Host "  App ID: $LamAppId"
Write-Host "  Secret: $LamSecret"
Write-Host ""
Write-Host "QA:"
Write-Host "  App ID: $QaAppId"
Write-Host "  Secret: $QaSecret"
Write-Host ""
Write-Host "Production:"
Write-Host "  App ID: $ProdAppId"
Write-Host "  Secret: $ProdSecret"
Write-Host ""
Write-Host "Tenant ID (all): $DbTenantId"
Write-Host "================================================"
Write-Host "⚠️  Store these in Azure Key Vault immediately!" -ForegroundColor Yellow
```

---

### 4.2: Create Security Groups for App Access

These groups will be registered as database users. This is better than registering individual apps because:
- ✅ Easier to manage permissions (change group membership vs. database users)
- ✅ Can add multiple apps to same group
- ✅ Follows least privilege principle

#### Via Azure Portal

**For LAM Environment:**

1. **Navigate to Groups**
   - Ensure you're in `rhcdb.onmicrosoft.com` tenant
   - Portal → **Microsoft Entra ID** → **Groups**

2. **Create Group**
   - Click **+ New group**
   - **Group type:** Security
   - **Group name:** `db-lam-app-users`
   - **Group description:** `Applications with access to LAM databases`
   - **Membership type:** Assigned
   - Click **Create**

3. **Add App Registration as Member**
   - Open the `db-lam-app-users` group
   - Click **Members** → **+ Add members**
   - Search for: `app-lam-db-access`
   - Select it and click **Select**

**For QA Environment:**

Repeat:
- **Group name:** `db-qa-app-users`
- **Description:** `Applications with access to QA databases`
- **Add member:** `app-qa-db-access`

**For Production Environment:**

Repeat:
- **Group name:** `db-prod-app-users`
- **Description:** `Applications with access to Production databases`
- **Add member:** `app-prod-db-access`

#### Via Azure CLI (PowerShell)

Complete script to create security groups and add app registrations:

```powershell
# Ensure you're in Database tenant
az login --tenant rhcdb.onmicrosoft.com

# Get service principal object IDs (NOT app IDs!)
# Service principals are created when you do "az ad sp create"
Write-Host "Getting service principal IDs..." -ForegroundColor Cyan
$LamSpId = az ad sp list --display-name "app-lam-db-access" --query "[0].id" -o tsv
$QaSpId = az ad sp list --display-name "app-qa-db-access" --query "[0].id" -o tsv
$ProdSpId = az ad sp list --display-name "app-prod-db-access" --query "[0].id" -o tsv

Write-Host "  LAM SP ID: $LamSpId"
Write-Host "  QA SP ID: $QaSpId"
Write-Host "  Prod SP ID: $ProdSpId"

# Create LAM security group
Write-Host "`nCreating LAM security group..." -ForegroundColor Cyan
$LamGroupId = az ad group create `
  --display-name "db-lam-app-users" `
  --mail-nickname "db-lam-app-users" `
  --description "Applications with access to LAM databases" `
  --query id -o tsv

# Add LAM app to group
az ad group member add `
  --group $LamGroupId `
  --member-id $LamSpId

Write-Host "✅ Created group: db-lam-app-users (ID: $LamGroupId)" -ForegroundColor Green

# Create QA security group
Write-Host "`nCreating QA security group..." -ForegroundColor Cyan
$QaGroupId = az ad group create `
  --display-name "db-qa-app-users" `
  --mail-nickname "db-qa-app-users" `
  --description "Applications with access to QA databases" `
  --query id -o tsv

az ad group member add `
  --group $QaGroupId `
  --member-id $QaSpId

Write-Host "✅ Created group: db-qa-app-users (ID: $QaGroupId)" -ForegroundColor Green

# Create Production security group
Write-Host "`nCreating Production security group..." -ForegroundColor Cyan
$ProdGroupId = az ad group create `
  --display-name "db-prod-app-users" `
  --mail-nickname "db-prod-app-users" `
  --description "Applications with access to Production databases" `
  --query id -o tsv

az ad group member add `
  --group $ProdGroupId `
  --member-id $ProdSpId

Write-Host "✅ Created group: db-prod-app-users (ID: $ProdGroupId)" -ForegroundColor Green

# Verify group memberships
Write-Host "`n📋 Verifying group memberships:" -ForegroundColor Cyan
Write-Host "LAM group members:"
az ad group member list --group "db-lam-app-users" --query "[].displayName" -o table

Write-Host "`nQA group members:"
az ad group member list --group "db-qa-app-users" --query "[].displayName" -o table

Write-Host "`nProduction group members:"
az ad group member list --group "db-prod-app-users" --query "[].displayName" -o table

Write-Host "`n✅ All security groups created and app registrations added!" -ForegroundColor Green
```

---

### 4.3: Register Groups as Database Users

Now we need to tell each database that these groups exist and what they can do.

**⚠️ Prerequisites:**
- SQL Servers and databases must be created (Step 2 & 3)
- You must be an Entra admin on the SQL Server
- Install Azure Data Studio or sqlcmd tool

---

#### Connect to Database as Entra Admin

**Option 1: Azure Data Studio (Recommended)**

1. **Download Azure Data Studio:** https://aka.ms/azuredatastudio
2. **Connect to LAM Database:**
   - Server: `rhcdb-lam-sqlsvr.database.windows.net`
   - Authentication: **Microsoft Entra ID - Universal with MFA**
   - Database: `lam_db`
   - Click **Connect**

---

#### Register Group in LAM Database

Once connected to `lam_db`, run these SQL commands:

```sql
-- Create user for the security group
CREATE USER [db-lam-app-users] FROM EXTERNAL PROVIDER;

-- Grant read permissions
ALTER ROLE db_datareader ADD MEMBER [db-lam-app-users];

-- Grant write permissions
ALTER ROLE db_datawriter ADD MEMBER [db-lam-app-users];

-- Grant execute permissions (for stored procedures)
GRANT EXECUTE TO [db-lam-app-users];

-- Verify the user was created
SELECT name, type_desc, create_date 
FROM sys.database_principals 
WHERE name = 'db-lam-app-users';

-- Verify permissions
SELECT 
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-lam-app-users';
```

**Expected Output:**
```
PrincipalName        PrincipalType    RoleName
------------------   --------------   -------------
db-lam-app-users     EXTERNAL_GROUP   db_datareader
db-lam-app-users     EXTERNAL_GROUP   db_datawriter
```

---

#### Register Group in QA Databases

**For qa_corp_db:**

```sql
-- Connect to qa_corp_db first!
USE qa_corp_db;
GO

-- Create user and grant permissions
CREATE USER [db-qa-app-users] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [db-qa-app-users];
ALTER ROLE db_datawriter ADD MEMBER [db-qa-app-users];
GRANT EXECUTE TO [db-qa-app-users];

-- Verify
SELECT name, type_desc FROM sys.database_principals WHERE name = 'db-qa-app-users';
```

**For qa_hm2_db:**

```sql
-- Connect to qa_hm2_db
USE qa_hm2_db;
GO

-- Create user and grant permissions
CREATE USER [db-qa-app-users] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [db-qa-app-users];
ALTER ROLE db_datawriter ADD MEMBER [db-qa-app-users];
GRANT EXECUTE TO [db-qa-app-users];

-- Verify
SELECT name, type_desc FROM sys.database_principals WHERE name = 'db-qa-app-users';
```

---

#### Register Group in Production Databases

**For prod_corp_db:**

```sql
USE prod_corp_db;
GO

CREATE USER [db-prod-app-users] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [db-prod-app-users];
ALTER ROLE db_datawriter ADD MEMBER [db-prod-app-users];
GRANT EXECUTE TO [db-prod-app-users];

-- Verify
SELECT name, type_desc FROM sys.database_principals WHERE name = 'db-prod-app-users';
```

**For prod_hm2_db:**

```sql
USE prod_hm2_db;
GO

CREATE USER [db-prod-app-users] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [db-prod-app-users];
ALTER ROLE db_datawriter ADD MEMBER [db-prod-app-users];
GRANT EXECUTE TO [db-prod-app-users];

-- Verify
SELECT name, type_desc FROM sys.database_principals WHERE name = 'db-prod-app-users';
```

---

### 4.4: Summary - What We Created

**App Registrations (in Database Tenant):**
| Name | Purpose | Tenant | Save These Values |
|------|---------|--------|-------------------|
| `app-lam-db-access` | LAM Container App identity | `rhcdb.onmicrosoft.com` | App ID, Secret |
| `app-qa-db-access` | QA Container Apps identity | `rhcdb.onmicrosoft.com` | App ID, Secret |
| `app-prod-db-access` | Prod Container Apps identity | `rhcdb.onmicrosoft.com` | App ID, Secret |

**Security Groups (in Database Tenant):**
| Group Name | Members | Database Users Created In |
|------------|---------|---------------------------|
| `db-lam-app-users` | `app-lam-db-access` | `lam_db` |
| `db-qa-app-users` | `app-qa-db-access` | `qa_corp_db`, `qa_hm2_db` |
| `db-prod-app-users` | `app-prod-db-access` | `prod_corp_db`, `prod_hm2_db` |

**Database Users (registered in each database):**
- All users have: `db_datareader` + `db_datawriter` + `EXECUTE` permissions

**✅ Result:** Container Apps in QA/Prod tenants can now authenticate to databases using their App Registration credentials!

---

## 🔧 Step 5: Configure Audit Logging

**💰 Cost:** First 5 GB/month per subscription is FREE, then ~$2.30/GB. SQL audit logs are small; likely stay under free tier.

**⚠️ Important:** Enable audit logging on **all three SQL servers** (LAM, QA, Production) for consistent security visibility. Use a single Log Analytics workspace to consolidate logs and stay within the free tier.

---

### Create Log Analytics Workspace (Single Workspace for All Servers)

#### Via Azure CLI (PowerShell)

```powershell
# Switch to Database tenant
az account set --subscription "subs-rhcdb"

# Create a single Log Analytics workspace for all audit logs
# Using db-lam-rg since it's the first resource group
az monitor log-analytics workspace create `
  --resource-group "db-lam-rg" `
  --workspace-name "rhcdb-audit-logs" `
  --location "eastus2" `
  --tags Purpose=Auditing Project=RHC Scope=AllServers

Write-Host "✅ Log Analytics workspace created" -ForegroundColor Green

# Get workspace ID (needed for audit configuration)
$workspaceId = az monitor log-analytics workspace show `
  --resource-group "db-lam-rg" `
  --workspace-name "rhcdb-audit-logs" `
  --query id -o tsv

Write-Host "Workspace ID: $workspaceId" -ForegroundColor Cyan
```

---

### Enable SQL Auditing on All Servers

**⚠️ Important:** The Microsoft.Insights resource provider must be registered before enabling audit logging. This happens automatically but takes 1-2 minutes to propagate.

#### Via Azure CLI (PowerShell) - Complete Script

```powershell
# Ensure Database tenant context
az account set --subscription "subs-rhcdb"

# Register Microsoft.Insights provider (required for Log Analytics integration)
Write-Host "`n📝 Registering Microsoft.Insights provider..." -ForegroundColor Cyan
az provider register --namespace Microsoft.Insights

# Wait for registration to complete
Write-Host "Waiting for registration to complete (this may take 1-2 minutes)..." -ForegroundColor Yellow
do {
    $state = az provider show --namespace Microsoft.Insights --query "registrationState" -o tsv
    Write-Host "Provider state: $state" -ForegroundColor Cyan
    if ($state -ne "Registered") {
        Start-Sleep -Seconds 15
    }
} while ($state -ne "Registered")

Write-Host "✅ Microsoft.Insights provider registered" -ForegroundColor Green

# Wait for propagation across Azure services
# NOTE: Provider registration can take several minutes to fully propagate
# Even after showing "Registered", some operations may fail initially
Write-Host "Waiting 60 seconds for propagation across Azure services..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

Write-Host "⚠️  If audit policy updates fail with 'Please register Microsoft.Insights'," -ForegroundColor Yellow
Write-Host "   wait another 30-60 seconds and retry the failed commands." -ForegroundColor Yellow

# Get workspace ID
$workspaceId = az monitor log-analytics workspace show `
  --resource-group "db-lam-rg" `
  --workspace-name "rhcdb-audit-logs" `
  --query id -o tsv

Write-Host "`n🔍 Enabling audit logging on all SQL servers..." -ForegroundColor Cyan
Write-Host "Workspace ID: $workspaceId`n" -ForegroundColor Yellow

# Enable auditing on LAM SQL Server
Write-Host "`n🔍 Enabling audit logging on SQL servers..." -ForegroundColor Cyan
Write-Host "Configuring rhcdb-lam-sqlsvr..." -ForegroundColor Cyan
az sql server audit-policy update `
  --resource-group "db-lam-rg" `
  --name "rhcdb-lam-sqlsvr" `
  --state Enabled `
  --log-analytics-target-state Enabled `
  --log-analytics-workspace-resource-id $workspaceId

Write-Host "✅ LAM server audit enabled" -ForegroundColor Green

# Enable auditing on QA SQL Server
Write-Host "`nConfiguring rhcdb-qa-sqlsvr..." -ForegroundColor Cyan
az sql server audit-policy update `
  --resource-group "db-qa-rg" `
  --name "rhcdb-qa-sqlsvr" `
  --state Enabled `
  --log-analytics-target-state Enabled `
  --log-analytics-workspace-resource-id $workspaceId

# Note: QA server may fail on first attempt due to provider propagation delay
# If it fails, wait 30 seconds and retry the QA command above
Write-Host "✅ QA server audit enabled" -ForegroundColor Green

# Enable auditing on Production SQL Server
Write-Host "`nConfiguring rhcdb-prod-sqlsvr..." -ForegroundColor Cyan
az sql server audit-policy update `
  --resource-group "db-prod-rg" `
  --name "rhcdb-prod-sqlsvr" `
  --state Enabled `
  --log-analytics-target-state Enabled `
  --log-analytics-workspace-resource-id $workspaceId

Write-Host "✅ Production server audit enabled" -ForegroundColor Green

Write-Host "`n✅ All SQL servers now auditing to rhcdb-audit-logs workspace!" -ForegroundColor Green
Write-Host "`n📊 View audit logs: Azure Portal → Log Analytics workspace → Logs" -ForegroundColor Cyan
```

#### Verify Audit Configuration

```powershell
# Check audit status on all servers
Write-Host "`n📋 Audit Status:" -ForegroundColor Cyan

Write-Host "`nLAM Server:" -ForegroundColor Yellow
az sql server audit-policy show `
  --resource-group "db-lam-rg" `
  --name "rhcdb-lam-sqlsvr" `
  --query "{State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o table

Write-Host "`nQA Server:" -ForegroundColor Yellow
az sql server audit-policy show `
  --resource-group "db-qa-rg" `
  --name "rhcdb-qa-sqlsvr" `
  --query "{State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o table

Write-Host "`nProduction Server:" -ForegroundColor Yellow
az sql server audit-policy show `
  --resource-group "db-prod-rg" `
  --name "rhcdb-prod-sqlsvr" `
  --query "{State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o table
```

---

## 🔧 Step 6: Enable Microsoft Defender for SQL

**💰 Cost:** $15/server/month × 3 servers = **$45/month**

**⚠️ Recommendation:** 
- **Production:** Enable immediately (required for HIPAA compliance)
- **QA:** Enable for pre-production validation
- **LAM:** Optional (development environment) - can skip to save $15/month

**Features:**
- Vulnerability assessments (security best practices)
- Advanced threat protection (SQL injection, anomalous access)
- Security alerts and recommendations
- Compliance reporting

---

### Enable Microsoft Defender for SQL (Subscription Level)

First, enable Defender at the subscription level (applies to all SQL servers):

#### Via Azure CLI (PowerShell)

```powershell
# Switch to Database tenant
az account set --subscription "subs-rhcdb"

# Register Microsoft.Security provider (required for Defender)
Write-Host "`n📝 Registering Microsoft.Security provider..." -ForegroundColor Cyan
az provider register --namespace Microsoft.Security

# Wait for registration to complete
Write-Host "Waiting for registration..." -ForegroundColor Yellow
do {
    $state = az provider show --namespace Microsoft.Security --query "registrationState" -o tsv
    Write-Host "Provider state: $state" -ForegroundColor Cyan
    if ($state -ne "Registered") {
        Start-Sleep -Seconds 15
    }
} while ($state -ne "Registered")

Write-Host "✅ Microsoft.Security provider registered" -ForegroundColor Green
Start-Sleep -Seconds 30

# Enable Defender for SQL at subscription level
Write-Host "`n🛡️ Enabling Microsoft Defender for SQL (subscription level)..." -ForegroundColor Cyan

az security pricing create `
  --name "SqlServers" `
  --tier "Standard"

Write-Host "✅ Microsoft Defender for SQL enabled at subscription level" -ForegroundColor Green
Write-Host "⚠️  This will cost $15/server/month (30-day free trial available)" -ForegroundColor Yellow
```

---

### Configure Advanced Threat Protection on Each Server

Now configure threat protection settings for each SQL server:

#### Via Azure CLI (PowerShell) - Complete Script

```powershell
# Ensure Database tenant context
az account set --subscription "subs-rhcdb"

$AdminEmail = "ron@recalibratehealthcare.com"

Write-Host "`n🔒 Configuring Advanced Threat Protection on all SQL servers..." -ForegroundColor Cyan

# Configure LAM SQL Server
Write-Host "`nConfiguring rhcdb-lam-sqlsvr..." -ForegroundColor Cyan
az sql server threat-policy update `
  --resource-group "db-lam-rg" `
  --name "rhcdb-lam-sqlsvr" `
  --state Enabled `
  --email-account-admins true `
  --email-addresses $AdminEmail

Write-Host "✅ LAM server threat protection enabled" -ForegroundColor Green

# Configure QA SQL Server
Write-Host "`nConfiguring rhcdb-qa-sqlsvr..." -ForegroundColor Cyan
az sql server threat-policy update `
  --resource-group "db-qa-rg" `
  --name "rhcdb-qa-sqlsvr" `
  --state Enabled `
  --email-account-admins true `
  --email-addresses $AdminEmail

Write-Host "✅ QA server threat protection enabled" -ForegroundColor Green

# Configure Production SQL Server
Write-Host "`nConfiguring rhcdb-prod-sqlsvr..." -ForegroundColor Cyan
az sql server threat-policy update `
  --resource-group "db-prod-rg" `
  --name "rhcdb-prod-sqlsvr" `
  --state Enabled `
  --email-account-admins true `
  --email-addresses $AdminEmail

Write-Host "✅ Production server threat protection enabled" -ForegroundColor Green

Write-Host "`n✅ Microsoft Defender for SQL fully configured!" -ForegroundColor Green
Write-Host "📧 Security alerts will be sent to: $AdminEmail" -ForegroundColor Cyan
```

#### Verify Defender Configuration

```powershell
# Check Defender subscription-level status
Write-Host "`n📋 Microsoft Defender Status:" -ForegroundColor Cyan
az security pricing show --name "SqlServers" --query "{Name:name, Tier:pricingTier, FreeTrialRemaining:freeTrialRemainingTime}" -o table

Write-Host "`n📊 View threat protection settings and security recommendations:" -ForegroundColor Cyan
Write-Host "   Azure Portal → SQL Server → Security → Microsoft Defender for Cloud" -ForegroundColor Yellow
```

**Note:** The Azure CLI does not have a reliable command to show individual server threat policy status. Verify configuration in the Azure Portal.

---

### Optional: Disable Defender on LAM (Save $15/month)

If you want to skip Defender on the LAM development server to save costs:

```powershell
# Disable threat protection on LAM server only
az sql server threat-policy update `
  --resource-group "db-lam-rg" `
  --server "rhcdb-lam-sqlsvr" `
  --state Disabled

Write-Host "✅ LAM server threat protection disabled (saves $15/month)" -ForegroundColor Green
Write-Host "⚠️  QA and Production servers remain protected" -ForegroundColor Yellow
```


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
-- Connect to rhc-rhcdb-qa-sqlsvr.database.windows.net
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

## 🔗 Step 7: Connection Strings for Container Apps

This is how your Container Apps (in QA/Prod tenants) will connect to databases (in Database tenant).

---

### Understanding Connection String Authentication

**What we're using:** Service Principal Authentication (cross-tenant)

**Why not Managed Identity?**
- Managed Identity only works within the same tenant
- Our Container Apps are in different tenants (QA/Prod External ID tenants)
- Service Principal with client credentials allows cross-tenant authentication

**The Flow:**
1. Container App reads credentials from environment variables (or Key Vault)
2. Authenticates as the Service Principal (in Database tenant)
3. Database recognizes the Service Principal through the security group
4. Permissions are granted based on group membership

---

### 7.1: Connection String Format

**Template for Service Principal Authentication:**

```
Server=tcp:<server-name>.database.windows.net,1433;
Database=<database-name>;
Authentication=Active Directory Service Principal;
User ID=<application-id>;
Password=<client-secret>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**Important Parameters:**
- **Server:** Fully qualified SQL Server name (e.g., `rhcdb-lam-sqlsvr.database.windows.net`)
- **Database:** Specific database name (e.g., `lam_db`)
- **Authentication:** Must be `Active Directory Service Principal`
- **User ID:** Application (client) ID from App Registration (NOT the service principal object ID)
- **Password:** Client secret value from App Registration
- **Encrypt:** Always `True` for security
- **TrustServerCertificate:** `False` to validate server certificate

---

### 7.2: Connection Strings by Environment

**LAM Environment:**

```
Server=tcp:rhcdb-lam-sqlsvr.database.windows.net,1433;
Database=lam_db;
Authentication=Active Directory Service Principal;
User ID=<lam-app-id-here>;
Password=<lam-secret-here>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**QA Environment - Corporate Database:**

```
Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;
Database=qa_corp_db;
Authentication=Active Directory Service Principal;
User ID=<qa-app-id-here>;
Password=<qa-secret-here>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**QA Environment - HM2 Database:**

```
Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;
Database=qa_hm2_db;
Authentication=Active Directory Service Principal;
User ID=<qa-app-id-here>;
Password=<qa-secret-here>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**Production Environment - Corporate Database:**

```
Server=tcp:rhcdb-prod-sqlsvr.database.windows.net,1433;
Database=prod_corp_db;
Authentication=Active Directory Service Principal;
User ID=<prod-app-id-here>;
Password=<prod-secret-here>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

**Production Environment - HM2 Database:**

```
Server=tcp:rhcdb-prod-sqlsvr.database.windows.net,1433;
Database=prod_hm2_db;
Authentication=Active Directory Service Principal;
User ID=<prod-app-id-here>;
Password=<prod-secret-here>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

---

### 7.3: Connection Strings in Different Languages/Frameworks

#### .NET / C# (ADO.NET)

```csharp
using System.Data.SqlClient;

string connectionString = 
    "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;" +
    "Database=qa_corp_db;" +
    "Authentication=Active Directory Service Principal;" +
    $"User ID={Environment.GetEnvironmentVariable("DB_CLIENT_ID")};" +
    $"Password={Environment.GetEnvironmentVariable("DB_CLIENT_SECRET")};" +
    "Encrypt=True;" +
    "TrustServerCertificate=False;" +
    "Connection Timeout=30;";

using (SqlConnection connection = new SqlConnection(connectionString))
{
    connection.Open();
    Console.WriteLine("Connected successfully!");
}
```

#### .NET / C# (Entity Framework Core)

```csharp
// In appsettings.json or environment variables
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:rhcdb-qa-sqlsvr.database.windows.net,1433;Database=qa_corp_db;Authentication=Active Directory Service Principal;User ID={DB_CLIENT_ID};Password={DB_CLIENT_SECRET};Encrypt=True;TrustServerCertificate=False;"
  }
}

// In Program.cs or Startup.cs
services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(
        Configuration.GetConnectionString("DefaultConnection")
            .Replace("{DB_CLIENT_ID}", Environment.GetEnvironmentVariable("DB_CLIENT_ID"))
            .Replace("{DB_CLIENT_SECRET}", Environment.GetEnvironmentVariable("DB_CLIENT_SECRET"))
    ));
```

#### Python (pyodbc)

```python
import pyodbc
import os

server = 'rhcdb-qa-sqlsvr.database.windows.net'
database = 'qa_corp_db'
client_id = os.environ['DB_CLIENT_ID']
client_secret = os.environ['DB_CLIENT_SECRET']

connection_string = (
    f'DRIVER={{ODBC Driver 18 for SQL Server}};'
    f'SERVER={server};'
    f'DATABASE={database};'
    f'UID={client_id};'
    f'PWD={client_secret};'
    f'Authentication=ActiveDirectoryServicePrincipal;'
    f'Encrypt=yes;'
    f'TrustServerCertificate=no;'
)

conn = pyodbc.connect(connection_string)
cursor = conn.cursor()
cursor.execute("SELECT @@VERSION")
print(cursor.fetchone())
```

#### Node.js (mssql)

```javascript
const sql = require('mssql');

const config = {
    server: 'rhcdb-qa-sqlsvr.database.windows.net',
    database: 'qa_corp_db',
    authentication: {
        type: 'azure-active-directory-service-principal-secret',
        options: {
            clientId: process.env.DB_CLIENT_ID,
            clientSecret: process.env.DB_CLIENT_SECRET,
            tenantId: 'b62a8921-d524-41af-9807-1057f031ecda' // Database tenant ID
        }
    },
    options: {
        encrypt: true,
        trustServerCertificate: false
    }
};

async function connect() {
    try {
        await sql.connect(config);
        const result = await sql.query`SELECT @@VERSION`;
        console.log('Connected successfully!', result);
    } catch (err) {
        console.error('Connection failed:', err);
    }
}

connect();
```

#### Java (JDBC)

```java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {
    public static void main(String[] args) {
        String server = "rhcdb-qa-sqlsvr.database.windows.net";
        String database = "qa_corp_db";
        String clientId = System.getenv("DB_CLIENT_ID");
        String clientSecret = System.getenv("DB_CLIENT_SECRET");
        
        String connectionUrl = String.format(
            "jdbc:sqlserver://%s:1433;" +
            "database=%s;" +
            "authentication=ActiveDirectoryServicePrincipal;" +
            "user=%s;" +
            "password=%s;" +
            "encrypt=true;" +
            "trustServerCertificate=false;",
            server, database, clientId, clientSecret
        );
        
        try (Connection connection = DriverManager.getConnection(connectionUrl)) {
            System.out.println("Connected successfully!");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
```

---

### 7.4: Storing Connection Strings Securely

**❌ NEVER DO THIS:**
- Hard-code connection strings in source code
- Commit secrets to Git repositories
- Store secrets in plain text configuration files

**✅ BEST PRACTICES:**

#### Option 1: Environment Variables (Container Apps)

Container Apps support environment variables and secrets:

```bash
# When creating Container App (Phase 5)
az containerapp create \
  --name "qa-corp-app" \
  --environment "qa-container-env" \
  --secrets \
    db-client-id="<qa-app-id>" \
    db-client-secret="<qa-secret>" \
  --env-vars \
    "DB_SERVER=rhcdb-qa-sqlsvr.database.windows.net" \
    "DB_NAME=qa_corp_db" \
    "DB_CLIENT_ID=secretref:db-client-id" \
    "DB_CLIENT_SECRET=secretref:db-client-secret"
```

#### Option 2: Azure Key Vault References (Best)

Store secrets in Key Vault and reference them:

**In Key Vault (QA tenant):**
- Secret: `db-client-id` → `<qa-app-id>`
- Secret: `db-client-secret` → `<qa-secret>`
- Secret: `db-tenant-id` → `b62a8921-d524-41af-9807-1057f031ecda`

**In Container App:**
```bash
az containerapp create \
  --name "qa-corp-app" \
  --environment "qa-container-env" \
  --secrets \
    db-client-id="keyvaultref:<key-vault-url>/secrets/db-client-id,identityref:<managed-identity-id>" \
    db-client-secret="keyvaultref:<key-vault-url>/secrets/db-client-secret,identityref:<managed-identity-id>"
```

**In Application Code:**
```csharp
// Just read from environment - Container App handles Key Vault
string clientId = Environment.GetEnvironmentVariable("DB_CLIENT_ID");
string clientSecret = Environment.GetEnvironmentVariable("DB_CLIENT_SECRET");
```

---

### 7.5: Testing Connection Strings

**Before deploying to Container Apps, test locally:**

#### Using sqlcmd

```bash
# Set environment variables (PowerShell)
$env:DB_CLIENT_ID = "<your-app-id>"
$env:DB_CLIENT_SECRET = "<your-client-secret>"
$env:DB_TENANT_ID = "b62a8921-d524-41af-9807-1057f031ecda"

# Test connection with Service Principal
sqlcmd -S rhcdb-qa-sqlsvr.database.windows.net -d qa_corp_db `
  -G -U $env:DB_CLIENT_ID -P $env:DB_CLIENT_SECRET `
  -Q "SELECT @@VERSION; SELECT SYSTEM_USER, USER_NAME();"
```

Expected output should show:
```
SYSTEM_USER: app-qa-db-access
USER_NAME: db-qa-app-users
```

#### Using Azure Data Studio

1. **Create new connection**
2. **Server:** `rhcdb-qa-sqlsvr.database.windows.net`
3. **Authentication:** `Azure Active Directory - Service Principal`
4. **User ID:** `<your-app-id>`
5. **Password:** `<your-client-secret>`
6. **Database:** `qa_corp_db`
7. **Encrypt:** Yes
8. **Trust server certificate:** No
9. Click **Connect**

---

### 7.6: Connection String Checklist

Before using connection strings in production:

- [ ] App Registration created in Database tenant
- [ ] Client secret generated and saved securely
- [ ] Service Principal added to security group
- [ ] Security group registered as database user
- [ ] Database permissions granted (db_datareader, db_datawriter, EXECUTE)
- [ ] Connection string tested with sqlcmd or Azure Data Studio
- [ ] Secrets stored in Key Vault (not environment variables)
- [ ] Container App configured with Key Vault references
- [ ] Application code reads from environment variables
- [ ] Connection pooling configured (for performance)
- [ ] Connection timeouts set appropriately
- [ ] Retry logic implemented for transient failures

---

### 7.7: DBA Connection Strings (Admin Access)

Database administrators need to connect with their Entra ID accounts for management tasks.

**Who Can Connect:**
- Members of security groups: `db-lam-sqlsvr-admin`, `db-qa-sqlsvr-admin`, `db-prod-sqlsvr-admin`
- Users: Ron, Mike, Dave, Bruce

---

#### SQL Server Management Studio (SSMS)

**Connect to LAM SQL Server:**

1. **Open SSMS**
2. **Server name:** `rhcdb-lam-sqlsvr.database.windows.net`
3. **Authentication:** `Microsoft Entra MFA`
4. **Login:** `ron@recalibratehealthcare.com` (or your admin account)
5. **Database:** `lam_db` (or leave default)
6. **Encrypt connection:** ✅ Checked
7. Click **Connect**

**Connection String Format (for applications):**

```
Server=tcp:rhcdb-lam-sqlsvr.database.windows.net,1433;
Database=lam_db;
Authentication=Active Directory Interactive;
Encrypt=True;
TrustServerCertificate=False;
```

**For MFA-enabled accounts:**
```
Server=tcp:rhcdb-lam-sqlsvr.database.windows.net,1433;
Database=lam_db;
Authentication=Active Directory Universal with MFA;
Encrypt=True;
TrustServerCertificate=False;
```

---

#### Azure Data Studio

**Connect as Admin:**

1. **Open Azure Data Studio**
2. **New Connection**
3. **Connection type:** Microsoft SQL Server
4. **Server:** `rhcdb-qa-sqlsvr.database.windows.net`
5. **Authentication type:** `Microsoft Entra ID - Universal with MFA support`
6. **Account:** Select your admin account (or click "Add an account")
7. **Database:** `qa_corp_db` (or \<Default\>)
8. **Encrypt:** `Mandatory (True)`
9. **Trust server certificate:** `False`
10. **Connection name:** `QA SQL Server (Admin)`
11. Click **Connect**

**Pro Tip:** Save this connection profile for quick access!

---

#### sqlcmd (Command Line)

**Interactive Authentication (with MFA):**

```bash
# Connect to LAM database
sqlcmd -S rhcdb-lam-sqlsvr.database.windows.net -d lam_db -G -U ron@recalibratehealthcare.com

# Connect to QA database
sqlcmd -S rhcdb-qa-sqlsvr.database.windows.net -d qa_corp_db -G -U ron@recalibratehealthcare.com

# Connect to Production database
sqlcmd -S rhcdb-prod-sqlsvr.database.windows.net -d prod_corp_db -G -U ron@recalibratehealthcare.com
```

**Run a query without interactive login:**

```bash
# For accounts without MFA (or with cached credentials)
sqlcmd -S rhcdb-lam-sqlsvr.database.windows.net -d lam_db -G -U ron@recalibratehealthcare.com -Q "SELECT DB_NAME(), SYSTEM_USER;"
```

---

#### PowerShell (Invoke-Sqlcmd)

```powershell
# Install SqlServer module if not already installed
Install-Module -Name SqlServer -Scope CurrentUser

# Connect with Entra authentication
Invoke-Sqlcmd `
  -ServerInstance "rhcdb-lam-sqlsvr.database.windows.net" `
  -Database "lam_db" `
  -AccessToken (Get-AzAccessToken -ResourceUrl "https://database.windows.net/").Token `
  -Query "SELECT @@VERSION, SYSTEM_USER;"

# Or using integrated auth
Invoke-Sqlcmd `
  -ServerInstance "rhcdb-qa-sqlsvr.database.windows.net" `
  -Database "qa_corp_db" `
  -Username "ron@recalibratehealthcare.com" `
  -Authentication "ActiveDirectoryInteractive" `
  -Query "SELECT * FROM sys.database_principals WHERE type = 'E';"
```

---

#### Python (for Admin Scripts)

```python
import pyodbc
import struct
from azure.identity import DefaultAzureCredential

# Get access token
credential = DefaultAzureCredential()
token = credential.get_token("https://database.windows.net/.default")

# Convert token to ODBC format
token_bytes = token.token.encode("UTF-16-LE")
token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)

# Connect with token
connection_string = (
    "DRIVER={ODBC Driver 18 for SQL Server};"
    "SERVER=rhcdb-lam-sqlsvr.database.windows.net;"
    "DATABASE=lam_db;"
    "Encrypt=yes;"
    "TrustServerCertificate=no;"
)

conn = pyodbc.connect(connection_string, attrs_before={1256: token_struct})
cursor = conn.cursor()
cursor.execute("SELECT SYSTEM_USER, USER_NAME();")
print(cursor.fetchone())
```

---

#### .NET (for Admin Tools)

```csharp
using Azure.Identity;
using Microsoft.Data.SqlClient;

// Get access token using DefaultAzureCredential (works with logged-in user)
var credential = new DefaultAzureCredential();
var tokenRequestContext = new TokenRequestContext(new[] { "https://database.windows.net/.default" });
var token = await credential.GetTokenAsync(tokenRequestContext);

// Connect with access token
string connectionString = 
    "Server=tcp:rhcdb-lam-sqlsvr.database.windows.net,1433;" +
    "Database=lam_db;" +
    "Encrypt=True;" +
    "TrustServerCertificate=False;";

using (SqlConnection connection = new SqlConnection(connectionString))
{
    connection.AccessToken = token.Token;
    await connection.OpenAsync();
    Console.WriteLine("Connected as admin!");
}
```

---

### 7.8: Quick Reference Table

#### Application Connection Strings (Service Principals)

| Environment | Server | Database | App Registration | Group |
|-------------|--------|----------|------------------|-------|
| LAM | `rhcdb-lam-sqlsvr.database.windows.net` | `lam_db` | `app-lam-db-access` | `db-lam-app-users` |
| QA (Corp) | `rhcdb-qa-sqlsvr.database.windows.net` | `qa_corp_db` | `app-qa-db-access` | `db-qa-app-users` |
| QA (HM2) | `rhcdb-qa-sqlsvr.database.windows.net` | `qa_hm2_db` | `app-qa-db-access` | `db-qa-app-users` |
| Prod (Corp) | `rhcdb-prod-sqlsvr.database.windows.net` | `prod_corp_db` | `app-prod-db-access` | `db-prod-app-users` |
| Prod (HM2) | `rhcdb-prod-sqlsvr.database.windows.net` | `prod_hm2_db` | `app-prod-db-access` | `db-prod-app-users` |

#### Admin Connection Strings (Entra ID Users)

| Environment | Server | Database | Admin Group | Admin Members |
|-------------|--------|----------|-------------|---------------|
| LAM | `rhcdb-lam-sqlsvr.database.windows.net` | `lam_db` | `db-lam-sqlsvr-admin` | Ron, Mike, Dave, Bruce |
| QA | `rhcdb-qa-sqlsvr.database.windows.net` | `qa_corp_db`, `qa_hm2_db` | `db-qa-sqlsvr-admin` | Ron, Mike, Dave, Bruce |
| Production | `rhcdb-prod-sqlsvr.database.windows.net` | `prod_corp_db`, `prod_hm2_db` | `db-prod-sqlsvr-admin` | Ron, Mike, Dave, Bruce |

**Database Tenant ID (all environments):** `b62a8921-d524-41af-9807-1057f031ecda`

**Admin Authentication Types:**
- **Interactive (MFA):** `Active Directory Interactive` or `Active Directory Universal with MFA`
- **Service Principal:** `Active Directory Service Principal` (for applications only)
- **Access Token:** Use Azure CLI/SDK to get token, pass to connection

---

## 🔧 Step 8: Verification Scripts

Test everything is configured correctly before deploying applications.

---

### 8.1: Verify Azure Resources

Run these from your local machine with Azure CLI:

#### Verify All Resource Groups

```bash
# Login to Database tenant
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# List all resource groups
az group list --query "[].{Name:name, Location:location, State:properties.provisioningState}" -o table

# Expected output should show:
# - db-lam-rg
# - db-qa-rg  
# - db-prod-rg
```

#### Verify All SQL Servers

```bash
# List SQL Servers
az sql server list --query "[].{Name:name, Location:location, ResourceGroup:resourceGroup, AdminType:administrators.administratorType}" -o table

# Verify Managed Identity is enabled
az sql server show --name "rhcdb-lam-sqlsvr" -g "db-lam-rg" --query "{Name:name, Identity:identity.type, PrincipalId:identity.principalId}"
az sql server show --name "rhcdb-qa-sqlsvr" -g "db-qa-rg" --query "{Name:name, Identity:identity.type, PrincipalId:identity.principalId}"
az sql server show --name "rhcdb-prod-sqlsvr" -g "db-prod-rg" --query "{Name:name, Identity:identity.type, PrincipalId:identity.principalId}"

# Expected: identity.type = "SystemAssigned"
```

#### Verify All Databases

```bash
# List all databases across all servers
echo "LAM Databases:"
az sql db list -g "db-lam-rg" -s "lam-sqlsvr" --query "[].{Name:name, Status:status, Edition:edition}" -o table

echo ""
echo "QA Databases:"
az sql db list -g "db-qa-rg" -s "qa-sqlsvr" --query "[].{Name:name, Status:status, Edition:edition}" -o table

echo ""
echo "Production Databases:"
az sql db list -g "db-prod-rg" -s "prod-sqlsvr" --query "[].{Name:name, Status:status, Edition:edition}" -o table

# Expected: All databases show Status=Online, Edition=Standard
```

#### Verify Entra-Only Authentication

```bash
# Check if Entra-only auth is enabled
az sql server ad-only-auth get -g "db-lam-rg" -s "lam-sqlsvr" --query azureAdOnlyAuthentication
az sql server ad-only-auth get -g "db-qa-rg" -s "qa-sqlsvr" --query azureAdOnlyAuthentication
az sql server ad-only-auth get -g "db-prod-rg" -s "prod-sqlsvr" --query azureAdOnlyAuthentication

# Expected: true (for all three)
```

#### Verify Firewall Rules

```bash
# List firewall rules for each server
echo "LAM Firewall Rules:"
az sql server firewall-rule list -g "db-lam-rg" -s "lam-sqlsvr" -o table

echo ""
echo "QA Firewall Rules:"
az sql server firewall-rule list -g "db-qa-rg" -s "qa-sqlsvr" -o table

echo ""
echo "Production Firewall Rules:"
az sql server firewall-rule list -g "db-prod-rg" -s "prod-sqlsvr" -o table

# Expected: Should see "AllowAzureServices" rule (0.0.0.0 to 0.0.0.0)
```

---

### 8.2: Verify Entra Security Groups

```bash
# Verify admin security groups exist
echo "SQL Server Admin Groups:"
az ad group list --filter "startswith(displayName,'db-') and endswith(displayName,'-sqlsvr-admin')" --query "[].{Name:displayName, Id:id, Members:''}" -o table

# Verify app user security groups exist
echo ""
echo "App User Groups:"
az ad group list --filter "startswith(displayName,'db-') and endswith(displayName,'-app-users')" --query "[].{Name:displayName, Id:id}" -o table

# Verify admin group memberships
echo ""
echo "LAM SQL Server Admins:"
az ad group member list --group "db-lam-sqlsvr-admin" --query "[].{Name:displayName, Email:userPrincipalName, Type:userType}" -o table

echo ""
echo "QA SQL Server Admins:"
az ad group member list --group "db-qa-sqlsvr-admin" --query "[].{Name:displayName, Email:userPrincipalName, Type:userType}" -o table

echo ""
echo "Production SQL Server Admins:"
az ad group member list --group "db-prod-sqlsvr-admin" --query "[].{Name:displayName, Email:userPrincipalName, Type:userType}" -o table

# Expected: Ron, Mike, Dave, Bruce in each group

# Verify app group memberships
echo ""
echo "LAM App Users:"
az ad group member list --group "db-lam-app-users" --query "[].{Name:displayName, AppId:appId, Type:servicePrincipalType}" -o table

echo ""
echo "QA App Users:"
az ad group member list --group "db-qa-app-users" --query "[].{Name:displayName, AppId:appId, Type:servicePrincipalType}" -o table

echo ""
echo "Production App Users:"
az ad group member list --group "db-prod-app-users" --query "[].{Name:displayName, AppId:appId, Type:servicePrincipalType}" -o table

# Expected: app-lam-db-access, app-qa-db-access, app-prod-db-access
```

---

### 8.3: Verify App Registrations

```bash
# List app registrations
echo "App Registrations for Database Access:"
az ad app list --filter "startswith(displayName,'app-') and endswith(displayName,'-db-access')" --query "[].{Name:displayName, AppId:appId, SignInAudience:signInAudience}" -o table

# Get service principal details
echo ""
echo "Service Principals:"
az ad sp list --filter "startswith(displayName,'app-') and endswith(displayName,'-db-access')" --query "[].{Name:displayName, AppId:appId, Id:id}" -o table

# Verify secrets exist (won't show secret values, just metadata)
LAM_APP_ID=$(az ad app list --display-name "app-lam-db-access" --query [0].appId -o tsv)
QA_APP_ID=$(az ad app list --display-name "app-qa-db-access" --query [0].appId -o tsv)
PROD_APP_ID=$(az ad app list --display-name "app-prod-db-access" --query [0].appId -o tsv)

echo ""
echo "LAM App Credentials:"
az ad app credential list --id $LAM_APP_ID --query "[].{Type:type, DisplayName:displayName, EndDate:endDateTime}" -o table

echo ""
echo "QA App Credentials:"
az ad app credential list --id $QA_APP_ID --query "[].{Type:type, DisplayName:displayName, EndDate:endDateTime}" -o table

echo ""
echo "Production App Credentials:"
az ad app credential list --id $PROD_APP_ID --query "[].{Type:type, DisplayName:displayName, EndDate:endDateTime}" -o table

# Expected: Each should have at least one Password credential
```

---

### 8.4: Verify Database Users and Permissions

Connect to each database and verify the security groups are registered as users.

#### SQL Script: Verify LAM Database

```sql
-- Connect to lam_db as admin first!
USE lam_db;
GO

-- 1. Check database users
SELECT 
    name AS UserName,
    type_desc AS UserType,
    authentication_type_desc AS AuthType,
    create_date AS Created
FROM sys.database_principals
WHERE type IN ('E', 'X', 'S')  -- E=External, X=External Group, S=SQL User
ORDER BY create_date DESC;

-- Expected: db-lam-app-users (Type: EXTERNAL_GROUP)

-- 2. Check role memberships
SELECT 
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-lam-app-users'
ORDER BY r.name;

-- Expected: db_datareader, db_datawriter

-- 3. Check execute permissions
SELECT 
    dp.name AS PrincipalName,
    dp.type_desc AS PrincipalType,
    pe.permission_name AS Permission,
    pe.state_desc AS State
FROM sys.database_permissions pe
JOIN sys.database_principals dp ON pe.grantee_principal_id = dp.principal_id
WHERE dp.name = 'db-lam-app-users'
    AND pe.class_desc = 'DATABASE'
    AND pe.permission_name = 'EXECUTE';

-- Expected: EXECUTE permission GRANTED

-- 4. Verify admin access
SELECT 
    dp.name AS AdminName,
    dp.type_desc AS AdminType,
    r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE r.name IN ('db_owner', 'db_accessadmin', 'db_datareader', 'db_datawriter')
    AND dp.type = 'E'  -- External users
ORDER BY dp.name, r.name;

-- Expected: Should see admin users with appropriate roles
```

#### SQL Script: Verify QA Databases

```sql
-- Check qa_corp_db
USE qa_corp_db;
GO

SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'db-qa-app-users';

SELECT r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-qa-app-users';

-- Expected: db-qa-app-users exists with db_datareader, db_datawriter

-- Check qa_hm2_db
USE qa_hm2_db;
GO

SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'db-qa-app-users';

SELECT r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-qa-app-users';

-- Expected: db-qa-app-users exists in both databases
```

#### SQL Script: Verify Production Databases

```sql
-- Check prod_corp_db
USE prod_corp_db;
GO

SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'db-prod-app-users';

SELECT r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-prod-app-users';

-- Check prod_hm2_db
USE prod_hm2_db;
GO

SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'db-prod-app-users';

SELECT r.name AS RoleName
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
WHERE dp.name = 'db-prod-app-users';

-- Expected: db-prod-app-users exists in both databases
```

---

### 8.5: Test Admin Connectivity

Test that admins can connect using Entra authentication.

#### Test with sqlcmd

```bash
# Test LAM
sqlcmd -S rhcdb-lam-sqlsvr.database.windows.net -d lam_db -G -U ron@recalibratehealthcare.com -Q "SELECT SYSTEM_USER, USER_NAME(), DB_NAME();"

# Test QA
sqlcmd -S rhcdb-qa-sqlsvr.database.windows.net -d qa_corp_db -G -U ron@recalibratehealthcare.com -Q "SELECT SYSTEM_USER, USER_NAME(), DB_NAME();"

# Test Production
sqlcmd -S rhcdb-prod-sqlsvr.database.windows.net -d prod_corp_db -G -U ron@recalibratehealthcare.com -Q "SELECT SYSTEM_USER, USER_NAME(), DB_NAME();"

# Expected output for each:
# SYSTEM_USER: ron@recalibratehealthcare.com
# USER_NAME: dbo (admins map to dbo)
# DB_NAME: (respective database name)
```

#### Test from Azure Portal Query Editor

1. **Navigate to LAM database** (`lam_db`)
2. Click **Query editor** (left menu)
3. **Authenticate:** Microsoft Entra authentication
4. **Run:**
   ```sql
   SELECT 
       SYSTEM_USER AS 'Who I Am',
       USER_NAME() AS 'Mapped To',
       DB_NAME() AS 'Database',
       IS_MEMBER('db_owner') AS 'Is DB Owner';
   ```
5. **Expected:** Your Entra account, mapped to dbo, IS_MEMBER = 1

**Repeat for QA and Production databases.**

---

### 8.6: Test Service Principal Connectivity

Test cross-tenant authentication using the app registrations.

#### PowerShell Test Script

```powershell
# Replace with your actual values from Step 4.1
$LAM_CLIENT_ID = "<lam-app-id>"
$LAM_SECRET = "<lam-client-secret>"
$QA_CLIENT_ID = "<qa-app-id>"
$QA_SECRET = "<qa-client-secret>"
$PROD_CLIENT_ID = "<prod-app-id>"
$PROD_SECRET = "<prod-client-secret>"
$DB_TENANT_ID = "b62a8921-d524-41af-9807-1057f031ecda"

# Test LAM connection
Write-Host "Testing LAM Service Principal..." -ForegroundColor Cyan
try {
    $result = sqlcmd -S rhcdb-lam-sqlsvr.database.windows.net -d lam_db `
        -U $LAM_CLIENT_ID -P $LAM_SECRET -G `
        -Q "SELECT SYSTEM_USER, USER_NAME();" -W
    Write-Host "✅ LAM Connection Success" -ForegroundColor Green
    Write-Host $result
} catch {
    Write-Host "❌ LAM Connection Failed: $_" -ForegroundColor Red
}

# Test QA connection
Write-Host "`nTesting QA Service Principal..." -ForegroundColor Cyan
try {
    $result = sqlcmd -S rhcdb-qa-sqlsvr.database.windows.net -d qa_corp_db `
        -U $QA_CLIENT_ID -P $QA_SECRET -G `
        -Q "SELECT SYSTEM_USER, USER_NAME();" -W
    Write-Host "✅ QA Connection Success" -ForegroundColor Green
    Write-Host $result
} catch {
    Write-Host "❌ QA Connection Failed: $_" -ForegroundColor Red
}

# Test Production connection
Write-Host "`nTesting Production Service Principal..." -ForegroundColor Cyan
try {
    $result = sqlcmd -S rhcdb-prod-sqlsvr.database.windows.net -d prod_corp_db `
        -U $PROD_CLIENT_ID -P $PROD_SECRET -G `
        -Q "SELECT SYSTEM_USER, USER_NAME();" -W
    Write-Host "✅ Production Connection Success" -ForegroundColor Green
    Write-Host $result
} catch {
    Write-Host "❌ Production Connection Failed: $_" -ForegroundColor Red
}

# Expected SYSTEM_USER: app-lam-db-access, app-qa-db-access, app-prod-db-access
# Expected USER_NAME: db-lam-app-users, db-qa-app-users, db-prod-app-users
```

---

### 8.7: Verify SQL Authentication is Disabled

Attempt to connect with the SQL admin credentials (should fail).

```bash
# These should all FAIL with "Login failed"
sqlcmd -S rhcdb-lam-sqlsvr.database.windows.net -d lam_db -U sqlAdminNewGroot -P "IAmNewGroot!" -Q "SELECT 1"

sqlcmd -S rhcdb-qa-sqlsvr.database.windows.net -d qa_corp_db -U sqlAdminNewGroot -P "IAmNewGroot!" -Q "SELECT 1"

sqlcmd -S rhcdb-prod-sqlsvr.database.windows.net -d prod_corp_db -U sqlAdminNewGroot -P "IAmNewGroot!" -Q "SELECT 1"

# Expected error: "Login failed for user 'sqlAdminNewGroot'. Reason: Azure Active Directory only authentication is enabled."
# ✅ This confirms SQL authentication is properly disabled!
```

---

### 8.8: Complete Verification Checklist

Run through this checklist to ensure everything is configured correctly:

```markdown
## Phase 3 Verification Checklist

### Azure Resources
- [ ] 3 Resource groups created (db-lam-rg, db-qa-rg, db-prod-rg)
- [ ] 3 SQL Servers created (lam-sqlsvr, qa-sqlsvr, prod-sqlsvr)
- [ ] 5 Databases created (lam_db, qa_corp_db, qa_hm2_db, prod_corp_db, prod_hm2_db)
- [ ] All SQL Servers have System-Assigned Managed Identity enabled
- [ ] All SQL Servers have Entra-only authentication enabled
- [ ] Firewall rules allow Azure services (0.0.0.0)

### Security Groups
- [ ] 3 SQL admin groups created (db-lam-sqlsvr-admin, db-qa-sqlsvr-admin, db-prod-sqlsvr-admin)
- [ ] All 4 admins added to each group (Ron, Mike, Dave, Bruce)
- [ ] 3 App user groups created (db-lam-app-users, db-qa-app-users, db-prod-app-users)
- [ ] SQL admin groups set as Entra admins on respective SQL Servers

### App Registrations
- [ ] app-lam-db-access created in Database tenant
- [ ] app-qa-db-access created in Database tenant
- [ ] app-prod-db-access created in Database tenant
- [ ] Client secrets created for all 3 apps (and saved securely!)
- [ ] Service principals added to their respective app user groups

### Database Users
- [ ] db-lam-app-users registered in lam_db
- [ ] db-qa-app-users registered in qa_corp_db
- [ ] db-qa-app-users registered in qa_hm2_db
- [ ] db-prod-app-users registered in prod_corp_db
- [ ] db-prod-app-users registered in prod_hm2_db
- [ ] All groups have db_datareader + db_datawriter + EXECUTE permissions

### Connectivity Tests
- [ ] Admin can connect to LAM via SSMS/Azure Data Studio
- [ ] Admin can connect to QA via SSMS/Azure Data Studio
- [ ] Admin can connect to Production via SSMS/Azure Data Studio
- [ ] Service Principal can connect to LAM database
- [ ] Service Principal can connect to QA databases
- [ ] Service Principal can connect to Production databases
- [ ] SQL authentication fails (confirms disabled)

### Documentation
- [ ] App Registration credentials documented (Application IDs, Tenant ID)
- [ ] Client secrets stored in secure location (Key Vault or password manager)
- [ ] Connection strings documented for all environments
- [ ] Admin connection methods documented (SSMS, Azure Data Studio, sqlcmd)
```

---

### 8.9: Automated Verification Script

**Complete PowerShell script to verify everything:**

```powershell
<#
.SYNOPSIS
    Verify Phase 3 Database Tenant Setup
.DESCRIPTION
    Runs all verification checks for SQL Servers, databases, security groups, and connectivity
#>

Write-Host "==================================================" -ForegroundColor Yellow
Write-Host "  Phase 3 Database Tenant Verification Script" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow
Write-Host ""

# Login to Database tenant
Write-Host "Step 1: Logging into Database Tenant..." -ForegroundColor Cyan
az login --tenant rhcdb.onmicrosoft.com
az account set --subscription "subs-rhcdb"

# Verify Resource Groups
Write-Host "`nStep 2: Verifying Resource Groups..." -ForegroundColor Cyan
$rgs = az group list --query "[?starts_with(name, 'db-')].name" -o tsv
$expectedRGs = @("db-lam-rg", "db-qa-rg", "db-prod-rg")
foreach ($rg in $expectedRGs) {
    if ($rgs -contains $rg) {
        Write-Host "  ✅ $rg exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $rg missing" -ForegroundColor Red
    }
}

# Verify SQL Servers
Write-Host "`nStep 3: Verifying SQL Servers..." -ForegroundColor Cyan
$servers = @("lam-sqlsvr", "qa-sqlsvr", "prod-sqlsvr")
$rgs = @("db-lam-rg", "db-qa-rg", "db-prod-rg")
for ($i = 0; $i -lt $servers.Length; $i++) {
    $server = az sql server show --name $servers[$i] -g $rgs[$i] 2>$null
    if ($server) {
        Write-Host "  ✅ $($servers[$i]) exists" -ForegroundColor Green
        
        # Check Managed Identity
        $identity = az sql server show --name $servers[$i] -g $rgs[$i] --query "identity.type" -o tsv
        if ($identity -eq "SystemAssigned") {
            Write-Host "    ✅ Managed Identity enabled" -ForegroundColor Green
        } else {
            Write-Host "    ❌ Managed Identity not enabled" -ForegroundColor Red
        }
        
        # Check Entra-only auth
        $entraOnly = az sql server ad-only-auth get -g $rgs[$i] -s $servers[$i] --query "azureAdOnlyAuthentication" -o tsv
        if ($entraOnly -eq "true") {
            Write-Host "    ✅ Entra-only authentication enabled" -ForegroundColor Green
        } else {
            Write-Host "    ⚠️  Entra-only authentication not enabled" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ $($servers[$i]) missing" -ForegroundColor Red
    }
}

# Verify Databases
Write-Host "`nStep 4: Verifying Databases..." -ForegroundColor Cyan
$dbConfigs = @(
    @{Server="lam-sqlsvr"; RG="db-lam-rg"; DB="lam_db"},
    @{Server="qa-sqlsvr"; RG="db-qa-rg"; DB="qa_corp_db"},
    @{Server="qa-sqlsvr"; RG="db-qa-rg"; DB="qa_hm2_db"},
    @{Server="prod-sqlsvr"; RG="db-prod-rg"; DB="prod_corp_db"},
    @{Server="prod-sqlsvr"; RG="db-prod-rg"; DB="prod_hm2_db"}
)

foreach ($config in $dbConfigs) {
    $db = az sql db show -g $config.RG -s $config.Server -n $config.DB --query "name" -o tsv 2>$null
    if ($db) {
        Write-Host "  ✅ $($config.DB) exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($config.DB) missing" -ForegroundColor Red
    }
}

# Verify Security Groups
Write-Host "`nStep 5: Verifying Security Groups..." -ForegroundColor Cyan
$adminGroups = @("db-lam-sqlsvr-admin", "db-qa-sqlsvr-admin", "db-prod-sqlsvr-admin")
$appGroups = @("db-lam-app-users", "db-qa-app-users", "db-prod-app-users")

foreach ($group in $adminGroups) {
    $exists = az ad group show --group $group 2>$null
    if ($exists) {
        Write-Host "  ✅ $group exists" -ForegroundColor Green
        $memberCount = (az ad group member list --group $group --query "length(@)" -o tsv)
        Write-Host "    Members: $memberCount (expected: 4)" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ $group missing" -ForegroundColor Red
    }
}

foreach ($group in $appGroups) {
    $exists = az ad group show --group $group 2>$null
    if ($exists) {
        Write-Host "  ✅ $group exists" -ForegroundColor Green
        $memberCount = (az ad group member list --group $group --query "length(@)" -o tsv)
        Write-Host "    Members: $memberCount (expected: 1)" -ForegroundColor Gray
    } else {
        Write-Host "  ❌ $group missing" -ForegroundColor Red
    }
}

# Verify App Registrations
Write-Host "`nStep 6: Verifying App Registrations..." -ForegroundColor Cyan
$apps = @("app-lam-db-access", "app-qa-db-access", "app-prod-db-access")
foreach ($app in $apps) {
    $exists = az ad app list --display-name $app --query "[0].appId" -o tsv 2>$null
    if ($exists) {
        Write-Host "  ✅ $app exists (App ID: $exists)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $app missing" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Yellow
Write-Host "  Verification Complete!" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "⚠️  Manual steps still required:" -ForegroundColor Yellow
Write-Host "  1. Test admin connectivity (SSMS/Azure Data Studio)" -ForegroundColor Gray
Write-Host "  2. Verify database users with SQL queries" -ForegroundColor Gray
Write-Host "  3. Test service principal connectivity" -ForegroundColor Gray
Write-Host "  4. Confirm SQL authentication fails" -ForegroundColor Gray
```

Save as `Verify-Phase3.ps1` and run after completing all setup steps!

---

## 🔧 Step 9: Enable Database Diagnostics and Connection Monitoring

**🎯 Goal:** Capture connection attempts, authentication failures, and query performance for troubleshooting.

**When connections fail, this is where you look first!**

---

### 9.1: Create Log Analytics Workspace

Central location to store and query all database diagnostic logs.

#### Via Azure Portal

1. **Navigate to Log Analytics Workspaces**
   - Ensure you're in `rhcdb.onmicrosoft.com` tenant
   - Search for "Log Analytics workspaces"
   - Click **+ Create**

2. **Basics Tab**
   - **Subscription:** `subs-rhcdb`
   - **Resource group:** `db-lam-rg` (we'll use one workspace for all environments)
   - **Name:** `db-diagnostics-workspace`
   - **Region:** `East US 2`

3. **Pricing Tier**
   - **Pricing tier:** Pay-as-you-go (default)
   - **Daily cap:** Optional (e.g., 1 GB/day to control costs)

4. **Tags**
   - Environment: `Shared`
   - Purpose: `Diagnostics`

5. **Review + Create** → **Create**

#### Via Azure CLI

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group "db-lam-rg" \
  --workspace-name "db-diagnostics-workspace" \
  --location "eastus2" \
  --sku "PerGB2018" \
  --retention-time 30 \
  --tags Environment=Shared Purpose=Diagnostics

# Get workspace ID (save this!)
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "db-lam-rg" \
  --workspace-name "db-diagnostics-workspace" \
  --query id -o tsv)

echo "Workspace ID: $WORKSPACE_ID"
```

---

### 9.2: Enable Diagnostic Settings on SQL Servers

Configure each SQL Server to send logs to Log Analytics.

#### Logs to Enable (Most Important for Connectivity)

| Log Category | What It Captures | When to Use |
|--------------|------------------|-------------|
| **SQLSecurityAuditEvents** | Authentication attempts (success/failure) | Connection failures, auth errors |
| **Errors** | Database errors and warnings | Application errors, timeouts |
| **Timeouts** | Query and connection timeouts | Slow connections, deadlocks |
| **Blocks** | Blocking queries | Performance issues |
| **DatabaseWaitStatistics** | What queries are waiting on | Performance analysis |
| **QueryStoreRuntimeStatistics** | Query execution performance | Slow query diagnosis |

---

#### Via Azure Portal (LAM SQL Server)

1. **Navigate to SQL Server**
   - Go to `rhcdb-lam-sqlsvr`
   - Click **Diagnostic settings** (under Monitoring)

2. **Add Diagnostic Setting**
   - Click **+ Add diagnostic setting**
   - **Name:** `lam-diagnostics`

3. **Select Logs**
   - ✅ **SQLSecurityAuditEvents** (Critical!)
   - ✅ **Errors**
   - ✅ **Timeouts**
   - ✅ **Blocks**
   - ✅ **DatabaseWaitStatistics**
   - ✅ **QueryStoreRuntimeStatistics**

4. **Destination**
   - ✅ **Send to Log Analytics workspace**
   - **Subscription:** `subs-rhcdb`
   - **Log Analytics workspace:** `db-diagnostics-workspace`

5. **Save**

**Repeat for QA and Production SQL Servers.**

---

#### Via Azure CLI (All Servers)

```bash
# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --resource-group "db-lam-rg" \
  --workspace-name "db-diagnostics-workspace" \
  --query id -o tsv)

# Enable diagnostics on LAM SQL Server
az monitor diagnostic-settings create \
  --name "lam-diagnostics" \
  --resource "/subscriptions/d2d3adf5-0ad7-41f5-853e-0a99cc123733/resourceGroups/db-lam-rg/providers/Microsoft.Sql/servers/lam-sqlsvr" \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "SQLSecurityAuditEvents", "enabled": true},
    {"category": "Errors", "enabled": true},
    {"category": "Timeouts", "enabled": true},
    {"category": "Blocks", "enabled": true},
    {"category": "DatabaseWaitStatistics", "enabled": true},
    {"category": "QueryStoreRuntimeStatistics", "enabled": true}
  ]'

# Enable diagnostics on QA SQL Server
az monitor diagnostic-settings create \
  --name "qa-diagnostics" \
  --resource "/subscriptions/d2d3adf5-0ad7-41f5-853e-0a99cc123733/resourceGroups/db-qa-rg/providers/Microsoft.Sql/servers/qa-sqlsvr" \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "SQLSecurityAuditEvents", "enabled": true},
    {"category": "Errors", "enabled": true},
    {"category": "Timeouts", "enabled": true},
    {"category": "Blocks", "enabled": true},
    {"category": "DatabaseWaitStatistics", "enabled": true},
    {"category": "QueryStoreRuntimeStatistics", "enabled": true}
  ]'

# Enable diagnostics on Production SQL Server
az monitor diagnostic-settings create \
  --name "prod-diagnostics" \
  --resource "/subscriptions/d2d3adf5-0ad7-41f5-853e-0a99cc123733/resourceGroups/db-prod-rg/providers/Microsoft.Sql/servers/prod-sqlsvr" \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "SQLSecurityAuditEvents", "enabled": true},
    {"category": "Errors", "enabled": true},
    {"category": "Timeouts", "enabled": true},
    {"category": "Blocks", "enabled": true},
    {"category": "DatabaseWaitStatistics", "enabled": true},
    {"category": "QueryStoreRuntimeStatistics", "enabled": true}
  ]'

# Verify diagnostic settings
az monitor diagnostic-settings list \
  --resource "/subscriptions/d2d3adf5-0ad7-41f5-853e-0a99cc123733/resourceGroups/db-lam-rg/providers/Microsoft.Sql/servers/lam-sqlsvr" \
  --query "[].{Name:name, Logs:logs[?enabled==\`true\`].category}" -o table
```

---

### 9.3: Enable Diagnostic Settings on Databases

Each database can also send detailed logs.

#### Via Azure CLI (LAM Database)

```bash
# Enable diagnostics on lam_db
az monitor diagnostic-settings create \
  --name "lam-db-diagnostics" \
  --resource "/subscriptions/d2d3adf5-0ad7-41f5-853e-0a99cc123733/resourceGroups/db-lam-rg/providers/Microsoft.Sql/servers/lam-sqlsvr/databases/lam_db" \
  --workspace $WORKSPACE_ID \
  --logs '[
    {"category": "Errors", "enabled": true},
    {"category": "QueryStoreRuntimeStatistics", "enabled": true},
    {"category": "QueryStoreWaitStatistics", "enabled": true},
    {"category": "Timeouts", "enabled": true},
    {"category": "Blocks", "enabled": true}
  ]' \
  --metrics '[
    {"category": "Basic", "enabled": true},
    {"category": "InstanceAndAppAdvanced", "enabled": true}
  ]'

# Repeat for other databases...
# qa_corp_db, qa_hm2_db, prod_corp_db, prod_hm2_db
```

---

### 9.4: Troubleshooting Queries - Where to Look When Connections Fail

Access these queries in the Azure Portal:
1. Go to **Log Analytics workspace** (`db-diagnostics-workspace`)
2. Click **Logs** (under General)
3. Run these KQL queries

---

#### Query 1: All Connection Attempts (Last 24 Hours)

**Use when:** You want to see if connections are reaching the database

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "SQLSecurityAuditEvents"
| where action_name_s == "DATABASE AUTHENTICATION SUCCEEDED" or action_name_s == "DATABASE AUTHENTICATION FAILED"
| project TimeGenerated, 
          Resource, 
          database_name_s,
          server_principal_name_s,
          client_ip_s,
          action_name_s,
          succeeded_s
| order by TimeGenerated desc
```

**What to look for:**
- ✅ "DATABASE AUTHENTICATION SUCCEEDED" = Good!
- ❌ "DATABASE AUTHENTICATION FAILED" = Check service principal, permissions, or expired secrets

---

#### Query 2: Failed Authentication Attempts

**Use when:** Apps can't connect - shows WHY authentication failed

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "SQLSecurityAuditEvents"
| where action_name_s == "DATABASE AUTHENTICATION FAILED"
| project TimeGenerated,
          Resource,
          database_name_s,
          server_principal_name_s as FailedPrincipal,
          client_ip_s as SourceIP,
          additional_information_s as ErrorDetails
| order by TimeGenerated desc
```

**Common errors:**
- **"Login failed for user"** → Service principal not registered as database user
- **"Azure Active Directory only authentication"** → Trying to use SQL auth when disabled
- **"Cannot open server"** → Firewall blocking connection
- **"User does not have permission"** → Service principal not in security group

---

#### Query 3: Connection Timeouts

**Use when:** Apps report slow connections or timeouts

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "Timeouts"
| project TimeGenerated,
          Resource,
          database_name_s,
          query_hash_s,
          query_time_ms_d,
          LogicalServerName_s
| order by TimeGenerated desc
```

**What to look for:**
- Multiple timeouts from same app → Network issues or DNS problems
- High query_time_ms → Query needs optimization

---

#### Query 4: Connection Errors by Type

**Use when:** You need to understand the pattern of failures

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "Errors"
| summarize ErrorCount = count() by error_number_d, error_message_s, database_name_s
| order by ErrorCount desc
```

**Common error numbers:**
- **18456** → Authentication failed
- **40613** → Database unavailable
- **40197** → Service error processing request
- **40501** → Service busy

---

#### Query 5: Successful Connections by Service Principal

**Use when:** You want to confirm which apps are connecting successfully

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "SQLSecurityAuditEvents"
| where action_name_s == "DATABASE AUTHENTICATION SUCCEEDED"
| where server_principal_name_s startswith "app-"
| summarize ConnectionCount = count() by 
            server_principal_name_s,
            database_name_s,
            client_ip_s
| order by ConnectionCount desc
```

**Expected results:**
- `app-lam-db-access` connecting to `lam_db`
- `app-qa-db-access` connecting to `qa_corp_db` and `qa_hm2_db`
- `app-prod-db-access` connecting to `prod_corp_db` and `prod_hm2_db`

---

#### Query 6: Connection Timeline (Visual)

**Use when:** You want to see connection patterns over time

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "SQLSecurityAuditEvents"
| where action_name_s contains "AUTHENTICATION"
| summarize Successful = countif(succeeded_s == "true"),
            Failed = countif(succeeded_s == "false")
            by bin(TimeGenerated, 1h), database_name_s
| render timechart
```

**What to look for:**
- Spikes in failures → Investigate that time period
- No connections at expected times → App not running or can't reach database

---

#### Query 7: Blocking Queries (Performance)

**Use when:** Apps report hangs or very slow queries

```kql
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category == "Blocks"
| project TimeGenerated,
          database_name_s,
          duration_ms_d,
          wait_resource_s,
          wait_type_s
| order by duration_ms_d desc
```

---

### 9.5: Create Alerts for Connection Failures

Get notified when connections start failing.

#### Via Azure Portal

1. **Navigate to Log Analytics Workspace**
   - Go to `db-diagnostics-workspace`
   - Click **Alerts** → **+ Create** → **Alert rule**

2. **Condition**
   - Click **Add condition**
   - **Signal:** Custom log search
   - **Query:**
     ```kql
     AzureDiagnostics
     | where Category == "SQLSecurityAuditEvents"
     | where action_name_s == "DATABASE AUTHENTICATION FAILED"
     | summarize FailureCount = count() by bin(TimeGenerated, 5m)
     | where FailureCount > 5
     ```
   - **Alert logic:**
     - **Threshold:** Greater than 5 failures in 5 minutes
     - **Frequency:** Check every 5 minutes

3. **Actions**
   - Create action group
   - **Email:** `ron@recalibratehealthcare.com`
   - **SMS:** Optional

4. **Alert Details**
   - **Alert rule name:** `Database Authentication Failures`
   - **Severity:** Error (Sev 2)

5. **Create**

---

#### Via Azure CLI

```bash
# Create action group for email notifications
az monitor action-group create \
  --name "db-alerts-group" \
  --resource-group "db-lam-rg" \
  --short-name "dbalerts" \
  --email-receiver name="Ron" email="ron@recalibratehealthcare.com"

# Get action group ID
ACTION_GROUP_ID=$(az monitor action-group show \
  --name "db-alerts-group" \
  --resource-group "db-lam-rg" \
  --query id -o tsv)

# Create alert rule for authentication failures
az monitor scheduled-query create \
  --name "db-auth-failures" \
  --resource-group "db-lam-rg" \
  --scopes $WORKSPACE_ID \
  --condition "count 'Aggregated' > 5" \
  --condition-query "AzureDiagnostics | where Category == 'SQLSecurityAuditEvents' | where action_name_s == 'DATABASE AUTHENTICATION FAILED'" \
  --evaluation-frequency 5m \
  --window-size 5m \
  --severity 2 \
  --action-groups $ACTION_GROUP_ID \
  --description "Alert when more than 5 database authentication failures occur in 5 minutes"
```

---

### 9.6: Diagnostic Dashboard (Quick View)

Create a saved query for daily health checks.

#### Via Azure Portal

1. **Navigate to Log Analytics Workspace**
2. Click **Logs**
3. Paste this query:

```kql
// Database Connection Health Dashboard
let timeRange = ago(24h);
let authAttempts = AzureDiagnostics
| where TimeGenerated > timeRange
| where Category == "SQLSecurityAuditEvents"
| summarize 
    TotalAttempts = count(),
    Successful = countif(succeeded_s == "true"),
    Failed = countif(succeeded_s == "false")
    by database_name_s;
let errors = AzureDiagnostics
| where TimeGenerated > timeRange
| where Category == "Errors"
| summarize ErrorCount = count() by database_name_s;
let timeouts = AzureDiagnostics
| where TimeGenerated > timeRange
| where Category == "Timeouts"
| summarize TimeoutCount = count() by database_name_s;
authAttempts
| join kind=leftouter (errors) on database_name_s
| join kind=leftouter (timeouts) on database_name_s
| project 
    Database = database_name_s,
    TotalAttempts,
    Successful,
    Failed,
    SuccessRate = round(Successful * 100.0 / TotalAttempts, 2),
    Errors = coalesce(ErrorCount, 0),
    Timeouts = coalesce(TimeoutCount, 0)
| order by Failed desc
```

4. **Save** → Name it `Database Connection Health`

**Run this every morning to check for issues!**

---

### 9.7: Troubleshooting Checklist - When Connections Fail

```markdown
## Connection Failure Troubleshooting Guide

### Step 1: Check if connection attempt reached the database
- [ ] Run Query 1 (All Connection Attempts) in Log Analytics
- [ ] If NO logs: Firewall issue or wrong server name
- [ ] If logs show "FAILED": Authentication issue (go to Step 2)

### Step 2: Identify authentication error
- [ ] Run Query 2 (Failed Authentication Attempts)
- [ ] Check `ErrorDetails` column for specific error message
- [ ] Common fixes:
  - [ ] "Login failed" → Service principal not registered as database user (Step 4.3)
  - [ ] "Azure AD only" → App using SQL auth instead of Service Principal (Step 7)
  - [ ] "User does not have permission" → Service principal not in security group (Step 4.2)

### Step 3: Verify service principal configuration
- [ ] Run Query 5 (Successful Connections by Service Principal)
- [ ] If app never connected successfully:
  - [ ] Verify app registration exists (Step 4.1)
  - [ ] Check client secret not expired (Step 8.3)
  - [ ] Confirm service principal in security group (Step 8.2)
  - [ ] Verify security group registered in database (Step 8.4)

### Step 4: Check network/firewall
- [ ] Run: `az sql server firewall-rule list -g <rg> -s <server> -o table`
- [ ] Verify "AllowAzureServices" rule exists (0.0.0.0 to 0.0.0.0)
- [ ] If connecting from specific IP, add firewall rule for that IP

### Step 5: Test connection directly
- [ ] Use sqlcmd to test Service Principal auth (Step 8.6)
- [ ] If sqlcmd fails with same error: Configuration issue (not app issue)
- [ ] If sqlcmd works: App connection string issue (Step 7)

### Step 6: Verify connection string
- [ ] Check Server name: `<server>.database.windows.net` (not just `<server>`)
- [ ] Check Database name: Exact match (case-sensitive in some drivers)
- [ ] Check Authentication: `Active Directory Service Principal`
- [ ] Check User ID: Application (client) ID, NOT service principal object ID
- [ ] Check Password: Client secret value (not secret ID)

### Step 7: Check for transient errors
- [ ] Run Query 4 (Connection Errors by Type)
- [ ] Error 40613 (database unavailable): Retry after 60 seconds
- [ ] Error 40197/40501 (service busy): Implement exponential backoff
```

---

### 9.8: Log Retention and Costs

**Log Analytics Pricing:**
- **Data ingestion:** ~$2.30 per GB ingested
- **Data retention:** First 31 days free, then ~$0.12 per GB/month

**Expected daily log volume:**
- **Low traffic (early days):** ~100 MB/day = ~$7/month
- **Medium traffic:** ~500 MB/day = ~$35/month
- **High traffic:** ~2 GB/day = ~$140/month

**Cost control tips:**
- Set daily cap on workspace (e.g., 1 GB/day)
- Disable verbose logs (QueryStoreRuntimeStatistics) after initial testing
- Keep SQLSecurityAuditEvents, Errors, Timeouts always enabled
- Archive logs to Storage Account after 31 days for compliance

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
- [x] SQL Server: rhc-rhcdb-qa-sqlsvr.database.windows.net
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
