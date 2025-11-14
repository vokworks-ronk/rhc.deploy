# Phase 6: GitHub Secrets Configuration

**Created:** November 13, 2025  
**Status:** Ready to configure

---

## ⚠️ IMPORTANT - SECURE CREDENTIALS

This file contains sensitive credentials. **DELETE THIS FILE** after configuring GitHub Secrets.

---

## Service Principal for GitHub Actions

**Service Principal Name:** `github-actions-qa-deployer`  
**Client ID:** `f2f4c74d-6739-408f-b941-76f658712b16`  
**Client Secret:** `RL08Q~aJteN9PF.YuDCHjbd~XJL7XiGgeiCNaceD`  
**Tenant ID:** `2604fd9a-93a6-448e-bdc9-25e3c2d671a2`  
**Subscription ID:** `3991b88f-785e-4e03-bac3-e6721b76140b`  
**Object ID:** `bf68f5da-62dd-49f3-b84f-8b2f9f4091f5`

**Permissions:**
- Contributor role on `rhc-smx-qa-rg`
- AcrPush role on `rhcsmxqaacr`

---

## AZURE_CREDENTIALS_QA Secret (Full JSON)

Use this entire JSON as the value for `AZURE_CREDENTIALS_QA` in GitHub Secrets:

```json
{
  "clientId": "f2f4c74d-6739-408f-b941-76f658712b16",
  "clientSecret": "RL08Q~aJteN9PF.YuDCHjbd~XJL7XiGgeiCNaceD",
  "subscriptionId": "3991b88f-785e-4e03-bac3-e6721b76140b",
  "tenantId": "2604fd9a-93a6-448e-bdc9-25e3c2d671a2",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

---

## SMX Repository Secrets (vokworks-ronk/smx25)

Go to: https://github.com/vokworks-ronk/smx25/settings/secrets/actions

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS_QA` | (entire JSON above) |
| `AZURE_SUBSCRIPTION_ID` | `3991b88f-785e-4e03-bac3-e6721b76140b` |
| `SMX_QA_RG` | `rhc-smx-qa-rg` |
| `SMX_QA_APP_NAME` | `rhc-smx-qa-app` |
| `SMX_QA_ENV_NAME` | `rhc-smx-qa-env` |
| `ACR_NAME` | `rhcsmxqaacr` |
| `SMX_QA_KV_NAME` | `rhc-smx-qa-kv-2025` |
| `DB_SERVER` | `rhcdb-qa-sqlsvr.database.windows.net` |
| `DB_NAME` | `qa_corp_db` |
| `B2C_CLIENT_SECRET` | (from Phase 4 - if you have it) |

---

## HP2 Repository Secrets (vokworks-ronk/hp225) - LATER

Configure these after SMX is validated:

Go to: https://github.com/vokworks-ronk/hp225/settings/secrets/actions

| Secret Name | Value |
|-------------|-------|
| `AZURE_CREDENTIALS_QA` | (same JSON as SMX) |
| `AZURE_SUBSCRIPTION_ID` | `3991b88f-785e-4e03-bac3-e6721b76140b` |
| `HP2_QA_RG` | `rhc-hp2-qa-rg` |
| `HP2_QA_APP_NAME` | `rhc-hp2-qa-app` |
| `HP2_QA_KV_NAME` | `rhc-hp2-qa-kv-2025` |
| `DB_SERVER` | `rhcdb-qa-sqlsvr.database.windows.net` |
| `DB_NAME` | `qa_corp_db` |
| `B2C_CLIENT_SECRET` | (from Phase 4 - if you have it) |

---

## Next Steps

1. ✅ Service principal created
2. ✅ ACR push permission granted
3. ⏳ Configure GitHub Secrets in SMX repository (manual step in GitHub UI)
4. ⏳ Configure SMX Container App environment variables
5. ⏳ Create GitHub Actions workflow file in SMX repository
6. ⏳ Test SMX deployment

**REMEMBER:** Delete this file after configuring GitHub Secrets!

---

## Verification Commands

```bash
# Verify service principal exists
az ad sp show --id f2f4c74d-6739-408f-b941-76f658712b16

# Verify role assignments
az role assignment list --assignee bf68f5da-62dd-49f3-b84f-8b2f9f4091f5 --output table

# Test ACR login with service principal
az acr login --name rhcsmxqaacr --username f2f4c74d-6739-408f-b941-76f658712b16 --password "RL08Q~aJteN9PF.YuDCHjbd~XJL7XiGgeiCNaceD"
```
