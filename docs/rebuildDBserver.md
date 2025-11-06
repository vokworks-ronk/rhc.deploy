# 🔥 Database Tenant Rebuild - CIAM to Workforce Migration

**Status:** Ready to Execute  
**Reason:** Current tenant is CIAM (Customer Identity) type, which does not support SQL Server workforce authentication  
**Impact:** Complete rebuild of Database tenant infrastructure  
**Data Loss:** None (databases are empty)

---

## 🎯 Problem Summary

The current Database tenant (`rhcdb.onmicrosoft.com`) was created as a **CIAM tenant** (Entra External ID for customers). This tenant type:

- ❌ Does not support SQL Server authentication with SSMS/workforce tools
- ❌ Causes `AADSTS500208` errors even for local accounts
- ❌ Designed for customer-facing apps, not enterprise administration
- ❌ Cannot be converted to workforce tenant

**Solution:** Delete everything and rebuild with a proper **workforce Entra ID tenant**.

---

## 📋 Pre-Rebuild Checklist

- [ ] Confirm all databases are empty (no production data)
- [ ] Document current app registration client secrets (if any apps deployed)
- [ ] Save connection string templates from Phase 3 docs
- [ ] Backup any custom T-SQL scripts or database schemas
- [ ] Notify team that Database tenant will be rebuilt

---

## 🗑️ Phase 1: Delete Current Infrastructure

### 1.1: Switch to Database Tenant Context

```powershell
# Login and set context
az login
az account set --subscription "subs-rhcdb"
az account show
```

### 1.2: Delete All Databases

```powershell
# Delete LAM database
az sql db delete --resource-group "db-lam-rg" --server "rhcdb-lam-sqlsvr" --name "lam_db" --yes

# Delete QA databases
az sql db delete --resource-group "db-qa-rg" --server "rhcdb-qa-sqlsvr" --name "qa_corp_db" --yes
az sql db delete --resource-group "db-qa-rg" --server "rhcdb-qa-sqlsvr" --name "qa_hp2_db" --yes

# Delete Production databases
az sql db delete --resource-group "db-prod-rg" --server "rhcdb-prod-sqlsvr" --name "prod_corp_db" --yes
az sql db delete --resource-group "db-prod-rg" --server "rhcdb-prod-sqlsvr" --name "prod_hp2_db" --yes
```

### 1.3: Delete SQL Servers

```powershell
# Delete LAM server
az sql server delete --resource-group "db-lam-rg" --name "rhcdb-lam-sqlsvr" --yes

# Delete QA server
az sql server delete --resource-group "db-qa-rg" --name "rhcdb-qa-sqlsvr" --yes

# Delete Production server
az sql server delete --resource-group "db-prod-rg" --name "rhcdb-prod-sqlsvr" --yes
```

### 1.4: Delete Log Analytics Workspace

```powershell
az monitor log-analytics workspace delete --resource-group "db-lam-rg" --workspace-name "rhcdb-audit-logs" --yes --force
```

### 1.5: Delete Resource Groups

```powershell
az group delete --name "db-lam-rg" --yes --no-wait
az group delete --name "db-qa-rg" --yes --no-wait
az group delete --name "db-prod-rg" --yes --no-wait
```

**Wait 10-15 minutes for all deletions to complete.**

### 1.6: Verify All Resources Deleted

```powershell
az resource list --subscription "subs-rhcdb" -o table
```

Should return empty or only metadata resources.

### 1.7: Delete the Subscription

**Option A: Via Portal (Recommended)**
1. Go to https://portal.azure.com
2. Navigate to **Subscriptions**
3. Select `subs-rhcdb`
4. Click **Cancel subscription**
5. Follow prompts to confirm cancellation

**Option B: Via CLI**
```powershell
# Note: Subscription deletion requires Owner role
az account subscription cancel --subscription-id "d2d3adf5-0ad7-41f5-853e-0a99cc123733"
```

### 1.8: Delete the CIAM Tenant

