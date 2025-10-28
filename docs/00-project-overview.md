# 🏥 Recalibrate Healthcare - Multi-Tenant B2C Deployment Project

## 📋 Project Overview

**Project Name:** Recalibrate Healthcare QA/Production Deployment  
**Organization:** Recalibrate Healthcare  
**Project Lead:** Ron (Domain Admin)  
**Target:** Deploy HP2 and SMX applications to QA environment THIS WEEK  
**Date Started:** October 27, 2025

---

## 🎯 Business Context

### Applications

#### **HP2 - Healthcare Practice Management Application**
- **Purpose:** Medical practice management app for healthcare providers
- **Users:** Healthcare practices (B2C customers)
- **Function:** Manage patients, practice operations
- **Note:** Patients themselves do NOT use the app
- **Usage Pattern:** Users pop in/out, not all-day usage
- **Future:** Will integrate with customer practice management systems

#### **SMX - Staff Management Application**
- **Purpose:** Internal staff tool to support HP2 customers
- **Users:** Recalibrate Healthcare internal staff
- **Function:** Customer support, management, administration

### User Scale Estimates

| Metric | Launch | Year 1 | Year 5 |
|--------|--------|--------|--------|
| **HP2 Practices** | 5-10 | 50-100 | TBD (growth dependent) |
| **Users per Practice** | 1-3 back office staff | 1-3 | 1-3 |
| **Total HP2 Users** | 5-30 | 50-300 | TBD |
| **SMX Staff Users** | < 6 | ~12 | TBD |

### Multi-Location Support
- Practices can have multiple locations
- Internal staff (SMX) creates first practice user via email invitation
- Practice admin self-provisions additional users as needed

---

## 🏢 Current Infrastructure

### Existing Tenants

#### **Back Office Tenant (Primary)**
- **Name:** RECALIBRATEHEALTHC
- **Domain:** `recalibratehealthcare.com`
- **Tenant ID:** `ed01df5d-6b39-45f8-82ae-36b88e5daae0`
- **Type:** Microsoft Entra ID (Workforce)
- **Purpose:** Internal operations, Office 365, billing
- **Users:** Ron + a couple Office 365 users
- **Resources:** 
  - Subscription: "Azure subscription 1"
  - VM: `web-2310a` (marketing website in "marketing" RG - East US)
  - **Status:** LEAVE ALONE - unrelated to B2C apps

#### **Dev B2C Tenant (Existing)**
- **Name:** smx25dev
- **Domain:** `smx25dev.onmicrosoft.com`
- **Tenant ID:** `cd21a3bf-622c-4725-8da7-2f8b9d265d14`
- **Type:** Microsoft Entra ID B2C
- **Purpose:** Development environment for HP2 and SMX
- **Status:** Active - both apps currently running here
- **Resources:** See resource groups below

#### **Dev Database Tenant (Existing)**
- **Domain:** `vokworks.onmicrosoft.com`
- **Type:** Microsoft Entra ID (Workforce)
- **Purpose:** Current development databases
- **Status:** Active - will remain for dev only
- **Note:** Separate tenant from dev apps

#### **Other Tenants (Ignore)**
- `core25a.onmicrosoft.com`
- `unwashedmasses.onmicrosoft.com`
- `unwashedmasses2.onmicrosoft.com`
- These are for other projects - not related to this deployment

---

## 🔧 Current Development Environment

### Dev Applications

#### **HP2 Dev**
- **URL:** `https://hp2-dev.recalibratex.net` ✓ (active)
- **Resource Group:** `hp225dev-rg` (East US 2)
- **Tenant:** `smx25dev.onmicrosoft.com`
- **Services:**
  - Container App: `hp225dev-app`
  - Container Apps Environment: `hp225dev-env`
  - Key Vault: `hp225dev-kv`
  - Application Insights: `hp225dev-insights`
  - Log Analytics: `hp225dev-logsworkspace`
  - Email Communication Services: `hp225dev-email-services`
  - Communication Services: `hp225dev-comms`, `hp225dev-communication-services`

#### **SMX Dev**
- **URL:** `https://smx-dev.recalibratex.net` ✓ (active)
- **Resource Group:** `smx25dev-rg` (East US 2)
- **Tenant:** `smx25dev.onmicrosoft.com`
- **Services:**
  - Container App: `smx25dev-app`
  - Container Apps Environment: `smx25dev-env`
  - Container Registry: `smx25devacr`
  - Storage: `smx25devstorage`
  - Key Vault: `smx25dev-kv`
  - Application Insights: `smx25dev-insights`
  - Email Communication Services: `smx25dev-email`
  - Communication Services: `smx25dev-comms`
  - Managed Domain: `AzureManagedDomain (smx25dev-email/AzureManagedDomain)`

