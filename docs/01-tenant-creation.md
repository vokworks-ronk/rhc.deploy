# 🏢 Phase 1: Tenant Creation

**Status:** 🚀 Ready to Execute  
**Prerequisites:** Global Administrator access to `recalibratehealthcare.com` tenant  
**Estimated Time:** 45-60 minutes (manual process)

---

## 📋 Overview

This phase creates the three new Microsoft Entra tenants required for the multi-tenant architecture:

1. **QA Tenant (External ID)** - `rhcqa.onmicrosoft.com`
2. **Production Tenant (External ID)** - `rhcprod.onmicrosoft.com`
3. **Database Tenant (Workforce)** - `rhcdbcore.onmicrosoft.com`

> **Important Update:** As of May 1, 2025, Azure AD B2C is no longer available for new customers. We're using **Microsoft Entra External ID** instead, which is the modern replacement with the same core functionality plus enhanced features.

⚠️ **IMPORTANT:** Tenant creation **MUST** be done manually via Azure Portal. There is no supported API, CLI, or PowerShell method to create new Entra tenants. Post-creation configuration can be automated.

---

## 🎯 Checklist

### Pre-Creation Tasks
- [ ] Verify you're logged into Azure Portal as Global Admin
- [ ] Confirm tenant names are available (not taken by others)
- [ ] Have this checklist ready to fill in Tenant IDs after creation

### Tenant Creation
- [ ] Create QA Tenant (`rhcqa.onmicrosoft.com`) - Entra External ID
- [ ] Create Production Tenant (`rhcprod.onmicrosoft.com`) - Entra External ID
- [ ] Create Database Tenant (`rhcdbcore.onmicrosoft.com`) - Workforce

### Post-Creation Verification
- [ ] Document all Tenant IDs (fill in table below)
- [ ] Verify you have Global Admin access to all new tenants
- [ ] Test switching between tenants in Azure Portal
- [ ] Update deployment-log.md with completion

---

## 📝 Tenant Information (Fill in after creation)

