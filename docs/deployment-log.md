# 📝 Deployment Log

**Project:** Recalibrate Healthcare Multi-Tenant QA Deployment  
**Project Lead:** Ron  
**Start Date:** October 27, 2025

---

## 📋 Log Purpose

This document tracks all deployment activities, decisions, and issues encountered during the QA environment deployment. Update this file as you complete each phase.

---

## 🎯 Overall Project Status

| Phase | Status | Completion Date | Notes |
|-------|--------|-----------------|-------|
| Phase 1: Tenant Creation | ✅ Complete | Nov 5, 2025 | Created rhcqa, rhcprod, rhcdbase tenants |
| Phase 2: Subscription Setup | ✅ Complete | Nov 5, 2025 | Created subscriptions for all tenants |
| Phase 3: Database Tenant Setup | ✅ Complete | Nov 11, 2025 | All infrastructure, DBA users, service principals complete |
| Phase 4: B2C Tenant Setup | ⬜ Not Started | | User flows and MFA |
| Phase 5: Resource Groups & Services | ⬜ Not Started | | Container Apps, Key Vault, etc. |
| Phase 6: GitHub Actions CI/CD | ⬜ Not Started | | Automated deployments |
| Phase 7: Security & Compliance | ⬜ Not Started | | Review and validation |

**Legend:**
- ⬜ Not Started
- 🔄 In Progress
- ✅ Complete
- ⚠️ Blocked/Issues

---

## 📅 Detailed Activity Log

### Phase 1: Tenant Creation

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### Tenants Created

- [ ] **B2C QA Tenant**
  - Domain: `rhc-b2c-qa.onmicrosoft.com`
  - Tenant ID: `_________________________`
  - Creation Date: `_______________`
  - Notes: _________________________

- [ ] **B2C Production Tenant**
  - Domain: `rhc-b2c-prod.onmicrosoft.com`
  - Tenant ID: `_________________________`
  - Creation Date: `_______________`
  - Notes: _________________________

- [ ] **Database Tenant**
  - Domain: `rhcdbcore.onmicrosoft.com`
  - Tenant ID: `_________________________`
  - Creation Date: `_______________`
  - Notes: _________________________

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

### Phase 2: Subscription Setup

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### Subscriptions Created

- [ ] **QA Subscription**
  - Name: `rhc-b2c-qa-sub`
  - Subscription ID: `_________________________`
  - Linked to: `rhc-b2c-qa.onmicrosoft.com`
  - Notes: _________________________

- [ ] **Production Subscription**
  - Name: `rhc-b2c-prod-sub`
  - Subscription ID: `_________________________`
  - Linked to: `rhc-b2c-prod.onmicrosoft.com`
  - Notes: _________________________

- [ ] **Database Subscription**
  - Name: `rhc-db-core-sub`
  - Subscription ID: `_________________________`
  - Linked to: `rhcdbcore.onmicrosoft.com`
  - Notes: _________________________

#### Billing Configuration

- [ ] Cost management alerts configured
- [ ] Budget limits set
- [ ] Billing linked to recalibratehealthcare.com

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

### Phase 3: Database Tenant Setup

**Date Started:** November 6, 2025  
**Date Completed:** November 11, 2025  
**Status:** ✅ Complete

#### Infrastructure Created

- [X] **Resource Groups**
  - `db-lam-rg` created in East US 2
  - `db-qa-rg` created in East US 2
  - `db-prod-rg` created in East US 2

- [X] **LAM SQL Server**
  - Name: `rhcdb-lam-sqlsvr.database.windows.net`
  - Entra-only authentication: ✅
  - SQL authentication: ❌ Disabled
  - Firewall rules configured (Nashua office IP)
  - Managed Identity: Enabled

- [X] **QA SQL Server**
  - Name: `rhcdb-qa-sqlsvr.database.windows.net`
  - Entra-only authentication: ✅
  - SQL authentication: ❌ Disabled
  - Firewall rules configured (Nashua office IP)
  - Managed Identity: Enabled

- [X] **Production SQL Server**
  - Name: `rhcdb-prod-sqlsvr.database.windows.net`
  - Entra-only authentication: ✅
  - SQL authentication: ❌ Disabled
  - Firewall rules configured (Nashua office IP)
  - Managed Identity: Enabled

- [X] **LAM Database**
  - `lam_db` created (Standard S0, 10 DTU)

- [X] **QA Databases**
  - `qa_corp_db` created (Standard S0, 10 DTU)
  - `qa_hp2_db` created (Standard S0, 10 DTU)

