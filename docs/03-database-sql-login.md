# 🔐 Re-Enable SQL Admin Account for QA Databases

**Status:** 🔴 REQUIRED IMMEDIATELY  
**Priority:** HIGH  
**Created:** November 13, 2025

---

## ⚠️ IMMEDIATE ACTION REQUIRED

The QA databases need the SQL admin account **re-enabled temporarily** to support cross-database and cross-table automation operations until DBA reviews proper solution.

### Current State:
- ❌ SQL authentication is **DISABLED** (Entra-only authentication configured in Phase 3)
- ✅ SQL admin account `sqlAdminNewGroot` exists but is disabled
- ❌ Automation processes cannot run without SQL login access

### Why SQL Authentication is Needed:
- Cross-database queries between `qa_corp_db` and `qa_hp2_db`
- Cross-table automation operations
- Entra-only auth blocks context switching and three-part naming

---

## 🔧 Simple Fix: Re-Enable SQL Admin Account

### Step 1: Enable SQL Authentication (Hybrid Mode)

```bash
# Login to Database tenant
az login --tenant rhcdbase.onmicrosoft.com
az account set --subscription "subs-rhcdbase"

# Disable Entra-only authentication (enables SQL auth in hybrid mode)
az sql server ad-only-auth disable \
  --resource-group "db-qa-rg" \
  --name "rhcdb-qa-sqlsvr"
```

**What this does:**
- Re-enables SQL admin account access
- Keeps Entra authentication active for DBA access
- No new users or permissions needed
- Minimal change - just flipping a switch

### Step 2: Verify SQL Authentication is Enabled

```bash
# Verify the change
az sql server show \
  --resource-group "db-qa-rg" \
  --name "rhcdb-qa-sqlsvr" \
  --query "{Name:name, AdminLogin:administratorLogin, EntraOnly:administrators.azureAdOnlyAuthentication}" \
  --output table
```

**Expected output:**
```
Name             AdminLogin       EntraOnly
---------------  ---------------  -----------
rhcdb-qa-sqlsvr  CloudSA21507cc1  False
```

✅ `EntraOnly: False` confirms SQL authentication is enabled!

### Step 3: Test SQL Admin Connection

```bash
# Test connection using SSMS or Azure Data Studio:
# Server: rhcdb-qa-sqlsvr.database.windows.net
# Authentication: SQL Server Authentication
# Login: CloudSA21507cc1
# Password: <password-from-phase-3>
```

**Via Azure Portal:**
1. Navigate to `rhcdb-qa-sqlsvr`
2. Go to **Settings** > **Azure Active Directory**
3. Verify "Support only Azure Active Directory authentication" is **UNCHECKED**

---

## 📝 SQL Admin Account Details

**Account Information:**
- **Username:** `CloudSA21507cc1`
- **Created:** Phase 3 (November 11, 2025)
- **Server:** `rhcdb-qa-sqlsvr.database.windows.net`
- **Access Level:** Full administrative access (sysadmin)
- **Databases:** `qa_corp_db`, `qa_hp2_db`

**Current Status:**
- Account exists but disabled due to Entra-only auth setting
- Re-enabling SQL auth will immediately restore access
- No new permissions or users need to be created

---

## 🔒 Security Notes

**This is a temporary measure:**
- ✅ Quick fix to unblock automation work
- ⏳ DBA will review and implement proper solution
- ⚠️ SQL admin has full server access - use carefully
- 🔐 Ensure password is stored securely

**Hybrid Mode Benefits:**
- Entra ID auth still active for DBA team
- SQL admin available for cross-database operations
- Both authentication methods work simultaneously
- Easy to disable SQL auth again later if needed

---

## ✅ Checklist

- [x] Enable SQL authentication on `rhcdb-qa-sqlsvr` (disabled Entra-only auth) ✅ **COMPLETE**
- [x] Verify SQL authentication enabled (`EntraOnly: False`) ✅ **COMPLETE**
- [ ] Test SQL admin login: `CloudSA21507cc1`
- [ ] Verify cross-database query capability
- [ ] Notify DBA that SQL auth is re-enabled
- [ ] Document temporary nature of this configuration
- [ ] Wait for DBA to implement proper long-term solution

---

## 🔴 Why This is Needed Now

**Without SQL authentication enabled:**
- ❌ Cross-database queries fail
- ❌ Automation processes cannot run
- ❌ Context switching between databases blocked
- ❌ Three-part naming (`database.schema.table`) doesn't work

**With SQL admin re-enabled:**
- ✅ Automation can proceed immediately
- ✅ Full cross-database capabilities restored
- ✅ Minimal configuration change
- ✅ Can be refined later by DBA

---

**Related Documents:**
- [03-database-tenant-setup.md](./03-database-tenant-setup.md) - Database infrastructure
- [03-database-xt-access.md](./03-database-xt-access.md) - Cross-tenant authentication patterns
- [05-resource-groups-and-services.md](./05-resource-groups-and-services.md) - Key Vault configuration