| Tenant Purpose | Domain Name | Tenant ID | Creation Date | Status |
|----------------|-------------|-----------|---------------|--------|
| QA (External ID) | `rhcqa.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| Production (External ID) | `rhcprod.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| Database (Workforce) | `rhcdbcore.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |

---

## 🔧 Step-by-Step Instructions

### 1. Create QA Tenant (External ID)

#### Via Azure Portal

1. **Navigate to Azure Portal**
   - Go to: https://portal.azure.com
   - Ensure you're in your main tenant (`recalibratehealthcare.com`)

2. **Navigate to Microsoft Entra ID**
   - In the search bar at top, search for: **"Microsoft Entra ID"** or **"Entra"**
   - Click on **"Microsoft Entra ID"**

3. **Start Tenant Creation**
   - Look for **"Manage tenants"** button at the top of the page
   - OR click the **"+ Create"** button
   - OR in the Overview page, look for options to manage or create tenants

4. **Choose Tenant Type**
   You should see options like:
   - **Microsoft Entra ID** (Workforce)
   - **Microsoft Entra External ID** (for customers/external users) ← **SELECT THIS**
   
   **Select:** "Microsoft Entra External ID" (if available)
   
   > **Note:** If you don't see "External ID" as an option, select "Microsoft Entra ID" (Workforce) and we'll enable External ID features after creation.

5. **Fill in Tenant Details**
   - **Organization name:** `RHC QA` or `RHC External ID QA`
   - **Initial domain name:** `rhcqa` ⚠️ **Must be alphanumeric only (no hyphens)**
   - **Country/Region:** `United States` (or your preferred region)
   - **Subscription:** Select your existing subscription (this is just for a small link resource)
   - **Resource group:** Create new or select existing (not critical - just for the link)
   - **Note:** The domain will become `rhcqa.onmicrosoft.com`

6. **Review + Create**
   - Review all details
   - Click **"Create"**
   - ⏳ Wait 2-5 minutes for tenant creation

7. **Verify Creation**
   - You'll see a notification: "Your new tenant is ready"
   - Click **"Go to tenant"** or switch directories manually

8. **Record Tenant ID**
   - In the new tenant, go to **Microsoft Entra ID** → **Overview**
   - Copy the **Tenant ID** (GUID)
   - Fill it into the table above

9. **Verify Tenant Type**
   - Check if External ID features are available
   - Look for "External Identities" or similar in the left menu
   - If not available, we'll enable it in Phase 4

10. **Verify Global Admin Access**
    - Check that you (Ron) are listed as Global Administrator
    - Go to **Roles and administrators** → **Global Administrator**

11. **Switch Back to Main Tenant**
    - Click your profile icon → **Switch directory**
    - Select `recalibratehealthcare.com`

---

### 2. Create Production Tenant (External ID)

#### Via Azure Portal

1. **Switch Back to Main Tenant**
   - Click your profile icon → **Switch directory**
   - Select `recalibratehealthcare.com`

2. **Repeat the Process**
   - Navigate to **Microsoft Entra ID**
   - Click **"Manage tenants"** → **"+ Create"**
   - Select **"Microsoft Entra External ID"** (or Workforce if External ID not available)

3. **Fill in Tenant Details**
   - **Organization name:** `RHC Production` or `RHC External ID Production`
   - **Initial domain name:** `rhcprod` ⚠️ **Must be alphanumeric only (no hyphens)**
   - **Country/Region:** `United States`
   - **Subscription:** Select existing
   - **Note:** The domain will become `rhcprod.onmicrosoft.com`

4. **Review + Create**
   - Review all details
   - Click **"Create"**
   - ⏳ Wait 2-5 minutes

5. **Verify Creation**
   - Click **"Go to tenant"** when ready
   - Navigate to **Microsoft Entra ID** → **Overview**
   - Copy the **Tenant ID**
   - Fill it into the table above

6. **Switch Back to Main Tenant**

---

### 3. Create Database Tenant (Workforce Tenant)

#### Via Azure Portal

⚠️ **IMPORTANT:** This is a **Workforce tenant**, NOT an External ID tenant. Different creation process.

1. **Switch Back to Main Tenant**
   - Click your profile icon → **Switch directory**
   - Select `recalibratehealthcare.com`

2. **Start Tenant Creation**
   - Navigate to **Microsoft Entra ID**
   - Click **"Manage tenants"** → **"+ Create"**

3. **Choose Tenant Type**
   - Select: **"Microsoft Entra ID"** (Workforce tenant)
   - **Do NOT select External ID for this one**

4. **Fill in Tenant Details**
   - **Organization name:** `RHC Database Core`
   - **Initial domain name:** `rhcdbcore` ⚠️ **Must be alphanumeric only (no hyphens)**
   - **Country/Region:** `United States`
   - **Note:** The domain will become `rhcdbcore.onmicrosoft.com`

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
   - Confirm this is a **Workforce tenant** (not External ID)
   - Should NOT have External ID or B2C-specific features

8. **Switch Back to Main Tenant**

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
   - `rhcqa.onmicrosoft.com` ✅
   - `rhcprod.onmicrosoft.com` ✅
   - `rhcdbcore.onmicrosoft.com` ✅
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

- [ ] QA = Microsoft Entra External ID (or Workforce with External ID features)
- [ ] Production = Microsoft Entra External ID (or Workforce with External ID features)
- [ ] Database Core = Microsoft Entra ID (Workforce) tenant

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
- QA Tenant (External ID) for QA environment
- Production Tenant (External ID) for production environment  
- Database Tenant (Workforce) for isolated SQL resources

✅ **Admin Access Configured:**
- You have Global Administrator access to all tenants

✅ **Foundation Ready:**
- Ready to create subscriptions in Phase 2
- Ready to configure External ID features in Phase 4
- Ready to deploy databases in Phase 3

---

## 📝 Update Deployment Log

After completing tenant creation, update `deployment-log.md`:

```markdown
## 2025-10-28 - Phase 1: Tenant Creation

**Completed by:** Ron

### Tenants Created
- [x] QA Tenant: rhcqa.onmicrosoft.com (Tenant ID: xxxxx)
- [x] Production Tenant: rhcprod.onmicrosoft.com (Tenant ID: xxxxx)
- [x] Database Tenant: rhcdbcore.onmicrosoft.com (Tenant ID: xxxxx)

**Tenant Type:** Microsoft Entra External ID (for QA/Prod) and Workforce (for Database)
**Status:** ✅ Complete
**Issues:** None
**Notes:** Migrated from Azure AD B2C to Microsoft Entra External ID per Microsoft's direction
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
