# Phase 6 Progress - GitHub Actions CI/CD

**Date:** November 13, 2025  
**Status:** Step 1-4 Complete, Ready for GitHub Configuration

---

## ✅ Completed Steps

### Step 1: Service Principal Created

**Service Principal:** `github-actions-qa-deployer`
- Client ID: `f2f4c74d-6739-408f-b941-76f658712b16`
- Object ID: `bf68f5da-62dd-49f3-b84f-8b2f9f4091f5`
- Tenant: `rhcqa.onmicrosoft.com` (2604fd9a-93a6-448e-bdc9-25e3c2d671a2)
- Subscription: `subs-rhcqa` (3991b88f-785e-4e03-bac3-e6721b76140b)

**Permissions:**
- ✅ Contributor role on `rhc-smx-qa-rg`
- ✅ AcrPush role on `rhcsmxqaacr`

### Step 4: SMX Container App Environment Variables

**Container App:** `rhc-smx-qa-app`  
**Managed Identity Principal ID:** `803e1c43-2245-49be-8463-a33df9bace0d`

**Environment Variables Configured:**
- ✅ DatabaseServer = `rhcdb-qa-sqlsvr.database.windows.net`
- ✅ DatabaseName = `qa_corp_db`
- ✅ KeyVaultUri = `https://rhc-smx-qa-kv-2025.vault.azure.net/`
- ✅ DatabaseTenantId = `4ed17c8b-26b0-4be9-a189-768c67fd03f5`
- ✅ ASPNETCORE_ENVIRONMENT = `Production`

**Key Vault Access Verified:**
- ✅ Managed identity has `Get` and `List` permissions on secrets
- ✅ Access policy exists for `803e1c43-2245-49be-8463-a33df9bace0d`
- ✅ Key Vault: `rhc-smx-qa-kv-2025`

---

## ⏳ Next Steps (Manual)

### Step 2: Configure GitHub Secrets

**Repository:** https://github.com/vokworks-ronk/smx25

1. Go to repository Settings → Secrets and variables → Actions
2. Add the following secrets (values in `PHASE6-GITHUB-SECRETS.md`):
   - `AZURE_CREDENTIALS_QA` (full JSON)
   - `AZURE_SUBSCRIPTION_ID`
   - `SMX_QA_RG`
   - `SMX_QA_APP_NAME`
   - `SMX_QA_ENV_NAME`
   - `ACR_NAME`
   - `SMX_QA_KV_NAME`
   - `DB_SERVER`
   - `DB_NAME`
   - `B2C_CLIENT_SECRET` (if available from Phase 4)

### Step 3: Create GitHub Actions Workflow

**File:** `.github/workflows/deploy-qa.yml` in SMX repository

1. Create the workflow file (template in `06-github-actions-qa.md`)
2. Commit to `main` branch
3. Create `qa` branch
4. Push to `qa` branch to trigger first deployment

### Step 6: Create QA Branch

```bash
cd /path/to/smx25
git checkout -b qa
git push -u origin qa
```

### Step 7: Test Deployment

After workflow file is created:

```bash
# Make a test change
echo "# QA Deployment Test" >> README.md
git add README.md
git commit -m "Test SMX QA deployment"
git push origin qa

# Watch: https://github.com/vokworks-ronk/smx25/actions
```

---

## 📊 Infrastructure Ready

**QA Tenant (rhcqa.onmicrosoft.com):**
- ✅ Service principal for deployments
- ✅ SMX Container App configured with environment variables
- ✅ Managed identity with Key Vault access
- ✅ ACR ready for image pushes

**Database Tenant (rhcdbase.onmicrosoft.com):**
- ✅ Service principal credentials in Key Vault (db-qa-app-id, db-qa-app-secret)
- ✅ SQL Server accessible (rhcdb-qa-sqlsvr.database.windows.net)
- ✅ Database ready (qa_corp_db)
- ✅ Entra group configured (db-qa-sqlsvr-app-users)

**Cross-Tenant Flow:**
1. Container App starts
2. Managed identity retrieves credentials from Key Vault
3. App uses service principal credentials to get OAuth token from Database tenant
4. App connects to SQL Server using access token
5. Database recognizes service principal via Entra group membership

---

## ⚠️ Important Notes

1. **Delete `PHASE6-GITHUB-SECRETS.md`** after configuring GitHub Secrets
2. **ACR Name** is `rhcsmxqaacr` (not `rhcsmxqaacr2025`)
3. **Managed Identity** is already configured for Key Vault access
4. **Database credentials** are in Key Vault, not in GitHub Secrets
5. **Service principal** has 2-year expiration on client secret

---

## 🔍 Verification Commands

```bash
# Verify service principal
az ad sp show --id f2f4c74d-6739-408f-b941-76f658712b16

# Verify role assignments
az role assignment list --assignee bf68f5da-62dd-49f3-b84f-8b2f9f4091f5 --output table

# Verify Container App config
az containerapp show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" --query "properties.template.containers[0].env"

# Verify Key Vault access
az keyvault show --name "rhc-smx-qa-kv-2025" --query "properties.accessPolicies[?objectId=='803e1c43-2245-49be-8463-a33df9bace0d']"

# Test ACR access
az acr login --name rhcsmxqaacr --username f2f4c74d-6739-408f-b941-76f658712b16 --password "RL08Q~aJteN9PF.YuDCHjbd~XJL7XiGgeiCNaceD"
```
