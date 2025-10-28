# 💳 Phase 2: Subscription Setup

**Status:** ⏳ Waiting for Phase 1  
**Prerequisites:** All three tenants created from Phase 1  
**Estimated Time:** 30-45 minutes

---

## 📋 Overview

This phase creates new Azure subscriptions for each tenant and links them to the central billing account under `recalibratehealthcare.com`.

**Subscriptions to Create:**
1. **QA Subscription** → `rhc-b2c-qa-sub` (for `rhc-b2c-qa.onmicrosoft.com`)
2. **Production Subscription** → `rhc-b2c-prod-sub` (for `rhc-b2c-prod.onmicrosoft.com`)
3. **Database Subscription** → `rhc-db-core-sub` (for `rhc-db-core.onmicrosoft.com`)

**Benefits:**
- Cost isolation and tracking per environment
- Security isolation between environments
- Separate resource limits and quotas
- Clear billing per tenant

---

## 🎯 Checklist

### Pre-Creation Tasks
- [ ] Verify all three tenants created (Phase 1 complete)
- [ ] Verify billing account access
- [ ] Decide on subscription offer type

### Subscription Creation
- [ ] Create QA Subscription (`rhc-b2c-qa-sub`)
- [ ] Create Production Subscription (`rhc-b2c-prod-sub`)
- [ ] Create Database Subscription (`rhc-db-core-sub`)

### Post-Creation Configuration
- [ ] Assign Ron as Owner on all subscriptions
- [ ] Configure cost management alerts
- [ ] Set spending limits (if applicable)
- [ ] Document subscription IDs

### Verification
- [ ] Test resource creation in each subscription
- [ ] Verify billing is linked correctly
- [ ] Update deployment-log.md

---

## 📝 Subscription Information (Fill in after creation)

| Subscription Name | Tenant | Subscription ID | Creation Date | Status |
|-------------------|--------|-----------------|---------------|--------|
| `rhc-b2c-qa-sub` | `rhc-b2c-qa.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| `rhc-b2c-prod-sub` | `rhc-b2c-prod.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |
| `rhc-db-core-sub` | `rhc-db-core.onmicrosoft.com` | `___________________` | `____/____/____` | ⬜ |

---

## 💡 Subscription Creation Options

### Option A: Azure Portal (Easiest)

This is the most straightforward method for creating subscriptions.

### Option B: Azure CLI

Requires Azure CLI and appropriate permissions.

### Option C: Microsoft Graph API

Most complex, but fully automated.

**Recommendation:** Start with Azure Portal for reliability, can automate later.

---

## 🔧 Method 1: Azure Portal (Recommended)

### 1. Create QA Subscription

#### Step 1: Navigate to Subscriptions

1. Log in to Azure Portal: https://portal.azure.com
2. Switch to the **B2C QA tenant** (`rhc-b2c-qa.onmicrosoft.com`)
   - Click profile icon → Switch directory
   - Select `rhc-b2c-qa.onmicrosoft.com`

3. Search for **"Subscriptions"** in the top search bar
4. Click **"+ Add"** or **"Create subscription"**

#### Step 2: Choose Offer Type

You'll see several options:

**For B2C Tenants (QA and Prod):**
- **Pay-As-You-Go** (Most common for production workloads)
- **Enterprise Agreement** (If you have EA with Microsoft)
- **Microsoft Customer Agreement** (Modern billing)

**Recommendation:** Use **Pay-As-You-Go** or **Microsoft Customer Agreement**

#### Step 3: Fill in Details

- **Subscription name:** `rhc-b2c-qa-sub`
- **Billing account:** Link to `recalibratehealthcare.com` billing
- **Resource group:** (Will create later)

#### Step 4: Complete Creation

- Review and click **"Create"**
- Wait for subscription to be provisioned (1-5 minutes)
- Copy the **Subscription ID** to the table above

---

### 2. Create Production Subscription

Repeat the same process:

1. Switch to **B2C Production tenant** (`rhc-b2c-prod.onmicrosoft.com`)
2. Navigate to **Subscriptions** → **Add**
3. Choose offer type (same as QA)
4. **Subscription name:** `rhc-b2c-prod-sub`
5. Link to `recalibratehealthcare.com` billing
6. Create and document Subscription ID

---

### 3. Create Database Subscription

Repeat for Database tenant:

1. Switch to **Database tenant** (`rhc-db-core.onmicrosoft.com`)
2. Navigate to **Subscriptions** → **Add**
3. Choose offer type (same as above)
4. **Subscription name:** `rhc-db-core-sub`
5. Link to `recalibratehealthcare.com` billing
6. Create and document Subscription ID

