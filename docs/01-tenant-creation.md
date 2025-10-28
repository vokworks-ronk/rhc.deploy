# 🏢 Phase 1: Tenant Creation

**Status:** 🚀 Ready to Execute  
**Prerequisites:** Global Administrator access to `recalibratehealthcare.com` tenant  
**Estimated Time:** 45-60 minutes (manual process)

---

## 📋 Overview

This phase creates the three new Microsoft Entra tenants required for the multi-tenant architecture:

1. **B2C QA Tenant** - `rhc-b2c-qa.onmicrosoft.com`
2. **B2C Production Tenant** - `rhc-b2c-prod.onmicrosoft.com`
3. **Database Tenant** - `rhc-db-core.onmicrosoft.com`

⚠️ **IMPORTANT:** Tenant creation **MUST** be done manually via Azure Portal. There is no supported API, CLI, or PowerShell method to create new Entra tenants. Post-creation configuration can be automated.

---

## 🎯 Checklist

### Pre-Creation Tasks
- [ ] Verify you're logged into Azure Portal as Global Admin
- [ ] Confirm tenant names are available (not taken by others)
- [ ] Have this checklist ready to fill in Tenant IDs after creation

### Tenant Creation
- [ ] Create B2C QA Tenant (`rhc-b2c-qa.onmicrosoft.com`)
- [ ] Create B2C Production Tenant (`rhc-b2c-prod.onmicrosoft.com`)
- [ ] Create Database Tenant (`rhc-db-core.onmicrosoft.com`)

### Post-Creation Verification
- [ ] Document all Tenant IDs (fill in table below)
- [ ] Verify you have Global Admin access to all new tenants
- [ ] Test switching between tenants in Azure Portal
- [ ] Update deployment-log.md with completion

---

## 📝 Tenant Information (Fill in after creation)

