## 🔑 Quick Reference - Key Information

**Project:** Recalibrate Healthcare QA Deployment  
**Last Updated:** November 14, 2025

---

## 🏢 Existing Infrastructure

### Back Office Tenant
- **Domain:** `recalibratehealthcare.com`
- **Tenant ID:** `ed01df5d-6b39-45f8-82ae-36b88e5daae0`
- **Usage:** Office 365, existing marketing website
- **Status:** LEAVE ALONE - not touching this

### Dev B2C Tenant
- **Domain:** `smx25dev.onmicrosoft.com`
- **Tenant ID:** `cd21a3bf-622c-4725-8da7-2f8b9d265d14`
- **Usage:** Current development environment
- **Status:** Keep running - dev stays separate from QA

### Dev Database Tenant
- **Domain:** `vokworks.onmicrosoft.com`
- **SQL Server:** `smxcore-sqlsvr.database.windows.net`
- **Databases:** `smxcore_corp_db`, `smxcore_hp2_db`, `smxcore_hm2_db`
- **Status:** Keep for dev only

---

## 🆕 New Infrastructure (To Be Created)

### New Tenants

> **⚠️ CRITICAL:** QA tenant is **CIAM** type (Customer Identity and Access Management), formerly Azure AD B2C. Supports **LOCAL ACCOUNTS** with email/password authentication.
> 
> **Authentication Endpoint:** Use `https://rhcqa.ciamlogin.com/` for CIAM tenants, NOT `login.microsoftonline.com`

| Purpose | Domain | Tenant ID | Tenant Type | Status |
|---------|--------|-----------|-------------|--------|
| QA (CIAM) | `rhcqa.onmicrosoft.com` | `2604fd9a-93a6-448e-bdc9-25e3c2d671a2` | **CIAM** | ✅ Created |
| Database (Azure AD) | `rhcdbase.onmicrosoft.com` | `4ed17c8b-26b0-4be9-a189-768c67fd03f5` | Azure AD | ✅ Created |
### New Subscriptions

| Name | Subscription ID | Purpose | Status |
|------|----------------|---------|--------|
| `subs-rhcqa` | `3991b88f-785e-4e03-bac3-e6721b76140b` | QA environment resources | ✅ Created |
| `subs-rhcdbase` | `a73a2d39-598b-4671-a3a6-2028c59f3d40` | Database resources | ✅ Created |
| `rhc-prod-sub` | (fill after creation) | Production resources (future) | ⬜ Future ||
| `rhc-prod-sub` | Production resources (future) | ⬜ Create in Phase 2 |
| `rhc-db-core-sub` | Database resources | ⬜ Create in Phase 2 |

### QA Databases

| Server | Database | Purpose | Tier | Status |
|--------|----------|---------|------|--------|
| `rhcdb-qa-sqlsvr.database.windows.net` | `qa_corp_db` | Shared/corporate data | Standard S0 | ✅ Created |
| `rhcdb-qa-sqlsvr.database.windows.net` | `qa_hp2_db` | HP2 application data | Standard S0 | ✅ Created |

---

## 🌐 Custom Domains

### Existing (Dev)
- ✅ `hp2-dev.recalibratex.net` → HP2 Dev
- ✅ `smx-dev.recalibratex.net` → SMX Dev

### To Be Configured (QA)
- ⬜ `hp2-qa.recalibratex.net` → HP2 QA
- ⬜ `smx-qa.recalibratex.net` → SMX QA

### Future (Production)
- ⬜ `hp2.recalibratex.net` → HP2 Production
- ⬜ `smx.recalibratex.net` → SMX Production

---

## 📦 Application Architecture

### HP2 (Healthcare Practice Management)
- **Users:** Healthcare practices (B2C external users)
- **Purpose:** Manage patients and practice operations
- **Database Access:** `corp_db` (read) + `hp2_db` (read/write)
- **GitHub Repo:** `vokworks-ronk/hp225`

### SMX (Staff Management)
- **Users:** Internal staff (B2C internal users)
- **Purpose:** Support HP2 customers
- **Database Access:** `corp_db` (read/write)
- **GitHub Repo:** `vokworks-ronk/smx25`

---

## 🔐 Security Requirements

### Authentication
- ✅ Email/password only (no social logins)
- ✅ MFA required for ALL users
- ✅ Invitation-only sign-up
- ✅ Strong password policies

### Database
- ✅ Entra ID authentication ONLY
- ❌ NO SQL authentication
- ✅ Managed Identity preferred
- ✅ Audit logging enabled