---

## 🔧 Method 2: Azure CLI

If you prefer automation, use Azure CLI:

### Prerequisites

```powershell
# Check if Azure CLI is installed
az --version

# If not installed, download from: https://aka.ms/installazurecliwindows
# Then restart PowerShell
```

### Create QA Subscription

```bash
# Login and set context to QA tenant
az login --tenant rhc-b2c-qa.onmicrosoft.com

# Create subscription (requires billing account ID)
az account create \
  --offer-type "MS-AZR-0003P" \
  --display-name "rhc-b2c-qa-sub" \
  --billing-account-name "<your-billing-account-id>" \
  --enrollment-account-name "<your-enrollment-account-id>"

# List subscriptions to verify
az account list --output table
```

### Create Production Subscription

```bash
# Switch to Production tenant
az login --tenant rhc-b2c-prod.onmicrosoft.com

# Create subscription
az account create \
  --offer-type "MS-AZR-0003P" \
  --display-name "rhc-b2c-prod-sub" \
  --billing-account-name "<your-billing-account-id>" \
  --enrollment-account-name "<your-enrollment-account-id>"
```

### Create Database Subscription

```bash
# Switch to Database tenant
az login --tenant rhc-db-core.onmicrosoft.com

# Create subscription
az account create \
  --offer-type "MS-AZR-0003P" \
  --display-name "rhc-db-core-sub" \
  --billing-account-name "<your-billing-account-id>" \
  --enrollment-account-name "<your-enrollment-account-id>"
```

**Note:** You'll need to get your billing account ID from the Azure Portal first.

---

## 🔧 Method 3: Microsoft Graph API

### Prerequisites

```powershell
# Install Microsoft Graph PowerShell
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Graph
Connect-MgGraph -Scopes "Subscription.ReadWrite.All"
```

### Create Subscription via Graph

```powershell
# Note: Subscription creation via Graph requires specific billing setup
# This is more complex and may not work for all account types

# Get billing account
$billingAccounts = Invoke-MgGraphRequest -Method GET -Uri "https://management.azure.com/providers/Microsoft.Billing/billingAccounts?api-version=2020-05-01"

# Create subscription (requires enrollment account)
$body = @{
    displayName = "rhc-b2c-qa-sub"
    billingProfileId = "<billing-profile-id>"
    skuId = "<sku-id>"
    costCenter = "RHC-QA"
} | ConvertTo-Json

Invoke-MgGraphRequest -Method POST `
  -Uri "https://management.azure.com/providers/Microsoft.Billing/billingAccounts/<billing-account>/createSubscription?api-version=2020-05-01" `
  -Body $body
```

**Note:** Graph API method is complex and may require Enterprise Agreement or Microsoft Customer Agreement. Use Portal method if this doesn't work.

---

## 🔐 Configure Subscription Access

After creating subscriptions, assign yourself as Owner:

### Via Azure Portal

For each subscription:

1. Navigate to the subscription in Azure Portal
2. Click **"Access control (IAM)"** in the left menu
3. Click **"+ Add"** → **"Add role assignment"**
4. **Role:** Select **"Owner"**
5. **Assign access to:** User, group, or service principal
6. **Select:** Search for your account (Ron)
7. Click **"Save"**

### Via Azure CLI

```bash
# Get your user object ID
az ad signed-in-user show --query id -o tsv

# Assign Owner role to QA subscription
az role assignment create \
  --role "Owner" \
  --assignee "<your-user-object-id>" \
  --scope "/subscriptions/<qa-subscription-id>"

# Repeat for Production subscription
az role assignment create \
  --role "Owner" \
  --assignee "<your-user-object-id>" \
  --scope "/subscriptions/<prod-subscription-id>"

# Repeat for Database subscription
az role assignment create \
  --role "Owner" \
  --assignee "<your-user-object-id>" \
  --scope "/subscriptions/<db-subscription-id>"
```

---

## 💰 Configure Cost Management

Set up cost alerts to monitor spending:

### 1. Budget Alerts (Via Portal)

For each subscription:

1. Navigate to subscription in Azure Portal
2. Click **"Cost Management"** → **"Budgets"**
3. Click **"+ Add"**
4. **Budget details:**
   - Name: `monthly-budget-qa` (or prod/db)
   - Reset period: Monthly
   - Creation date: Today
   - Expiration date: 1 year from now
5. **Budget amount:**
   - QA: $500/month (adjust as needed)
   - Production: $1000/month (adjust as needed)
   - Database: $200/month (adjust as needed)
