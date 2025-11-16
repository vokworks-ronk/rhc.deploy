# CIAM Authentication Configuration Fix

**Date:** November 14, 2025  
**Issue:** SMX QA authentication redirecting to wrong tenant  
**Root Cause:** Application configured for Azure AD instead of Azure AD B2C/CIAM  
**Status:** ✅ RESOLVED

---

## 🔴 Problem Summary

When accessing SMX QA at `https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io`, users were unable to authenticate:

**Symptoms:**
- Browser redirected to Microsoft login page
- Asked for username/password repeatedly
- Login attempts failed

**Error in Logs:**
```
AADSTS500208: The domain is not a valid login domain for the account type.
Message contains error: 'invalid_request'
```

**Root Cause:**
- QA tenant (`rhcqa.onmicrosoft.com`) is a **CIAM tenant** (Customer Identity and Access Management)
- CIAM supports **local accounts** with email/password authentication
- Application was configured for **Azure AD** (organizational accounts) instead of **CIAM**
- Wrong authentication endpoint used: `login.microsoftonline.com` instead of `rhcqa.ciamlogin.com`

---

## 🔧 Solution Implemented

### 1. Understanding CIAM/B2C Local Accounts

**CIAM Tenant Type:**
- QA tenant is type: `CIAM` (new name for Azure AD B2C)
- Supports local account authentication
- Users sign in with email/password stored in the tenant
- Examples: `rkrueger@celerasys.com`, `homer@gmail.com`, `user@example.com`
- **These are LOCAL accounts, not external identities**

**Key Difference:**
- **Azure AD:** Organizational accounts from corporate directory
- **CIAM/B2C:** Consumer/customer accounts with local passwords

### 2. Corrected Environment Variables

Changed Container App environment variables from Azure AD to CIAM configuration:

**BEFORE (Incorrect - Azure AD):**
```bash
AzureAd__Instance=https://login.microsoftonline.com/
AzureAd__Domain=rhcqa.onmicrosoft.com
AzureAd__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2
AzureAd__ClientId=f5c66c2e-400c-4af7-b397-c1c841504371
AzureAd__ClientSecret=JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK
```

**AFTER (Correct - CIAM):**
```bash
AzureAd__Instance=https://rhcqa.ciamlogin.com/
AzureAd__Domain=rhcqa.onmicrosoft.com
AzureAd__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2
AzureAd__ClientId=f5c66c2e-400c-4af7-b397-c1c841504371
AzureAd__ClientSecret=JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK
AzureAd__CallbackPath=/signin-oidc
```

**Critical Change:**
- Instance URL: `https://rhcqa.ciamlogin.com/` (CIAM endpoint)
- Added CallbackPath for OAuth redirect

### 3. Deployment Command

```bash
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --replace-env-vars \
    "AzureAd__Instance=https://rhcqa.ciamlogin.com/" \
    "AzureAd__Domain=rhcqa.onmicrosoft.com" \
    "AzureAd__TenantId=2604fd9a-93a6-448e-bdc9-25e3c2d671a2" \
    "AzureAd__ClientId=f5c66c2e-400c-4af7-b397-c1c841504371" \
    "AzureAd__ClientSecret=JdZ8Q~D10SiqYMwkdcdZF-IUQYBdriE3Jv54CalK" \
    "AzureAd__CallbackPath=/signin-oidc" \
    "DatabaseServer=rhcdb-qa-sqlsvr.database.windows.net" \
    "DatabaseName=qa_corp_db" \
    "KeyVaultUri=https://rhc-smx-qa-kv-2025.vault.azure.net/" \
    "DatabaseTenantId=4ed17c8b-26b0-4be9-a189-768c67fd03f5" \
    "ASPNETCORE_ENVIRONMENT=Production"
```

**Result:**
- New revision: `rhc-smx-qa-app--0000006`
- Status: Running
- Authentication: Working ✅

---

## 📋 CIAM Authentication Checklist

Use this checklist for all future deployments to CIAM/B2C tenants:

### Tenant Verification
- [ ] Verify tenant type is CIAM/B2C
  ```bash
  az rest --method GET --url "https://graph.microsoft.com/v1.0/organization" \
    --query "value[0].tenantType" -o tsv
  # Should return: "CIAM"
  ```

### Environment Variables (Container Apps)
- [ ] `AzureAd__Instance` = `https://{tenant-name}.ciamlogin.com/`
  - **NOT** `https://login.microsoftonline.com/`
- [ ] `AzureAd__Domain` = `{tenant-name}.onmicrosoft.com`
- [ ] `AzureAd__TenantId` = (CIAM tenant ID)
- [ ] `AzureAd__ClientId` = (App registration client ID)
- [ ] `AzureAd__ClientSecret` = (App registration secret)
- [ ] `AzureAd__CallbackPath` = `/signin-oidc`