| Tenant Purpose | Domain Name | Tenant ID | Creation Date | Status |
|----------------|-------------|-----------|---------------|--------|
| B2C QA | `rhc-b2c-qa.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| B2C Production | `rhc-b2c-prod.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| Database Core | `rhc-db-core.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |

---

## 🔧 Step-by-Step Instructions

### 1. Create B2C QA Tenant

#### Via Azure Portal

1. **Navigate to Azure Portal**
   - Go to: https://portal.azure.com
   - Ensure you're in your main tenant (`recalibratehealthcare.com`)

2. **Start Tenant Creation**
   - Click **"Create a resource"**
   - Search for: **"Azure Active Directory B2C"** or **"Entra ID B2C"**
   - Click **"Create"**

3. **Choose Creation Type**
   - Select: **"Create a new Azure AD B2C Tenant"**
   - Click **"Create"**

4. **Fill in Tenant Details**
   - **Organization name:** `RHC B2C QA`
   - **Initial domain name:** `rhc-b2c-qa`
   - **Country/Region:** `United States` (or your preferred region)
   - **Note:** The domain will become `rhc-b2c-qa.onmicrosoft.com`

5. **Review + Create**
   - Review all details
   - Click **"Create"**
   - ⏳ Wait 2-5 minutes for tenant creation

6. **Verify Creation**
   - You'll see a notification: "Your new tenant is ready"
   - Click **"Go to tenant"** or switch directories manually

7. **Record Tenant ID**
   - In the new tenant, go to **Microsoft Entra ID** → **Overview**
   - Copy the **Tenant ID** (GUID)
   - Fill it into the table above

8. **Verify Global Admin Access**
   - Check that you (Ron) are listed as Global Administrator
   - Go to **Microsoft Entra ID** → **Roles and administrators** → **Global Administrator**

---

### 2. Create B2C Production Tenant

#### Via Azure Portal

1. **Switch Back to Main Tenant**
   - Click your profile icon → **Switch directory**
   - Select `recalibratehealthcare.com`

2. **Start Tenant Creation**
   - Click **"Create a resource"**
   - Search for: **"Azure Active Directory B2C"**
   - Click **"Create"**

3. **Choose Creation Type**
   - Select: **"Create a new Azure AD B2C Tenant"**
   - Click **"Create"**

4. **Fill in Tenant Details**
   - **Organization name:** `RHC B2C Production`
   - **Initial domain name:** `rhc-b2c-prod`
   - **Country/Region:** `United States`
   - **Note:** The domain will become `rhc-b2c-prod.onmicrosoft.com`

5. **Review + Create**
   - Review all details
   - Click **"Create"**
   - ⏳ Wait 2-5 minutes

6. **Verify Creation**
   - Click **"Go to tenant"** when ready
   - Navigate to **Microsoft Entra ID** → **Overview**
   - Copy the **Tenant ID**
   - Fill it into the table above

---

### 3. Create Database Tenant (Workforce Tenant)

#### Via Azure Portal

⚠️ **IMPORTANT:** This is a **Workforce tenant**, NOT a B2C tenant. Different creation process.

1. **Switch Back to Main Tenant**
   - Click your profile icon → **Switch directory**
   - Select `recalibratehealthcare.com`

2. **Start Tenant Creation**
   - Click **"Create a resource"**
   - Search for: **"Microsoft Entra ID"** or **"Azure Active Directory"**
   - Click **"Create"** (NOT "Create a B2C tenant")

3. **Choose Tenant Type**
   - Select: **"Azure Active Directory"** (Workforce tenant)
   - **Do NOT select B2C**

4. **Fill in Tenant Details**
   - **Organization name:** `RHC Database Core`
   - **Initial domain name:** `rhc-db-core`
   - **Country/Region:** `United States`
   - **Note:** The domain will become `rhc-db-core.onmicrosoft.com`

5. **Review + Create**
   - Review all details
   - Click **"Create"**
   - ⏳ Wait 2-5 minutes

6. **Verify Creation**
   - Click **"Go to tenant"** when ready
   - Navigate to **Microsoft Entra ID** → **Overview**
   - Copy the **Tenant ID**
   - Fill it into the table above

7. **Verify Tenant Type**
   - Confirm this is a **Workforce tenant** (not B2C)
   - You should NOT see B2C-specific features

---

## ⚠️ Common Issues & Troubleshooting

### Issue: "Domain name is already taken"

**Solution:**
- Try a different domain name
- Add numbers or unique identifier: `rhc-b2c-qa-2025`
- Document the actual name used

### Issue: "You don't have permission to create a tenant"

**Solution:**
- Verify you're a Global Administrator in the parent tenant
- Some organizations restrict tenant creation
- May need to contact Microsoft support or use different account

### Issue: "Tenant creation failed"

**Solution:**
- Wait a few minutes and try again
- Clear browser cache
- Try in private/incognito browser window
- Try different browser

### Issue: "Can't switch to new tenant"

**Solution:**
- Log out and log back in
- It can take 5-10 minutes for tenant to be fully provisioned
- Check: Settings → Directories + subscriptions → Refresh

---

## 🔍 Verification Steps

After creating all three tenants, verify:

### 1. All Tenants Visible

1. Go to Azure Portal
2. Click profile icon → **Switch directory**
3. Confirm you see all tenants:
   - `recalibratehealthcare.com` ✅
   - `rhc-b2c-qa.onmicrosoft.com` ✅
   - `rhc-b2c-prod.onmicrosoft.com` ✅
   - `rhc-db-core.onmicrosoft.com` ✅
   - (Plus your dev tenants)

### 2. Tenant IDs Recorded

- [ ] B2C QA Tenant ID documented
- [ ] B2C Prod Tenant ID documented
- [ ] Database Tenant ID documented

### 3. Global Admin Access

For each new tenant:
1. Switch to the tenant
2. Go to **Microsoft Entra ID** → **Roles and administrators**
3. Click **Global Administrator**
4. Verify you (Ron) are listed

### 4. Tenant Types Correct

- [ ] B2C QA = Azure AD B2C tenant
- [ ] B2C Prod = Azure AD B2C tenant
- [ ] Database Core = Azure AD (Workforce) tenant

---

## 📜 Post-Creation PowerShell Verification

Once tenants are created, you can verify them programmatically:

### Using Microsoft Graph PowerShell

```powershell
# Install Microsoft Graph PowerShell if not already installed
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Directory.Read.All"

# List all tenants you have access to
Get-MgOrganization | Select-Object DisplayName, Id, VerifiedDomains

# Disconnect
Disconnect-MgGraph
```

### Using Azure CLI

```bash
# Login to Azure
az login

# List all tenants
az account tenant list --output table

# Show specific tenant details (replace with your tenant ID)
az rest --method get --url "https://graph.microsoft.com/v1.0/organization"
```

---

## 📊 What We've Accomplished

After completing this phase:

✅ **3 New Tenants Created:**
- B2C QA Tenant for QA environment
- B2C Production Tenant for production environment
- Database Tenant for isolated SQL resources

✅ **Admin Access Configured:**
- You have Global Administrator access to all tenants

✅ **Foundation Ready:**
- Ready to create subscriptions in Phase 2
- Ready to configure B2C features in Phase 4
- Ready to deploy databases in Phase 3

---

## 📝 Update Deployment Log

After completing tenant creation, update `deployment-log.md`:

```markdown
## 2025-10-27 - Phase 1: Tenant Creation

**Completed by:** Ron

### Tenants Created
- [x] B2C QA Tenant: rhc-b2c-qa.onmicrosoft.com (Tenant ID: xxxxx)
- [x] B2C Production Tenant: rhc-b2c-prod.onmicrosoft.com (Tenant ID: xxxxx)
- [x] Database Tenant: rhc-db-core.onmicrosoft.com (Tenant ID: xxxxx)

**Status:** ✅ Complete
**Issues:** None
**Notes:** All tenants created successfully, Global Admin access verified
```

---

## ➡️ Next Steps

Once all tenants are created and verified:

**👉 Proceed to:** `02-subscription-setup.md`

This will create subscriptions and link them to each tenant for resource billing.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** 🚀 Ready to Execute