- [X] **Production Databases**
  - `prod_corp_db` created (Standard S0, 10 DTU)
  - `prod_hp2_db` created (Standard S0, 10 DTU)

- [X] **Security Configuration**
  - Audit logging enabled on all 3 servers
  - Microsoft Defender for SQL enabled (30-day free trial)
  - Log Analytics workspace: `rhcdb-audit-logs` (eastus2)

#### DBA Access Configuration

- [X] **DBA Users Created**
  - icelerasys@rhcdbase.onmicrosoft.com
  - mmcguirk@rhcdbase.onmicrosoft.com
  - dtuck@rhcdbase.onmicrosoft.com
  - bscott@rhcdbase.onmicrosoft.com
  - Ron's B2B account added (ron@recalibratehealthcare.com)

- [X] **Admin Security Groups**
  - db-lam-sqlsvr-admin (5 members)
  - db-qa-sqlsvr-admin (5 members)
  - db-prod-sqlsvr-admin (5 members)

#### Application Access Configuration

- [X] **Service Principals Created**
  - app-lam-db-access (App ID: 85a62c04-b11c-41d5-9b8c-ef9083e98c41)
  - app-qa-db-access (App ID: 694db84f-ab2d-4410-b94e-92dbc8a24205)
  - app-prod-db-access (App ID: 2f5e8533-d09b-4ac1-9f50-db184b61258a)

- [X] **App-Users Security Groups**
  - db-lam-sqlsvr-app-users (1 service principal)
  - db-qa-sqlsvr-app-users (1 service principal)
  - db-prod-sqlsvr-app-users (1 service principal)

- [X] **Database Users Created**
  - All 5 databases have app-users groups with db_datareader, db_datawriter, EXECUTE permissions

#### Issues Encountered

**MAJOR ISSUE: Azure Regional Capacity Constraints (Nov 6-11)**
- Problem: "RegionDoesNotAllowProvisioning" errors when creating SQL servers
- Regions affected: East US, East US 2, Central US, South Central US, West US 2
- Azure Support: Unhelpful, misdiagnosed phantom servers as real resources
- **WORKAROUND (User Solution):**
  1. Deleted all 3 resource groups
  2. Waited 1 hour for Azure backend propagation
  3. Recreated resource groups in East US 2
  4. All servers created successfully immediately after
- Result: 5-day delay, but all infrastructure operational

**EARLIER ISSUE: CIAM Tenant Type (Nov 5-6)**
- Original rhcdb tenant was CIAM type (incompatible with SQL Server)
- Rebuilt entirely as rhcdbase with workforce tenant type
- Documented in rebuildDBserver.md

#### Lessons Learned

1. **Always verify tenant type immediately after creation** - CIAM vs Workforce is permanent
2. **Azure capacity messages can be misleading** - Delete/recreate with wait period can clear stuck state
3. **Don't rely solely on Azure support** - User workarounds sometimes more effective
4. **Document phantom resource issues** - Failed operations create metadata that confuses support
5. **Service principals work better than managed identity for cross-tenant** - Database tenant isolation maintained

---

### Phase 4: B2C Tenant Configuration

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### User Flows

- [ ] **Sign Up and Sign In Flow**
  - Name: `B2C_1_signupsignin_qa`
  - MFA: Required ✅
  - Email verification: Enabled ✅
  - Password policy: Configured ✅

#### Application Registrations

- [ ] **HP2 QA Application**
  - App ID: `_________________________`
  - Client Secret: Stored in Key Vault
  - Redirect URI: `https://hp2-qa.recalibratex.net/signin-oidc`

- [ ] **SMX QA Application**
  - App ID: `_________________________`
  - Client Secret: Stored in Key Vault
  - Redirect URI: `https://smx-qa.recalibratex.net/signin-oidc`

#### Security Configuration

- [ ] MFA enforcement verified
- [ ] Password policies configured
- [ ] Audit logging enabled
- [ ] Token lifetimes configured

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

### Phase 5: Resource Groups and Services

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### HP2 QA Resources

- [ ] Resource Group: `rhc-hp2-qa-rg` (East US 2)
- [ ] Log Analytics: `rhc-hp2-qa-logs`
- [ ] Application Insights: `rhc-hp2-qa-insights`
- [ ] Container Apps Environment: `rhc-hp2-qa-env`
- [ ] Container App: `rhc-hp2-qa-app`
- [ ] Key Vault: `rhc-hp2-qa-kv`
- [ ] Communication Services: `rhc-hp2-qa-comms`