**⚠️ IMPORTANT:** You cannot delete a tenant until all subscriptions are removed and there's a 30-day waiting period for cancelled subscriptions.

**Tenant Deletion Process:**

1. **Remove all subscriptions** (done in step 1.7)

2. **Wait for subscription deletion to complete** (up to 24 hours)

3. **Delete via Azure Portal:**
   - Go to https://portal.azure.com
   - Switch to Database tenant (rhcdb.onmicrosoft.com)
   - Navigate to **Microsoft Entra ID**
   - Go to **Overview** → **Manage tenant**
   - Click **Delete tenant**
   - Follow the checklist to remove blockers:
     - Delete all users
     - Delete all groups
     - Delete all app registrations
     - Delete all enterprise applications
   - Confirm deletion

4. **Alternative - Just abandon it:**
   - If deletion is blocked, you can simply stop using the tenant
   - No cost for an unused tenant
   - Can formally delete later when Azure allows it

---

## 🆕 Phase 2: Create New Workforce Tenant

### 2.1: Create New Entra ID Workforce Tenant

**Via Azure Portal (Recommended):**

1. Go to https://portal.azure.com (in your work tenant or personal account)
2. Search for **Tenant** or **Microsoft Entra ID**
3. Click **Manage tenants** → **Create**
4. Select **Workforce** (NOT External ID / CIAM!)
5. Fill in details:
   - **Organization name:** `RHC Database Administration`
   - **Initial domain name:** `rhcdbase` (must be unique)
   - **Country/Region:** United States
6. Review and create
7. Wait 2-3 minutes for tenant creation
8. **Switch to the new tenant**

**Verify tenant type:**
```powershell
az login --tenant <new-tenant-id>
az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" --headers "Content-Type=application/json" | ConvertFrom-Json | Select-Object -ExpandProperty value | Select-Object displayName, tenantType
```

**Should show:** `tenantType: AAD` (not CIAM)

### 2.2: Document New Tenant Information