### Application Configuration (appsettings.json)
- [ ] Configuration section name: `AzureAd` (app reads this)
- [ ] Environment variables override hardcoded values
- [ ] No hardcoded credentials in source code

### App Registration (Azure Portal)
- [ ] Redirect URI includes Container App URL + `/signin-oidc`
- [ ] Supported account types: "Accounts in this organizational directory only"
- [ ] ID tokens enabled (Implicit grant and hybrid flows)

### Testing
- [ ] User can access application URL
- [ ] Redirects to CIAM login page (rhcqa.ciamlogin.com)
- [ ] Can sign in with local account (e.g., rkrueger@celerasys.com)
- [ ] Successful authentication redirects back to application
- [ ] No authentication errors in Container App logs

---

## 🔍 How to Identify CIAM Tenants

### Via Azure CLI

```bash
# Login to tenant
az login --tenant {tenant-name}.onmicrosoft.com

# Check tenant type
az rest --method GET --url "https://graph.microsoft.com/v1.0/organization" \
  --query "value[0].{TenantType:tenantType,VerifiedDomains:verifiedDomains[].name}" -o json

# Returns:
# {
#   "TenantType": "CIAM",  <-- This indicates CIAM/B2C
#   "VerifiedDomains": [
#     "rhcqa.onmicrosoft.com"
#   ]
# }
```

### Via Azure Portal

1. Go to **Azure Active Directory** → **Overview**
2. Look for tenant type label
3. CIAM tenants show "External Identities" features

---

## 📊 Tenant Architecture Summary

**Project Tenants:**

| Tenant | Type | Purpose | Authentication |
|--------|------|---------|----------------|
| `rhcqa.onmicrosoft.com` | CIAM | QA user authentication | Local accounts (email/password) |
| `rhcdbase.onmicrosoft.com` | Azure AD | Database infrastructure | Organizational accounts |
| `vokworks.onmicrosoft.com` | Azure AD | Development | Organizational accounts |
| `recalibratehealthcare.com` | Azure AD | Production (future) | Organizational accounts |

**Authentication Endpoints:**

| Tenant | Endpoint | Use Case |
|--------|----------|----------|
| rhcqa | `https://rhcqa.ciamlogin.com/` | SMX/HP2 QA user login |
| rhcdbase | `https://login.microsoftonline.com/` | Database service principal |
| vokworks | `https://login.microsoftonline.com/` | Developer access |

---

## 🎯 Lessons Learned

### 1. Document Tenant Types Early
- Always verify and document tenant type during Phase 1 (Tenant Creation)
- Add tenant type to all architecture diagrams
- Include in QUICK-REFERENCE.md

### 2. CIAM vs Azure AD Configuration
- CIAM uses different login endpoints (`.ciamlogin.com`)
- Local accounts are stored IN the tenant, not external
- Example: `user@gmail.com` in CIAM = local account, not Google login

### 3. Environment Variables Are Critical
- Always override hardcoded appsettings.json values
- Container Apps: Use `--replace-env-vars` or `--set-env-vars`
- Never commit secrets to source code

### 4. Testing After Deployment
- Always test authentication end-to-end
- Check Container App logs for errors
- Verify redirect URIs match exactly

### 5. Configuration Naming
- Application code uses `AzureAd` config section
- Works for both Azure AD and CIAM/B2C
- The **Instance** URL determines behavior

---

## 📝 Updated Documentation

The following documents have been updated to reflect CIAM authentication:

- [x] `docs/04-b2c-tenant-setup.md` - Already documented CIAM
- [x] `docs/05-resource-groups-and-services.md` - Updated environment variables
- [x] `docs/06-github-actions-qa.md` - Corrected ACR name, added CIAM notes
- [x] `docs/PHASE6-PROGRESS.md` - Added authentication fix details
- [x] `docs/CIAM-AUTHENTICATION-FIX.md` - This document (NEW)

---

## 🔄 Apply to Future Environments

When deploying to **STAGING** and **PRODUCTION**, remember:

### Staging Environment
- [ ] Verify staging tenant type
- [ ] If CIAM: Use `https://{staging-tenant}.ciamlogin.com/`
- [ ] Configure environment variables correctly
- [ ] Test authentication before production

### Production Environment
- [ ] Document production tenant type
- [ ] Configure authentication endpoint based on tenant type
- [ ] Use production app registration IDs
- [ ] Store all secrets in Key Vault
- [ ] Test with production users

---

## ✅ Verification Completed

**SMX QA Authentication Status:** ✅ WORKING

- Users can access: `https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io`
- Redirects to: `https://rhcqa.ciamlogin.com/...`
- Local account login: `rkrueger@celerasys.com` (local password)
- Authentication flow: Complete ✅
- Container App revision: `rhc-smx-qa-app--0000006`

**Next:** Apply same configuration pattern to HP2 when ready to deploy.

---

**Document Version:** 1.0  
**Last Updated:** November 14, 2025  
**Status:** ✅ Complete