6. **Alert conditions:**
   - Alert at 50%, 75%, 90%, 100% of budget
   - Email: your email address
7. Click **"Create"**

### 2. Cost Alerts via Azure CLI

```bash
# Create budget for QA subscription
az consumption budget create \
  --budget-name "monthly-budget-qa" \
  --category cost \
  --amount 500 \
  --time-grain monthly \
  --time-period start-date=2025-10-01 end-date=2026-10-01 \
  --resource-group-filter [] \
  --subscription "<qa-subscription-id>"
```

---

## 🔍 Verification Steps

### 1. List All Subscriptions

#### Via Portal
1. Go to **"Subscriptions"** in Azure Portal
2. Verify you see all new subscriptions
3. Check each one shows correct tenant

#### Via Azure CLI

```bash
# Login and list all subscriptions across all tenants
az login
az account list --all --output table

# Should show:
# - rhc-b2c-qa-sub (in rhc-b2c-qa tenant)
# - rhc-b2c-prod-sub (in rhc-b2c-prod tenant)
# - rhc-db-core-sub (in rhc-db-core tenant)
```

### 2. Test Resource Creation

Try creating a resource group in each subscription:

```bash
# Test QA subscription
az login --tenant rhc-b2c-qa.onmicrosoft.com
az account set --subscription "rhc-b2c-qa-sub"
az group create --name "test-rg" --location "eastus2"
az group delete --name "test-rg" --yes --no-wait

# Repeat for Production
az login --tenant rhc-b2c-prod.onmicrosoft.com
az account set --subscription "rhc-b2c-prod-sub"
az group create --name "test-rg" --location "eastus2"
az group delete --name "test-rg" --yes --no-wait

# Repeat for Database
az login --tenant rhc-db-core.onmicrosoft.com
az account set --subscription "rhc-db-core-sub"
az group create --name "test-rg" --location "eastus2"
az group delete --name "test-rg" --yes --no-wait
```

### 3. Verify Billing Linkage

1. Go to **"Cost Management + Billing"** in Azure Portal
2. Click **"Billing scopes"**
3. Verify all three new subscriptions are listed
4. Check they're linked to your billing account

---

## ⚠️ Common Issues & Troubleshooting

### Issue: "You don't have permission to create subscriptions"

**Cause:** Not all Azure accounts can create subscriptions programmatically

**Solutions:**
1. Use Azure Portal (usually works even when API doesn't)
2. Contact your account manager if you have Enterprise Agreement
3. May need to be added as billing administrator
4. For new organizations, may need to contact Microsoft support

### Issue: "Billing account not found"

**Solution:**
1. Go to **"Cost Management + Billing"** in Azure Portal
2. Note your billing account ID
3. Ensure you're using the correct billing account in scripts

### Issue: "Subscription creation pending"

**Solution:**
- Wait 5-10 minutes for provisioning
- Check email for verification requirements
- May need to verify payment method

### Issue: "Can't see subscription in tenant"

**Solution:**
1. Log out and log back in
2. Refresh the portal
3. Switch to the correct directory
4. Wait a few minutes for replication

---

## 📊 What We've Accomplished

After completing this phase:

✅ **3 New Subscriptions Created:**
- QA subscription for QA environment resources
- Production subscription for production resources
- Database subscription for SQL resources

✅ **Cost Management Configured:**
- Budgets and alerts set up
- Spending monitored per environment

✅ **Access Configured:**
- You have Owner access to all subscriptions
- Can create and manage resources

✅ **Ready for Resource Deployment:**
- Can now create resource groups
- Can deploy databases, apps, and services

---

## 📝 Update Deployment Log

After completing subscription setup:

```markdown
## 2025-10-XX - Phase 2: Subscription Setup

**Completed by:** Ron

### Subscriptions Created
- [x] QA Subscription: rhc-b2c-qa-sub (ID: xxxxx)
- [x] Production Subscription: rhc-b2c-prod-sub (ID: xxxxx)
- [x] Database Subscription: rhc-db-core-sub (ID: xxxxx)

### Configuration
- [x] Cost management and budgets configured
- [x] Owner role assigned to Ron
- [x] Billing linked to recalibratehealthcare.com

**Status:** ✅ Complete
**Issues:** None
**Notes:** All subscriptions created and tested
```

---

## ➡️ Next Steps

Once all subscriptions are created and verified:

**👉 Proceed to:** `03-database-tenant-setup.md`

This will set up the database tenant with SQL servers and databases for QA.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** ⏳ Waiting for Phase 1
