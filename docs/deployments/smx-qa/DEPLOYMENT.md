# SMX QA Deployment

**Environment:** QA  
**Application:** SMX  
**Status:** ✅ Working with branding feature deployed  
**Last Updated:** November 16, 2025

---

## 📊 Quick Reference

| Resource | Value |
|----------|-------|
| **Container App** | `rhc-smx-qa-app` |
| **Resource Group** | `rhc-smx-qa-rg` |
| **URL** | https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io |
| **Custom Domain** | `smx-qa.recalibratex.net` (configured) |
| **Tenant** | `rhcqa.onmicrosoft.com` (CIAM) |
| **Tenant ID** | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` |
| **Subscription** | `subs-rhcqa` (`3991b88f-785e-4e03-bac3-e6721b76140b`) |

---

## 🎯 Current Status

- ✅ Authentication working (CIAM tenant)
- ✅ Database connected (service principal auth)
- ✅ DataProtection configured (blob + Key Vault)
- ✅ Application Insights connected
- ✅ GitHub Actions deployment working
- ✅ Custom domain configured
- ✅ **Branding configured** ("SMX QA v0.1.0" with build info)

---

## 📋 Environment Variables

**Current Backup:** `env-vars-backup-20251116-044745.json`  
**Total Variables:** 31

**Branding Configuration:**
- **Application__Branding__ApplicationName** = "SMX QA"
- **Application__Branding__Version** = "0.1.0"

**⚠️ CRITICAL:** Always backup before changes:
```powershell
.\docs\backup-env-vars.ps1 -AppName rhc-smx-qa-app -ResourceGroup rhc-smx-qa-rg -Environment smx-qa
```

---

## 📝 Deployment History

See: `PHASE6-PROGRESS.md` and `QA-DEPLOYMENT-SUMMARY.md` in this folder.

---

## 🔧 Configuration Files

- `QA-CONFIGURATION-REFERENCE.md` - Complete configuration reference
- `env-vars-backup-*.json` - Environment variable backups (to be added)

---

## 🆘 Emergency Contacts

- **Azure Subscription Owner:** [To be filled]
- **Database Admin:** [To be filled]