**HP2 Managed Identity ID:** `_________________________`

#### SMX QA Resources

- [ ] Resource Group: `rhc-smx-qa-rg` (East US 2)
- [ ] Container Registry: `rhcsmxqaacr`
- [ ] Log Analytics: `rhc-smx-qa-logs`
- [ ] Application Insights: `rhc-smx-qa-insights`
- [ ] Container Apps Environment: `rhc-smx-qa-env`
- [ ] Container App: `rhc-smx-qa-app`
- [ ] Key Vault: `rhc-smx-qa-kv`
- [ ] Storage Account: `rhcsmxqastorage`
- [ ] Communication Services: `rhc-smx-qa-comms`

**SMX Managed Identity ID:** `_________________________`

#### Key Vault Secrets

- [ ] B2C Client IDs stored
- [ ] B2C Client Secrets stored
- [ ] Application Insights keys stored
- [ ] Communication Services connection strings stored

#### Database Access Configured

- [ ] HP2 Managed Identity → corp_db, hp2_db
- [ ] SMX Managed Identity → corp_db

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

### Phase 6: GitHub Actions CI/CD

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### Service Principal

- [ ] Service principal created: `github-actions-qa-deployer`
- [ ] Client ID: `_________________________`
- [ ] Granted Contributor role to resource groups
- [ ] Granted AcrPush role to SMX Container Registry

#### GitHub Secrets Configured

**HP2 Repository (vokworks-ronk/hp225):**
- [ ] `AZURE_CREDENTIALS_QA`
- [ ] `AZURE_SUBSCRIPTION_ID`
- [ ] `HP2_QA_RG`
- [ ] `HP2_QA_APP_NAME`
- [ ] `B2C_CLIENT_SECRET`

**SMX Repository (vokworks-ronk/smx25):**
- [ ] `AZURE_CREDENTIALS_QA`
- [ ] `AZURE_SUBSCRIPTION_ID`
- [ ] `SMX_QA_RG`
- [ ] `SMX_QA_APP_NAME`
- [ ] `ACR_NAME`
- [ ] `B2C_CLIENT_SECRET`

#### Workflows Created

- [ ] HP2: `.github/workflows/deploy-qa.yml`
- [ ] SMX: `.github/workflows/deploy-qa.yml`
- [ ] QA branches created in both repos

#### Deployments

- [ ] **HP2 First Deployment**
  - Date: `_______________`
  - Commit SHA: `_________________________`
  - Status: ⬜ Success / ⬜ Failed
  - URL: `_________________________`
  - Notes: _________________________

- [ ] **SMX First Deployment**
  - Date: `_______________`
  - Commit SHA: `_________________________`
  - Status: ⬜ Success / ⬜ Failed
  - URL: `_________________________`
  - Notes: _________________________

#### Custom Domains

- [ ] **HP2 Custom Domain**
  - Domain: `hp2-qa.recalibratex.net`
  - DNS configured: ⬜
  - Certificate bound: ⬜
  - HTTPS working: ⬜

- [ ] **SMX Custom Domain**
  - Domain: `smx-qa.recalibratex.net`
  - DNS configured: ⬜
  - Certificate bound: ⬜
  - HTTPS working: ⬜

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

### Phase 7: Security and Compliance

**Date Started:** _______________  
**Date Completed:** _______________  
**Status:** ⬜

#### Security Review

- [ ] Identity and access management reviewed
- [ ] Data protection verified
- [ ] Network security assessed
- [ ] Monitoring and logging verified
- [ ] Vulnerability management assessed

#### Compliance

- [ ] HIPAA requirements documented
- [ ] PCI-DSS strategy defined
- [ ] Security policies drafted
- [ ] Incident response plan drafted
- [ ] Disaster recovery plan drafted

#### Action Items Identified

- [ ] Complete HIPAA policy documentation
- [ ] Sign BAA with Microsoft Azure
- [ ] Configure security alerts
- [ ] Implement container image scanning
- [ ] Schedule penetration testing

#### Issues Encountered

_Document any issues here..._

#### Lessons Learned

_Document lessons learned..._

---

## 🎉 QA Environment Launch

**QA Launch Date:** _______________

### Final Checklist

- [ ] HP2 QA application deployed and accessible
- [ ] SMX QA application deployed and accessible
- [ ] Authentication working (B2C with MFA)
- [ ] Database connectivity verified
- [ ] Custom domains working with HTTPS
- [ ] Monitoring and logging operational
- [ ] CI/CD pipeline functional
- [ ] Security review complete