| Property | Value |
|----------|-------|
| **Tenant Name** | RHC Database Administration |
| **Domain** | rhcdbase.onmicrosoft.com |
| **Tenant ID** | _(record from portal)_ |
| **Tenant Type** | AAD (Workforce) ✅ |
| **Created Date** | _(today's date)_ |

---

## 🔨 Phase 3: Rebuild Database Infrastructure

### 3.1: Create New Subscription in New Tenant

**Via Azure Portal:**

1. Still logged into new tenant
2. Go to **Subscriptions** → **Add**
3. Select subscription type (Pay-As-You-Go or EA)
4. Name: `subs-rhcdbase`
5. Complete billing setup
6. Record new subscription ID

**Set as default:**
```powershell
az account set --subscription "subs-rhcdbase"
```

### 3.2: Follow Phase 3 Documentation

**Now execute the ORIGINAL Phase 3 plan** (`docs/03-database-tenant-setup.md`) with the new tenant:

- ✅ Step 1: Create security groups
- ✅ Step 2: Create resource groups
- ✅ Step 3: Create SQL Servers (Entra-only auth)
- ✅ Step 4: Create databases
- ✅ Step 4.1-4.3: App registrations and database users
- ✅ Step 5: Enable audit logging
- ✅ Step 6: Enable Microsoft Defender
- ✅ Step 7: Document connection strings
- ✅ Step 8: Run verification script

**Key differences for rebuild:**
- All commands will work correctly with workforce tenant
- SSMS authentication will work seamlessly
- Local user accounts will authenticate properly
- No cross-tenant authentication issues

### 3.3: Create DBA User Accounts

**Create local accounts in new tenant:**

```powershell
# Switch to new tenant
az login --tenant <new-tenant-id>
az account set --subscription "subs-rhcdbase"

# Create Mike McGuirk
az ad user create --display-name "Mike McGuirk" --user-principal-name "mmcguirk@rhcdbase.onmicrosoft.com" --password "TempPass123!Rhc" --force-change-password-next-sign-in true

# Create David Tuck  
az ad user create --display-name "David Tuck" --user-principal-name "dtuck@rhcdbase.onmicrosoft.com" --password "TempPass123!Rhc" --force-change-password-next-sign-in true

# Add to admin groups (get IDs first)
$mikeId = (az ad user show --id "mmcguirk@rhcdbase.onmicrosoft.com" --query id -o tsv)
$daveId = (az ad user show --id "dtuck@rhcdbase.onmicrosoft.com" --query id -o tsv)

# Add to all three SQL server admin groups
az ad group member add --group "db-lam-sqlsvr-admin" --member-id $mikeId
az ad group member add --group "db-qa-sqlsvr-admin" --member-id $mikeId
az ad group member add --group "db-prod-sqlsvr-admin" --member-id $mikeId

az ad group member add --group "db-lam-sqlsvr-admin" --member-id $daveId
az ad group member add --group "db-qa-sqlsvr-admin" --member-id $daveId
az ad group member add --group "db-prod-sqlsvr-admin" --member-id $daveId
```

### 3.4: Test SSMS Authentication

**Mike and Dave should test:**

1. **Server:** `rhcdb-qa-sqlsvr.database.windows.net`
2. **Authentication:** `Azure Active Directory - Universal with MFA`
3. **Login:** `mmcguirk@rhcdbase.onmicrosoft.com`
4. **Password:** (set during first login)

**This should work perfectly with no authentication errors!**

---

## 🔒 Phase 4: Configure MFA (Optional)

### 4.1: Enable Security Defaults (Quick Option)

```powershell
# Enable security defaults (includes MFA)
az rest --method PATCH --uri "https://graph.microsoft.com/v1.0/policies/identitySecurityDefaultsEnforcementPolicy" --headers "Content-Type=application/json" --body '{\"isEnabled\": true}'
```

This automatically enforces MFA for all users.

### 4.2: Conditional Access Policy (Advanced Option)

If you need more control, create a Conditional Access policy:

1. Go to **Microsoft Entra ID** → **Security** → **Conditional Access**
2. Create new policy:
   - **Name:** `Require MFA for Database Admin`
   - **Users:** Include db-*-admin groups
   - **Cloud apps:** All cloud apps
   - **Grant:** Require MFA
   - **Enable policy:** On

---

## ✅ Phase 5: Verification

### 5.1: Run Verification Script

Update `databaseVerification.ps1` with new tenant context:

```powershell
# Update subscription name if changed
az account set --subscription "subs-rhcdbase"

# Run verification
.\databaseVerification.ps1
```

### 5.2: Verify Tenant Type

```powershell
az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" --headers "Content-Type=application/json" | ConvertFrom-Json | Select-Object -ExpandProperty value | Select-Object displayName, tenantType
```

**Should show:**
- `displayName: RHC Database Administration`
- `tenantType: AAD` ✅ (NOT CIAM)

### 5.3: Test All Admin Accounts

Have each DBA test SSMS connection:
- [ ] Ron can connect
- [ ] Mike can connect
- [ ] Dave can connect

All should work seamlessly with no authentication errors.

---

## 📝 Phase 6: Update Documentation

### 6.1: Update Phase 3 Documentation

Update `docs/03-database-tenant-setup.md` with new tenant information:

```markdown
**Tenant Information:**
- Tenant Name: RHC Database Administration
- Domain: rhcdbase.onmicrosoft.com
- Tenant ID: [new-tenant-id]
- Tenant Type: AAD (Workforce) ✅
- Subscription: subs-rhcdbase
- Subscription ID: [new-subscription-id]
```

### 6.2: Update deployment-log.md

Record the rebuild:

```markdown
## 2025-11-05: Database Tenant Rebuild

**Issue:** Original tenant was CIAM type, incompatible with SQL Server workforce authentication

**Actions:**
- Deleted all resources from CIAM tenant (rhcdb.onmicrosoft.com)
- Created new workforce tenant (rhcdbase.onmicrosoft.com)
- Rebuilt all infrastructure in new tenant
- Re-executed Phase 3 from scratch

**Result:** All authentication working correctly, no AADSTS500208 errors
```

---

## 🎓 Lessons Learned

### What Went Wrong

1. **Selected wrong tenant type during creation**
   - CIAM = External ID for customers (B2C scenarios)
   - Workforce = Internal users and enterprise apps

2. **CIAM limitations not obvious at creation time**
   - Azure Portal doesn't clearly explain the restrictions
   - Works fine for subscriptions and resources
   - Only fails when trying to authenticate users to SQL Server

3. **No conversion path between tenant types**
   - Once created, tenant type is permanent
   - Only solution is to rebuild

### How to Avoid This in Future

1. **Always choose "Workforce" for internal admin tenants**
2. **Use "External ID/CIAM" only for customer-facing apps**
3. **Test authentication early** - don't wait until full deployment
4. **Verify tenant type immediately after creation:**
   ```powershell
   az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" --query "value[0].tenantType"
   ```

### Documentation Updates Needed

- [ ] Add tenant type verification to Phase 2 (Database Tenant Creation)
- [ ] Add warning about CIAM vs Workforce in tenant creation step
- [ ] Add early authentication test in Phase 3 before creating all resources

---

## 🚨 Troubleshooting

### Issue: Can't Delete Subscription

**Error:** Subscription has active resources

**Solution:**
```powershell
# List all resources
az resource list --subscription "subs-rhcdb" -o table

# Force delete any remaining
az resource delete --ids [resource-id] --no-wait
```

### Issue: Can't Delete Tenant

**Error:** Directory has active subscriptions

**Solution:**
- Wait 24 hours after subscription cancellation
- Or just abandon the tenant (no cost)

### Issue: Tenant Deletion Blocked

**Causes:**
- App registrations exist
- Users exist
- Enterprise apps exist

**Solution:**
Go through tenant deletion checklist in portal and remove all blockers.

---

## ⏱️ Time Estimates

| Phase | Time | Notes |
|-------|------|-------|
| Delete Infrastructure | 15 min | Plus 10 min wait time |
| Delete Subscription | 5 min | Plus 24 hour wait for full removal |
| Create New Tenant | 5 min | Instant |
| Create Subscription | 10 min | Depends on billing setup |
| Rebuild Phase 3 | 60 min | Following original docs |
| Create DBA Accounts | 10 min | |
| Testing & Verification | 15 min | |
| **Total** | **2 hours** | Excluding subscription wait time |

---

## 📞 Support

If you encounter issues:

1. **Check tenant type first:**
   ```powershell
   az rest --method GET --uri "https://graph.microsoft.com/v1.0/organization" --query "value[0].tenantType"
   ```

2. **Verify you're in correct tenant:**
   ```powershell
   az account show
   ```

3. **Check Azure service health:**
   https://status.azure.com

---

## ✅ Completion Checklist

- [ ] Phase 1: Old infrastructure deleted
- [ ] Phase 1: Old subscription deleted/cancelled
- [ ] Phase 1: Old tenant abandoned or scheduled for deletion
- [ ] Phase 2: New workforce tenant created (tenantType = AAD)
- [ ] Phase 2: New subscription created in new tenant
- [ ] Phase 3: All SQL Servers recreated
- [ ] Phase 3: All databases recreated
- [ ] Phase 3: Security groups and app registrations created
- [ ] Phase 3: Audit logging and Defender enabled
- [ ] Phase 4: DBA accounts created (Mike, Dave, Ron)
- [ ] Phase 4: MFA configured
- [ ] Phase 5: Verification script passes
- [ ] Phase 5: All DBAs can connect via SSMS
- [ ] Phase 6: Documentation updated with new tenant info
- [ ] Phase 6: deployment-log.md updated

---

**Ready to proceed? Start with Phase 1.1 and work through systematically.**

**DO NOT SKIP THE TENANT TYPE VERIFICATION in Phase 2.1!**
