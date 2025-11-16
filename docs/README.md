# RHC Deployment Documentation

**Last Updated:** November 16, 2025

---

## 🚨 CRITICAL PRINCIPLE - READ THIS FIRST

### Before ANY Azure Container App Update:

**ALWAYS backup environment variables BEFORE making changes:**

```powershell
# Backup current state (do this EVERY time before changes)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
az containerapp show `
  --name {app-name} `
  --resource-group {rg-name} `
  --query "properties.template.containers[0].env" `
  -o json > "deployments/{env}/env-vars-backup-$timestamp.json"

# Commit the backup
git add deployments/{env}/
git commit -m "Backup env vars before changes - $timestamp"

# THEN make your changes using --set-env-vars (adds to existing)
# NEVER use --replace-env-vars unless you have a complete backup
```

**Why this matters:**
- Azure Container Apps environment variables are NOT backed up by Azure
- `--replace-env-vars` wipes out ALL existing variables
- Lost configuration can take hours/days to reconstruct
- Git commits provide version history and recovery points

---

## 📁 Folder Structure

```
docs/
├── guides/              # Step-by-step setup guides (read once, reference later)
│   ├── 00-project-overview.md
│   ├── 01-tenant-creation.md
│   ├── 02-subscription-setup.md
│   ├── 03-database-*.md
│   ├── 04-b2c-tenant-setup.md
│   ├── 05-resource-groups-and-services.md
│   ├── 06-github-actions-qa.md
│   └── 07-security-and-compliance.md
│
├── reference/           # Troubleshooting and lookup docs
│   ├── CIAM-AUTHENTICATION-FIX.md
│   ├── CUSTOM-DOMAINS-SETUP.md
│   ├── MONITORING-GUIDE.md
│   ├── ENVIRONMENT_VARIABLES_INVENTORY.md
│   └── ...
│
├── templates/           # Reusable templates for new deployments
│   ├── PRODUCTION-DEPLOYMENT-CHECKLIST.md
│   └── (more templates to be added)
│
└── deployments/         # COMPLETE state for each environment
    ├── smx-dev/
    ├── smx-qa/
    ├── smx-prod/
    ├── hp2-dev/
    ├── hp2-qa/
    └── hp2-prod/
```

---

## 📚 Documentation Overview

This project contains comprehensive documentation for deploying HP2 and SMX applications to secure multi-tenant environments (Dev, QA, Production).

---

## 🎯 Current Deployment Status

### Development Environments
- **SMX Dev** - `smx25dev-app` - ⚠️ Recently recovered from config wipe
- **HP2 Dev** - `hp225dev-app` - Status unknown

### QA Environments  
- **SMX QA** - `rhc-smx-qa-app` - ✅ Working (as of Nov 14, 2025)
- **HP2 QA** - `rhc-hp2-qa-app` - ⏳ Partially configured

### Production Environments
- **SMX Prod** - ⏳ Not yet deployed
- **HP2 Prod** - ⏳ Not yet deployed

---

## ⚡ Quick Start

### For New Deployments
1. **Copy template**: Use `templates/PRODUCTION-DEPLOYMENT-CHECKLIST.md`
2. **Create deployment folder**: `deployments/{app}-{env}/`
3. **Backup BEFORE changes**: Use script above (in CRITICAL PRINCIPLE)
4. **Document as you go**: Update deployment folder with actual values
5. **Commit frequently**: Git is your safety net

### For Initial Setup

### Document Index

| # | Document | Purpose | Status |
|---|----------|---------|--------|
| 0 | `00-project-overview.md` | Complete project context, requirements, architecture | ✅ Complete |
| 1 | `01-tenant-creation.md` | Create 3 new Azure tenants (manual process) | 🚀 Ready |
| 2 | `02-subscription-setup.md` | Create and link subscriptions | ⏳ After Phase 1 |
| 3 | `03-database-tenant-setup.md` | Set up SQL servers and databases | ⏳ After Phases 1-2 |
| 4 | `04-b2c-tenant-setup.md` | Configure B2C authentication, MFA, user flows | ⏳ After Phase 1 |
| 5 | `05-resource-groups-and-services.md` | Create all Azure resources for apps | ⏳ After Phases 1-4 |
| 6 | `06-github-actions-qa.md` | Set up CI/CD pipelines | ⏳ After Phase 5 |
| 7 | `07-security-and-compliance.md` | Security review and compliance (HIPAA, PCI-DSS) | ✅ Reference |
| - | `deployment-log.md` | Track progress, issues, and decisions | 📝 Active |
| - | `notions.md` | Original architecture document | 📖 Reference |