### QA Environment URLs

- **HP2 QA:** `_________________________`
- **SMX QA:** `_________________________`

### Known Issues

_List any known issues that are not blockers..._

### Next Steps

- [ ] Begin user acceptance testing
- [ ] Monitor for issues
- [ ] Iterate based on feedback
- [ ] Plan production deployment

---

## 📊 Key Metrics

### Deployment Metrics

- **Total Time to Complete QA Setup:** _____ hours/days
- **Number of Issues Encountered:** _____
- **Number of Deployments:** _____
- **Average Deployment Time:** _____ minutes

### Cost Tracking

| Month | QA Environment Cost | Notes |
|-------|---------------------|-------|
| October 2025 | $_______ | Initial deployment |
| November 2025 | $_______ | |
| December 2025 | $_______ | |

---

## 💡 Lessons Learned (Summary)

### What Went Well

1. _Add positive learnings..._
2. 
3. 

### Challenges Faced

1. _Add challenges..._
2. 
3. 

### Improvements for Production

1. _Add improvement ideas..._
2. 
3. 

---

## 📞 Key Contacts

| Role | Name | Contact | Notes |
|------|------|---------|-------|
| Project Lead / Admin | Ron | | Domain Admin |
| Microsoft Support | | | |
| GitHub Support | | | |

---

## 🔗 Important Links

### Azure Portals
- Main Portal: https://portal.azure.com
- B2C QA Tenant: https://portal.azure.com/<tenant-id>
- Database Tenant: https://portal.azure.com/<tenant-id>

### GitHub Repositories
- HP2: https://github.com/vokworks-ronk/hp225
- SMX: https://github.com/vokworks-ronk/smx25

### Application URLs
- HP2 Dev: https://hp2-dev.recalibratex.net
- SMX Dev: https://smx-dev.recalibratex.net
- HP2 QA: _To be filled_
- SMX QA: _To be filled_

### Documentation
- Project Overview: `00-project-overview.md`
- Architecture Doc: `notions.md`

---

## 📝 Daily Notes

Use this section for quick daily notes during deployment:

### 2025-11-11
**Phase 3 Database Tenant Complete!**
- Created 4 DBA user accounts (icelerasys, mmcguirk, dtuck, bscott)
- Added Ron's B2B guest account to admin groups (5 total admins)
- Created 3 service principals for application database access
- Configured database-level users with R/W/X permissions in all 5 databases
- Tested SSMS connectivity with icelerasys account - SUCCESS!
- Service principal credentials generated and saved securely
- All Phase 3 infrastructure operational and ready for Phase 5 Container Apps

### 2025-11-06 to 2025-11-11
**Azure Capacity Crisis and Resolution**
- Encountered widespread "RegionDoesNotAllowProvisioning" errors
- Submitted Azure support ticket - received poor assistance
- User implemented workaround: delete resource groups, wait 1 hour, recreate
- Breakthrough: All 3 SQL servers created successfully in East US 2
- Rapidly completed all databases, firewall rules, audit logging, Microsoft Defender
- Updated all documentation to reflect completion

### 2025-11-05 to 2025-11-06
**CIAM Tenant Issue Discovery and Rebuild**
- Discovered original rhcdb tenant was CIAM type (incompatible with SQL Server)
- Made decision to completely rebuild with new workforce tenant
- Created rhcdbase.onmicrosoft.com tenant (AAD workforce type)
- Created new subs-rhcdbase subscription
- Cancelled old rhcdb tenant and subscription
- Documented rebuild process in rebuildDBserver.md

### 2025-11-05
**Phase 1 & 2 Complete**
- Created rhcqa.onmicrosoft.com (External ID tenant)
- Created rhcprod.onmicrosoft.com (External ID tenant)
- Created rhcdb.onmicrosoft.com (later discovered to be CIAM - deprecated)
- Created subscriptions for all tenants
- Linked billing to central account

---

## ✅ Sign-Off

### QA Environment Ready for Testing

**Date:** _______________  
**Signed by:** Ron  
**Status:** ⬜ Ready / ⬜ Not Ready

**Notes:**
_Add any final notes before declaring QA ready..._

---

### Production Readiness (Future)

**Date:** _______________  
**Signed by:** Ron  
**Status:** ⬜ Ready / ⬜ Not Ready

**Notes:**
_To be filled when production deployment begins..._

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Status:** 📝 Active Logging Document
