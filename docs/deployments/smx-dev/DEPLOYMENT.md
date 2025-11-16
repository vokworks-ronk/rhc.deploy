# SMX Dev Deployment

**Environment:** Development  
**Application:** SMX  
**Status:** ✅ Working (recently recovered from env var wipe)  
**Last Updated:** November 16, 2025

---

## 📊 Quick Reference

| Resource | Value |
|----------|-------|
| **Container App** | `smx25dev-app` |
| **Resource Group** | `smx25dev-rg` |
| **URL** | https://smx25dev-app.agreeablemoss-80fddddc.eastus2.azurecontainerapps.io |
| **Custom Domain** | `smx-dev.recalibratex.net` |
| **Tenant** | `smx25dev.onmicrosoft.com` (B2C/CIAM) |
| **Tenant ID** | `cd21a3bf-622c-4725-8da7-2f8b9d265d14` |
| **Subscription** | `subs-smx25dev` (`70a93d6d-b91d-4dae-b879-a510995c5be5`) |
| **Location** | East US 2 |

---

## 🎯 Current Status

- ✅ Application running
- ✅ Authentication working (B2C/CIAM tenant)
- ✅ Database connected (remote SQL Server)
- ✅ DataProtection configured (blob + Key Vault)
- ✅ Application Insights connected
- ✅ GitHub Actions deployment working
- ✅ Custom domain configured
- ⚠️ Recently recovered from environment variable wipe (Nov 15, 2025)

---

## 🏗️ Architecture Notes

**Tenant Structure:**
- **smx25dev.onmicrosoft.com** is a B2C/CIAM tenant
- Hosts TWO applications:
  - SMX Dev (this app) - in `smx25dev-rg`
  - HP2 Dev - in separate resource group in same tenant
- Users may have access to one or both apps
- This pattern (2 apps, 1 B2C tenant) repeats for QA and Production

**Database Access:**
- Databases are in a DIFFERENT tenant (not smx25dev)
- Cross-tenant access via connection strings
- No tenant-to-tenant trust needed

---

## 🔧 Azure Resources

### Container Apps
- **App Name:** `smx25dev-app`
- **Environment:** `smx25dev-env`
- **Managed Identity Principal ID:** `27b3100f-aac7-4b3c-9cb4-1ed34c24603d`
- **FQDN:** `smx25dev-app.agreeablemoss-80fddddc.eastus2.azurecontainerapps.io`

### Container Registry
- **Name:** `smx25devacr`
- **Login Server:** `smx25devacr.azurecr.io`

### Key Vault
- **Name:** `smx25dev-kv`
- **URI:** `https://smx25dev-kv.vault.azure.net/`

### Storage Account
- **Name:** `smx25devstorage`
- **Blob Endpoint:** `https://smx25devstorage.blob.core.windows.net/`
- **DataProtection Container:** `dataprotection`

### Application Insights
- **Name:** `smx25dev-insights`
- **Type:** `Microsoft.Insights/components`

### Log Analytics
- **Name:** `workspace-smx25dev-rg`
- **Type:** `Microsoft.OperationalInsights/workspaces`

### Communication Services
- **Communication Services:** `smx25dev-comms`
- **Email Service:** `smx25dev-email`
- **Domain:** `AzureManagedDomain`

---

## 🔐 Authentication

### B2C/CIAM Configuration
- **Instance:** `https://smx25dev.ciamlogin.com/`
- **Domain:** `smx25dev.onmicrosoft.com`
- **Tenant ID:** `cd21a3bf-622c-4725-8da7-2f8b9d265d14`
- **Client ID:** (stored in env vars - see backup files)
- **Client Secret:** Stored in Key Vault

**Note:** This is a CIAM tenant, not traditional Azure AD. Uses local accounts with email/password authentication.

---

## 🗄️ Database

### Connection Details
- **Server:** (Remote SQL Server in different tenant)
- **Database:** (Multiple databases accessed via connection strings)
- **Authentication:** Connection strings with credentials
- **Note:** Database details intentionally kept minimal as they're in a separate tenant

---

## 📋 Environment Variables

**Current Backup:** `env-vars-backup-20251116-033750.json`  
**Total Variables:** 19

**Key Variables Documented:**
- EntraExternalId configuration
- Database connection strings
- DataProtection settings
- Application Insights
- Communication Services

**⚠️ CRITICAL:** Always backup before changes using:
```powershell
.\docs\backup-env-vars.ps1 -AppName smx25dev-app -ResourceGroup smx25dev-rg -Environment smx-dev
```

---

## 📝 Deployment History

| Date | Action | Result | Notes |
|------|--------|--------|-------|
| Nov 16, 2025 | Environment variables backed up | ✅ Success | 19 vars backed up to prevent future loss |
| Nov 15, 2025 | Environment variables restored | ✅ Success | Recovered from accidental wipe |
| Nov 15, 2025 | ⚠️ Environment variables wiped | ❌ Disaster | Claude agent used `--replace-env-vars` |
| Aug 20, 2025 | Blob storage data protection deployed | ✅ Success | Build 77 |

---

## 🔗 Related Applications

**HP2 Dev** - Also in smx25dev.onmicrosoft.com tenant
- Different resource group
- Shares same B2C tenant
- Users may access both apps

---

## 🚀 GitHub Repository

- **Repo:** `vokworks-ronk/smx25`
- **Branch:** `develop`
- **GitHub Actions:** Auto-deploy on push to develop

---

## 🆘 Emergency Contacts

- **Tenant Admin:** Ron
- **DevOps:** Ron  
- **Database Admin:** (separate tenant)

---

## 📖 Additional Documentation

- See `../../reference/ENVIRONMENT_VARIABLES_INVENTORY.md` for detailed variable analysis
- See `DANGER-ENVIRONMENT-VARIABLES.md` for safety warnings
- See backup files in this folder for complete env var history