### Compliance
- ✅ HIPAA compliance required
- ✅ PCI-DSS (use payment gateway, don't store cards)
- ✅ Maximum security posture

---

## 📊 Resource Naming Convention

### Pattern
`rhc-<app>-<env>-<type>`

### Examples
- Resource Group: `rhc-hp2-qa-rg`
- Container App: `rhc-hp2-qa-app`
- Key Vault: `rhc-hp2-qa-kv`
- SQL Server: `rhc-qa-sqlsvr`

### Special Cases
- Container Registry: `rhcsmxqaacr` (no hyphens, lowercase)
- Storage Account: `rhcsmxqastorage` (no hyphens, lowercase)

---

## 🔑 Important IDs to Track

### Tenant IDs
```
Back Office:     ed01df5d-6b39-45f8-82ae-36b88e5daae0
Dev (smx25dev):  cd21a3bf-622c-4725-8da7-2f8b9d265d14
QA (CIAM):       2604fd9a-93a6-448e-bdc9-25e3c2d671a2  ✅
Database:        4ed17c8b-26b0-4be9-a189-768c67fd03f5  ✅
Prod:            ___________________________________
```

### Subscription IDs
```
QA:              3991b88f-785e-4e03-bac3-e6721b76140b  ✅
Database:        a73a2d39-598b-4671-a3a6-2028c59f3d40  ✅
Production:      ___________________________________
```

### Application IDs (CIAM/External ID)
```
HP2 QA:          cfdc3d4b-dfe3-4414-a09d-a11a568187de  ✅
SMX QA:          f5c66c2e-400c-4af7-b397-c1c841504371  ✅
HP2 Prod:        ___________________________________
SMX Prod:        ___________________________________
```

### Managed Identity IDs
```
HP2 QA:          79266d50-2220-4237-bc2a-588f83c39d54  ✅
SMX QA:          803e1c43-2245-49be-8463-a33df9bace0d  ✅
```

---

## 🚀 Deployment Phases

### Phase 1: Tenant Creation (45-60 min)
Create 3 new tenants manually via Azure Portal

### Phase 2: Subscription Setup (30-45 min)
Create subscriptions and link billing

### Phase 3: Database Tenant Setup (45-60 min)
Create SQL servers and databases

### Phase 4: B2C Tenant Configuration (60-90 min)
Configure user flows, MFA, app registrations

### Phase 5: Resource Groups & Services (90-120 min)
Create all Azure resources for HP2 and SMX

### Phase 6: GitHub Actions CI/CD (60-90 min)
Set up automated deployments

### Phase 7: Security Review (Ongoing)
Validate security and compliance

---

## 📝 Key Vault Secrets to Store

### HP2 QA Key Vault (`rhc-hp2-qa-kv`)
- `B2C-ClientId`
- `B2C-ClientSecret`
- `B2C-TenantId`
- `ApplicationInsights-InstrumentationKey`
- `CommunicationServices-ConnectionString`

### SMX QA Key Vault (`rhc-smx-qa-kv`)
- `B2C-ClientId`
- `B2C-ClientSecret`
- `B2C-TenantId`
- `ApplicationInsights-InstrumentationKey`
- `CommunicationServices-ConnectionString`
- `Storage-ConnectionString`

---

## 🌐 URLs to Remember

### Azure Portals
- Main: https://portal.azure.com
- B2C Admin: https://portal.azure.com#blade/Microsoft_AAD_B2CAdmin
- SQL: https://portal.azure.com#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Sql%2Fservers

### GitHub Repos
- HP2: https://github.com/vokworks-ronk/hp225
- SMX: https://github.com/vokworks-ronk/smx25

### Documentation
- Microsoft Graph: https://docs.microsoft.com/graph
- Azure CLI: https://docs.microsoft.com/cli/azure
- B2C Docs: https://docs.microsoft.com/azure/active-directory-b2c

---

## ⚡ Quick Commands

### Switch to Tenant
```bash
az login --tenant <tenant-name>.onmicrosoft.com
```

### Set Subscription
```bash
az account set --subscription <subscription-name>
```

### List Resources
```bash
az resource list --resource-group <rg-name> --output table
```

### View Container App
```bash
az containerapp show --name <app-name> --resource-group <rg-name>
```

### Get Container App URL
```bash
az containerapp show --name <app-name> --resource-group <rg-name> --query "properties.configuration.ingress.fqdn" -o tsv
```

### View Logs
```bash
az containerapp logs show --name <app-name> --resource-group <rg-name> --tail 50
```

---

## 🎯 Success Checklist

### Phase Complete When:
- [ ] All resources created (check with `az resource list`)
- [ ] All secrets in Key Vault (check Key Vault in portal)
- [ ] Apps deployed (check Container Apps status)
- [ ] Custom domains working (test in browser)
- [ ] Authentication working (test sign-in)
- [ ] Database connectivity working (check app logs)
- [ ] CI/CD working (push to qa branch)
- [ ] Monitoring working (check Application Insights)

---

## 📞 Contacts

| Role | Name | Email/Contact |
|------|------|---------------|
| Project Lead | Ron | |
| Domain Admin | Ron | |

---

## 💡 Common Gotchas

1. **Tenant creation is manual** - no way to automate it
2. **DNS takes time** - allow 15-30 minutes for propagation
3. **Secrets expire** - check expiration dates
4. **Case sensitivity** - Azure resource names are case-insensitive, but URLs are case-sensitive
5. **Managed Identity** - must be configured from both sides (app and database)
6. **⚠️ CIAM Authentication** - CRITICAL for QA/Prod environments:
   - Use `https://{tenant}.ciamlogin.com/` for CIAM tenants
   - NOT `https://login.microsoftonline.com/`
   - Local accounts use email/password (e.g., `user@example.com`)
   - See `docs/CIAM-AUTHENTICATION-FIX.md` for complete details

---

## 🔄 Daily Workflow (After Setup)

### Developer Makes Changes
1. Commit to `qa` branch
2. Push to GitHub
3. GitHub Actions automatically deploys
4. Test at `hp2-qa.recalibratex.net` or `smx-qa.recalibratex.net`

### Monitoring
1. Check Application Insights daily
2. Review error logs
3. Monitor costs in Azure Portal
4. Review audit logs weekly

---
**Document Version:** 1.1  
**Last Updated:** November 14, 2025  
**Status:** ✅ QA Environment Complete - CIAM Authentication Configured
---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Status:** ✅ Ready for Use