### Dev Databases

#### **SQL Server**
- **Name:** `smxcore-sqlsvr.database.windows.net`
- **Location:** East US
- **Tenant:** `vokworks.onmicrosoft.com`
- **Resource Group:** `smxCore-rg`
- **Subscription:** `subs-vokworks`
- **Tier:** Azure SQL Database (Standard S0: 10 DTUs)
- **Authentication:** Microsoft Entra admin configured

#### **Databases**
1. **`smxcore_corp_db`** (Corporate/Shared Database)
   - Used by: SMX (primary), HP2 (read access)
   - Tier: Standard S0 (10 DTUs)
   
2. **`smxcore_hp2_db`** (HP2 Primary Database)
   - Used by: HP2 (primary)
   - Tier: Standard S0 (10 DTUs)
   
3. **`smxcore_hm2_db`** (Unknown/Unused?)
   - Tier: Standard S0 (10 DTUs)

#### **Current Database Authentication**
- ⚠️ Using SQL authentication (username/password)
- ⚠️ INSECURE - needs to change to Managed Identity or Service Principal
- Target: Implement secure authentication in QA

---

## 🎯 Target Architecture

### New Tenants to Create

> **Note:** As of May 1, 2025, Azure AD B2C is no longer available for new customers. We're using **Microsoft Entra External ID** instead, which is the modern replacement with enhanced features.

#### **1. QA Tenant (External ID)**
- **Domain:** `rhcqa.onmicrosoft.com`
- **Type:** Microsoft Entra External ID (or Workforce with External ID features)
- **Purpose:** QA/testing environment for HP2 and SMX
- **Custom Domains:** 
  - `hp2-qa.recalibratex.net`
  - `smx-qa.recalibratex.net`
- **Access:** External identities (customer users)
- **Status:** TO BE CREATED

#### **2. Production Tenant (External ID)**
- **Domain:** `rhcprod.onmicrosoft.com`
- **Type:** Microsoft Entra External ID (or Workforce with External ID features)
- **Purpose:** Production environment for HP2 and SMX
- **Custom Domains:** 
  - `hp2.recalibratex.net`
  - `smx.recalibratex.net`
- **Access:** External identities (customer users)
- **Status:** TO BE CREATED (after QA is stable)

#### **3. Database Tenant**
- **Domain:** `rhcdbcore.onmicrosoft.com`
- **Type:** Microsoft Entra ID (Workforce)
- **Purpose:** Isolated tenant for QA and Production databases
- **Access:** Restricted to IT accounts and service principals ONLY
- **Security:** No external identities or app registrations permitted
- **Status:** TO BE CREATED

### Target QA Environment

#### **QA Applications**

**HP2 QA**
- **URL:** `https://hp2-qa.recalibratex.net`
- **Resource Group:** `rhc-hp2-qa-rg` (to be created)
- **Tenant:** `rhc-b2c-qa.onmicrosoft.com`
- **Services:** Mirror HP2 dev stack

**SMX QA**
- **URL:** `https://smx-qa.recalibratex.net`
- **Resource Group:** `rhc-smx-qa-rg` (to be created)
- **Tenant:** `rhc-b2c-qa.onmicrosoft.com`
- **Services:** Mirror SMX dev stack

#### **QA Databases**

**SQL Server:** `rhc-qa-sqlsvr.database.windows.net` (to be created)
- **Location:** East US 2
- **Tenant:** `rhcdbcore.onmicrosoft.com`
- **Resource Group:** `rhc-db-qa-rg`
- **Tier:** Azure SQL Database (Standard S0: 10 DTUs)
- **Authentication:** Managed Identity or Service Principal (SECURE)

**Databases:**
1. `corp_db` (Corporate/Shared)
2. `hp2_db` (HP2 Primary)

#### **Database Usage Pattern (QA)**
- SMX QA → `corp_db`
- HP2 QA → `corp_db` (read) + `hp2_db` (read/write)

---

## 🔐 Security & Compliance Requirements

### Authentication & Identity