---

## ⚡ Quick Start

### Step 1: Read the Overview

Start here to understand the full project context:

```
📄 Read: 00-project-overview.md
```

This document contains:
- Business context (HP2 and SMX applications)
- Current infrastructure
- Target architecture
- User requirements
- Security requirements
- Success criteria

### Step 2: Begin Phase 1

Create the three new Azure tenants:

```
📄 Follow: 01-tenant-creation.md
📝 Update: deployment-log.md (as you go)
```

**Time:** 45-60 minutes (manual process)  
**Result:** 3 new tenants created

### Step 3: Continue Through Phases

Work through each phase sequentially:

```
Phase 2 → 3 → 4 → 5 → 6 → 7
```

Each document contains:
- ✅ Checklists
- 📜 Scripts (Microsoft Graph, Azure CLI, PowerShell)
- 📖 Step-by-step instructions
- ⚠️ Troubleshooting tips
- 🔍 Verification steps

### Step 4: Track Your Progress

Keep the deployment log updated:

```
📝 Update: deployment-log.md
```

Fill in:
- Tenant IDs
- Subscription IDs
- Resource names
- Issues encountered
- Lessons learned

---

## 🎯 Project Goals

### Primary Goal: QA Environment THIS WEEK

Deploy HP2 and SMX to fully functional QA environment:
- ✅ Separate from dev
- ✅ Secure authentication (B2C + MFA)
- ✅ Isolated databases
- ✅ Automated deployment (GitHub Actions)
- ✅ Custom domains with HTTPS
- ✅ Monitoring and logging

### Secondary Goal: Production Ready

Set foundation for production deployment:
- ✅ Security best practices
- ✅ HIPAA compliance groundwork
- ✅ Scalable architecture
- ✅ Automated processes

---

## 🏗️ Architecture Summary

### Multi-Tenant Design

```
┌─────────────────────────────────────────────────────────────┐
│                    Back Office Tenant                        │
│              recalibratehealthcare.com                       │
│         (Billing, Office 365, Existing Website)              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  B2C QA Tenant (NEW)                         │
│              rhc-b2c-qa.onmicrosoft.com                      │
│                                                               │
│  ┌───────────────────┐        ┌───────────────────┐         │
│  │   HP2 QA App      │        │   SMX QA App      │         │
│  │ Container App     │        │ Container App     │         │
│  └───────────────────┘        └───────────────────┘         │
│                                                               │
│  • User authentication (B2C + MFA)                           │
│  • Application hosting                                       │
│  • Managed Identity for database access                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│               Database Tenant (NEW)                          │
│              rhcdbcore.onmicrosoft.com                     │
│                                                               │
│  ┌───────────────────────────────────────────────┐          │
│  │   QA SQL Server                                │          │
│  │   ├── corp_db (shared)                         │          │
│  │   └── hp2_db (HP2-specific)                    │          │
│  └───────────────────────────────────────────────┘          │
│                                                               │
│  • Isolated from B2C tenants                                 │
│  • Entra-only authentication                                 │
│  • No SQL authentication                                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              B2C Production Tenant (FUTURE)                  │
│            rhc-b2c-prod.onmicrosoft.com                      │
│         (Production apps will deploy here later)             │
└─────────────────────────────────────────────────────────────┘
```

### Security Model

- **No direct trust** between B2C and Database tenants
- **Managed Identity** for secure cross-tenant access
- **MFA required** for all users
- **Entra-only** authentication (no SQL logins)
- **Secrets in Key Vault** (never in code)
- **Audit everything** (comprehensive logging)

---

## 📋 Prerequisites

### Access Requirements

- ✅ Global Administrator access to `recalibratehealthcare.com`
- ✅ Ability to create new Azure tenants
- ✅ Access to GitHub repositories:
  - `vokworks-ronk/hp225` (HP2)
  - `vokworks-ronk/smx25` (SMX)

### Knowledge Requirements

- Basic Azure portal navigation
- Understanding of tenants and subscriptions
- Familiarity with B2C authentication concepts
- Basic SQL knowledge
- GitHub Actions basics (or willingness to learn)

### Tools Needed

- Web browser (for Azure Portal)
- PowerShell or Azure CLI (optional, for automation)
- SQL client (Azure Data Studio or SSMS) for database setup
- Git (for repository management)

---

## 💰 Expected Costs

### QA Environment (Monthly)