#### **HP2 Users (Healthcare Practices)**
- ✅ **Invitation-only** - Email invitation to sign up
- ✅ **Email/password** authentication
- ✅ **MFA required** - Enforced via B2C policy
- ❌ No social logins (Google, Facebook, etc.)
- ❌ No SAML/SSO (not initially, may add later for enterprise customers)

#### **SMX Users (Internal Staff)**
- ✅ Authenticate via **B2C tenant** (not back office tenant)
- ✅ **MFA required** - Enforced via B2C policy
- ✅ **Invitation-only** - Managed by Ron/IT

#### **Database Access**
- ❌ **NO SQL authentication** (username/password)
- ✅ **Managed Identity** (preferred)
- ✅ **Service Principal** (alternative)
- ✅ Cross-tenant access from B2C tenant to Database tenant

### Compliance Requirements

#### **HIPAA Compliance**
- **HP2:** ✅ Required (handles patient data)
- **SMX:** ⚠️ Possibly required (handles customer data that may include PHI)
- **Requirements:**
  - Encrypted data in transit and at rest
  - Audit logging for all data access
  - Access controls and MFA
  - Business Associate Agreements (BAAs) with Microsoft

#### **PCI-DSS Compliance**
- **Both HP2 and SMX:** ✅ May process credit cards
- **Strategy:** Use payment gateway (Stripe, Square, Authorize.net)
- **DO NOT** store credit card data directly
- If storing card data: Azure Payment HSM required

#### **Best Practices**
- ✅ Maximum security posture
- ✅ Principle of least privilege
- ✅ Network isolation where possible
- ✅ Encryption everywhere
- ✅ Comprehensive audit logging
- ✅ Regular security reviews

---

## 🔗 GitHub & CI/CD

### GitHub Repositories

**Account:** `vokworks-ronk` (personal, no organization)  
**Visibility:** All repos private

1. **HP2 Repository**
   - **Name:** `hp225`
   - **URL:** `https://github.com/vokworks-ronk/hp225`
   - **Status:** ✅ CI/CD to dev already working

2. **SMX Repository**
   - **Name:** `smx25`
   - **URL:** `https://github.com/vokworks-ronk/smx25`
   - **Status:** ✅ CI/CD to dev already working

### Deployment Strategy

- **Dev:** ✅ Already automated via GitHub Actions
- **QA:** 🚀 Need to create GitHub Actions workflows THIS WEEK
- **Production:** ⏳ Will create after QA is stable

**Deployment Target:** Azure Container Apps (all environments)

---

## 💰 Subscription & Billing Strategy

### Current Subscriptions
- **Back Office Tenant:** "Azure subscription 1" (existing)
- **Dev B2C Tenant:** Uses "subs-smx25dev" (inferred)
- **Dev Database Tenant:** "subs-vokworks" (existing)

### New Subscriptions Needed

All subscriptions will be linked to **central billing account** under existing Office 365 tenant (`recalibratehealthcare.com`)

| Tenant | Subscription Name | Purpose |
|--------|-------------------|---------|
| `rhc-b2c-qa.onmicrosoft.com` | `rhc-b2c-qa-sub` | QA environment resources |
| `rhc-b2c-prod.onmicrosoft.com` | `rhc-b2c-prod-sub` | Production environment resources |
| `rhcdbcore.onmicrosoft.com` | `rhc-db-core-sub` | Database resources (QA & Prod) |

**Benefits:**
- Cost isolation and tracking per environment
- Security isolation between environments
- Separate billing for each tenant/environment

---

## 📅 Timeline & Milestones

### Phase 1: QA Deployment (THIS WEEK) 🚀
**Target:** Week of October 27, 2025

- [ ] Create 3 new tenants (manual via Portal)
- [ ] Create and link subscriptions
- [ ] Set up Database tenant with QA SQL Server and databases
- [ ] Configure B2C QA tenant with user flows and MFA
- [ ] Create HP2 and SMX resource groups and services in QA
- [ ] Configure Managed Identity/Service Principal for database access
- [ ] Update GitHub Actions for QA deployment
- [ ] Deploy HP2 to QA
- [ ] Deploy SMX to QA
- [ ] Configure custom domains
- [ ] Test end-to-end (authentication, database, app functionality)
- [ ] Document configurations and secrets

### Phase 2: Production Deployment (Several Weeks After QA)
**Target:** TBD after QA is stable

- [ ] Validate QA is stable and secure
- [ ] Create production databases in Database tenant
- [ ] Create HP2 and SMX resource groups and services in Production
- [ ] Configure production-grade settings (scaling, monitoring, alerts)
- [ ] Set up GitHub Actions for production deployment
- [ ] Deploy HP2 to Production
- [ ] Deploy SMX to Production
- [ ] Configure custom domains for production
- [ ] Perform security audit
- [ ] Load testing
- [ ] Go-live checklist
- [ ] Customer onboarding process

### Phase 3: Post-Production (Future)
- [ ] Monitor and optimize
- [ ] Scale SQL tier if needed
- [ ] Consider SQL Managed Instance migration (if DBA replication needed)
- [ ] Integration with customer practice management systems
- [ ] Enterprise features (SAML/SSO for large customers)

---

## 🔧 Automation Preferences

### Tooling Priority (Ron's Preference)

1. **Microsoft Graph** (preferred - future-proof, willing to retry)
2. **Azure CLI** (liked and familiar)
3. **PowerShell** (fallback)
4. **Azure Portal GUI** (manual fallback - least reproducible)

### Script Organization

All scripts will be provided in documentation with:
- Graph API examples (preferred)
- Azure CLI alternatives
- PowerShell alternatives
- Manual Portal steps as fallback

Scripts will be **idempotent** where possible (safe to run multiple times).

---

## 📚 Documentation Structure

This project uses a phased documentation approach:

1. **`00-project-overview.md`** (this file) - Complete project context
2. **`01-tenant-creation.md`** - Creating the 3 new tenants
3. **`02-subscription-setup.md`** - Subscriptions and billing
4. **`03-database-tenant-setup.md`** - Database tenant and SQL resources
5. **`04-b2c-tenant-setup.md`** - B2C configuration, user flows, MFA
6. **`05-resource-groups-and-services.md`** - HP2 and SMX service stacks
7. **`06-github-actions-qa.md`** - CI/CD pipelines for QA
8. **`07-security-and-compliance.md`** - HIPAA, PCI-DSS, security baseline
9. **`08-production-deployment.md`** - Production deployment (future)
10. **`deployment-log.md`** - Running log of completed work

Each document contains:
- ✅ Markdown checklists for progress tracking
- 📜 Scripts (Graph, CLI, PowerShell)
- 📖 Step-by-step instructions
- ⚙️ Configuration details
- 🔐 Security considerations

---

## 🎯 Success Criteria

### QA Environment Success
- [ ] Both HP2 and SMX deployed and accessible at custom domains
- [ ] Users can authenticate with email/password + MFA
- [ ] Apps can connect to databases using Managed Identity (not SQL auth)
- [ ] GitHub Actions automatically deploy on push to QA branch
- [ ] All services running in correct resource groups/tenants
- [ ] Audit logging enabled
- [ ] No security warnings or misconfigurations

### Production Ready
- [ ] QA stable for several weeks
- [ ] Security audit completed
- [ ] Load testing completed
- [ ] Monitoring and alerting configured
- [ ] Backup and disaster recovery plan documented
- [ ] Customer onboarding process defined
- [ ] Compliance documentation completed (HIPAA BAA, etc.)

---

## 👥 Team & Roles

**Ron (You)**
- Domain Administrator
- Global Admin on all tenants
- Primary deployer and implementer
- Decision maker

**GitHub Copilot (Me)**
- Technical guidance
- Documentation
- Script generation
- Problem solving

**Team Size:** Just the two of us! 💪

---

## 📝 Notes & Decisions

### Key Decisions Made

1. ✅ **Azure SQL Database** (not Managed Instance) for QA and Production initially
2. ✅ **Standard S0 tier** to start (can scale up later)
3. ✅ **Managed Identity** for database authentication (preferred over Service Principal)
4. ✅ **Container Apps** for all environments
5. ✅ **Invitation-only** user provisioning
6. ✅ **MFA required** for all users
7. ✅ **Separate resource groups** for HP2 and SMX in each environment
8. ✅ **Payment gateway** approach for credit cards (no direct storage)
9. ✅ **Empty databases** for QA (DBAs will populate data separately)

### Future Considerations

- Migration to SQL Managed Instance if DBA replication workflows needed
- SAML/SSO for enterprise customers
- Additional social login providers
- Integration APIs for practice management systems
- Advanced monitoring and analytics
- Disaster recovery and high availability
- Multi-region deployment

---

## 🚀 Let's Get Started!

This document captures all requirements and context. Now let's execute!

**Next Step:** Review `01-tenant-creation.md` to create the three new tenants.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Status:** ✅ Complete - Ready for execution