**Compute:**
- Container Apps (2 apps, minimal scale): ~$50-100/month
- Container Registry: ~$5/month

**Databases:**
- Azure SQL (2 databases, S0 tier): ~$30/month

**Networking & Storage:**
- Log Analytics: ~$10-20/month
- Storage: ~$5/month
- Communication Services: Pay-per-use (~$10/month)

**Total Estimated:** ~$100-200/month for QA

**Note:** Costs will increase for production with higher tiers and scale.

---

## 🛠️ Automation Approach

This documentation provides three automation options:

### 1. Microsoft Graph API (Preferred)
- Most modern approach
- Future-proof
- Best for full automation

### 2. Azure CLI
- Cross-platform
- Well-documented
- Good balance of power and simplicity

### 3. PowerShell
- Native to Windows
- Mature and stable
- Good for Windows-centric environments

### 4. Azure Portal (Fallback)
- Manual but visual
- Good for learning
- Step-by-step instructions provided

**Recommendation:** Try Graph first, fall back to CLI or Portal as needed.

---

## ⚠️ Important Notes

### Tenant Creation
- **MUST be done manually** via Azure Portal
- No API/CLI option available
- Takes 5-10 minutes per tenant

### Custom Domains
- Requires DNS configuration
- Allow 15-30 minutes for propagation
- HTTPS certificates auto-generated by Azure

### Database Access
- Managed Identity is preferred over Service Principals
- Must configure from both sides (B2C tenant and Database tenant)
- Test connectivity before deploying apps

### GitHub Actions
- Requires secrets configuration
- Service principal needs proper permissions
- Test with small change first

---

## 🎓 Learning Resources

### Azure Fundamentals
- Azure Portal: https://portal.azure.com
- Azure Documentation: https://docs.microsoft.com/azure
- Azure CLI Reference: https://docs.microsoft.com/cli/azure

### B2C Authentication
- Azure AD B2C Overview: https://docs.microsoft.com/azure/active-directory-b2c
- User Flows: https://docs.microsoft.com/azure/active-directory-b2c/user-flow-overview
- Custom Policies: https://docs.microsoft.com/azure/active-directory-b2c/custom-policy-overview

### Security & Compliance
- Azure Security: https://docs.microsoft.com/azure/security
- HIPAA on Azure: https://docs.microsoft.com/azure/compliance/offerings/offering-hipaa-us
- PCI-DSS: https://www.pcisecuritystandards.org

### Container Apps
- Container Apps Docs: https://docs.microsoft.com/azure/container-apps
- Managed Identity: https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources

---

## 🤝 Getting Help

### During Deployment

1. **Check troubleshooting section** in each phase document
2. **Review deployment log** for similar issues
3. **Search Azure docs** for specific errors
4. **Use GitHub Copilot** for code/script questions
5. **Contact Microsoft Support** for Azure-specific issues

### Common Issues

Most issues fall into these categories:
- **Permissions:** Verify Global Admin access
- **DNS:** Allow time for propagation
- **Secrets:** Double-check values in Key Vault
- **Networking:** Check firewall rules and NSGs

---

## ✅ Success Criteria

### QA Environment Is Ready When:

- [ ] HP2 accessible at `https://hp2-qa.recalibratex.net`
- [ ] SMX accessible at `https://smx-qa.recalibratex.net`
- [ ] Users can sign in with MFA
- [ ] Apps can connect to databases
- [ ] GitHub Actions deploy automatically
- [ ] Monitoring shows healthy state
- [ ] No critical security warnings

---

## 🚀 Let's Get Started!

You're ready to begin! Here's your checklist:

### Right Now
- [x] Review this Quick Start Guide
- [ ] Read `00-project-overview.md` (10 minutes)
- [ ] Open `01-tenant-creation.md` (start Phase 1)
- [ ] Open `deployment-log.md` (prepare to log)

### Today
- [ ] Complete Phase 1 (tenant creation)
- [ ] Complete Phase 2 (subscriptions)
- [ ] Start Phase 3 (databases)

### This Week
- [ ] Complete Phases 3-6
- [ ] Deploy HP2 to QA
- [ ] Deploy SMX to QA
- [ ] Verify everything works end-to-end

---

## 📞 Need Help?

Ask questions as you go! Document issues in `deployment-log.md` so we can troubleshoot together.

**You've got this!** 💪

The documentation is comprehensive, and we'll work through any issues that come up.

---

**Good luck with the deployment!** 🎉

---

**Document Version:** 1.0  
**Created:** October 27, 2025  
**Status:** ✅ Ready to Use
