# HP2 QA Deployment Progress

**Started:** November 15, 2025  
**Target Completion:** TBD  
**Status:** In Progress

---

## Deployment Chunks Overview

| Chunk | Task | Time Est. | Status | Completed |
|-------|------|-----------|--------|-----------|
| 0 | Infrastructure Setup | - | ✅ Complete | Pre-done |
| 1 | Database Setup | 15 min | ✅ Complete | Pre-done |
| 2 | Communication Services | 10 min | ⬜ Not Started | - |
| 3 | Environment Configuration | 10 min | ✅ Complete | Nov 15 |
| 4 | Deploy HP2 Code | 15 min | ✅ Complete | Nov 15 |
| 5 | Verification & Custom Domain | 20 min | ⬜ Not Started | - |

**Total Estimated Time:** ~70 minutes

---

## ✅ Chunk 0: Infrastructure Setup (COMPLETE)

**What was done:**
- ✅ Resource group created: `rhc-hp2-qa-rg`
- ✅ Container App created: `rhc-hp2-qa-app` (running hello-world placeholder)
- ✅ Container Environment: `rhc-hp2-qa-env`
- ✅ Container Registry: `rhchp2qaacr`
- ✅ Key Vault: `rhc-hp2-qa-kv-2025`
- ✅ Storage Account: `rhchp2qastorage`
- ✅ Application Insights: `rhc-hp2-qa-insights`
- ✅ Log Analytics: `rhc-hp2-qa-logs`
- ✅ App Registration in CIAM tenant (cfdc3d4b-dfe3-4414-a09d-a11a568187de)

**Current State:**
- Container App Status: Running (hello-world image)
- Latest Revision: `rhc-hp2-qa-app--zmzzyrb`

---

## ✅ Chunk 1: Database Setup (COMPLETE)

**Goal:** Create HP2-specific database and configure access

### Tasks:
- [X] Create `qa_hp2_db` database on `rhcdb-qa-sqlsvr.database.windows.net`
- [X] Grant service principal access to `qa_hp2_db`
- [X] Database user created: `db-qa-sqlsvr-app-users` (Read/Write/Execute)

### Commands to Run:

```bash
# Create HP2 database
az sql db create \
  --resource-group "rhcdb-qa-rg" \
  --server "rhcdb-qa-sqlsvr" \
  --name "qa_hp2_db" \
  --tier Standard \
  --capacity 10 \
  --zone-redundant false \
  --backup-storage-redundancy Local

# Grant service principal access (after database is created)
# Service Principal: db-qa-app (from Key Vault)
# Run this via SQL query in Azure Portal or via sqlcmd
```

**SQL Grant Command:**
```sql
-- Connect to qa_hp2_db
CREATE USER [db-qa-app] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [db-qa-app];
ALTER ROLE db_datawriter ADD MEMBER [db-qa-app];
ALTER ROLE db_ddladmin ADD MEMBER [db-qa-app];
```

### Verification:
- [X] Database shows "Online" status
- [X] Database user created in all QA databases (qa_corp_db, qa_hp2_db)

### Notes:
**Completed in Phase 3 (Nov 11, 2025)** - Database and access already configured per `03-database-tenant-setup.md`:
- Database: `qa_hp2_db` on `rhcdb-qa-sqlsvr.database.windows.net`
- Tier: Standard S0 (10 DTU)
- Database User: `db-qa-sqlsvr-app-users` with R/W/X permissions
- Service principal credentials stored in Key Vault (`db-qa-app-id`, `db-qa-app-secret`)
- Server located in `db-qa-rg` resource group in **rhcdb tenant** (not QA subscription)

---

## ⬜ Chunk 2: Communication Services

**Goal:** Set up email services for HP2 QA invitations

### Tasks:
- [ ] Create Communication Service: `rhc-hp2-qa-comms`
- [ ] Create Email Service: `rhc-hp2-qa-email`
- [ ] Link Azure Managed Domain to Email Service
- [ ] Link Domain to Communication Service
- [ ] Retrieve connection string
- [ ] Get FromAddress (DoNotReply@xxx.azurecomm.net)

### Commands to Run:

```bash
# Create Communication Service
az communication create \
  --name "rhc-hp2-qa-comms" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates"

# Create Email Service
az communication email create \
  --name "rhc-hp2-qa-email" \
  --resource-group "rhc-hp2-qa-rg" \
  --data-location "UnitedStates"

# Get connection string
az communication list-key \
  --name "rhc-hp2-qa-comms" \
  --resource-group "rhc-hp2-qa-rg" \
  --query primaryConnectionString -o tsv
```

### Values to Capture:
- **Connection String:** `_________________________________`
- **FromAddress:** `DoNotReply@___________________________.azurecomm.net`

### Notes:
<!-- Add any issues or observations here -->

---

## ✅ Chunk 3: Environment Configuration (COMPLETE)

**Goal:** Configure all environment variables for HP2 QA

### Tasks:
- [X] Run complete environment configuration command
- [X] Verify new revision is created
- [X] Check container app status

### Command to Run:

See `QA-CONFIGURATION-REFERENCE.md` - HP2 QA Complete Configuration section

Key variables:
- CIAM authentication config
- Database connections (corp + HP2)
- Communication Services
- Storage
- DataProtection
- Application Insights

### Verification:
- [X] New revision created successfully
- [X] Container app shows "Running" status
- [X] Environment variables visible in portal

### Notes:
**Completed:** November 15, 2025
- **New Revision:** rhc-hp2-qa-app--0000002
- **Status:** Active, Provisioned, 1 replica running
- All environment variables configured successfully:
  - ✅ CIAM authentication (rhcqa tenant)
  - ✅ Database connections (qa_corp_db + qa_hp2_db with service principal auth)
  - ✅ Application Insights
  - ✅ Key Vault URI
  - ✅ Invitation BaseUrl (https://hp2-qa.recalibratex.net)
  - ⚠️ Communication Services connection string set to placeholder (will update after Chunk 2)
- Container app currently running hello-world image (will update in Chunk 4)

---

## ✅ Chunk 4: Deploy HP2 Code (COMPLETE)

**Goal:** Build and deploy HP2 application code

**Completed:** November 15, 2025

### What was accomplished:
- ✅ Created Azure Container Registry: `rhchp2qaacr.azurecr.io`
- ✅ Created GitHub Actions workflow: `.github/workflows/deploy-qa.yml`
- ✅ Created service principal: `github-hp2-qa-deploy`
- ✅ Configured GitHub secret: `AZURE_CREDENTIALS_HP2_QA`
- ✅ Granted ACR permissions (AcrPush to service principal, AcrPull to container app)
- ✅ Configured container app ACR authentication with managed identity
- ✅ Successfully built and deployed HP2 application

### Deployment Details:
- **GitHub Workflow Run**: #19394474556 ✅ Success
- **Docker Image**: `rhchp2qaacr.azurecr.io/hp2-app:build-1`
- **Latest Revision**: `rhc-hp2-qa-app--0000003`
- **Container App Status**: Running
- **App URL**: https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io

### Issues Resolved:
1. ⚠️ ACR didn't exist - created `rhchp2qaacr`
2. ⚠️ Container app couldn't authenticate to ACR - configured managed identity
3. ⚠️ Tag conflict on retry - deleted existing tag

### Next Steps:
- Proceed to Chunk 5: Verification & Custom Domain

---

## ⬜ Chunk 5: Verification & Custom Domain
- **Image Tag:** `_________________________________`
- **Revision:** `_________________________________`

### Notes:
<!-- Add any issues or observations here -->

---

## ⬜ Chunk 5: Verification & Custom Domain

**Goal:** Test functionality and configure custom domain

### Tasks:

#### 5.1 Test Authentication
- [ ] Navigate to app URL
- [ ] Click Sign In
- [ ] Verify redirects to CIAM tenant
- [ ] Sign in with test account
- [ ] Verify redirected back to app

#### 5.2 Test Database Connectivity
- [ ] Navigate to `/system-diags`
- [ ] Verify databases show "Provisioned"
- [ ] Click "Test Database Connectivity"
- [ ] Verify all tests pass

#### 5.3 Configure Custom Domain
```bash
# Add custom domain
az containerapp hostname add \
  --hostname "hp2-qa.recalibratex.net" \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg"

# Bind with managed certificate
az containerapp hostname bind \
  --hostname "hp2-qa.recalibratex.net" \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --environment "rhc-hp2-qa-env" \
  --validation-method CNAME
```

#### 5.4 Update App Registration
- [ ] Go to Azure Portal → Entra ID → App Registrations
- [ ] Find HP2 QA app (cfdc3d4b-dfe3-4414-a09d-a11a568187de)
- [ ] Update Redirect URIs to include `https://hp2-qa.recalibratex.net/signin-oidc`

#### 5.5 Set Scaling Configuration
```bash
# Set to scale to zero for QA (can change to 1 during testing)
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --min-replicas 0 \
  --max-replicas 10
```

### Final Verification Checklist:
- [ ] App accessible at `https://hp2-qa.recalibratex.net`
- [ ] Authentication works
- [ ] Database connectivity confirmed
- [ ] No errors in Application Insights
- [ ] SSL certificate valid
- [ ] Can send invitation emails

### Notes:
<!-- Add any issues or observations here -->

---

## Issues & Resolutions

### Issue #1
**Date:**  
**Problem:**  
**Resolution:**  

---

## Reference Information

### Key Resources
- **Resource Group:** `rhc-hp2-qa-rg`
- **Container App:** `rhc-hp2-qa-app`
- **App URL (default):** https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io
- **App URL (custom):** https://hp2-qa.recalibratex.net
- **Database Server:** rhcdb-qa-sqlsvr.database.windows.net
- **Databases:** qa_corp_db, qa_hp2_db
- **CIAM Tenant:** rhcqa.onmicrosoft.com (2604fd9a-93a6-448e-bdc9-25e3c2d671a2)
- **App Registration ID:** cfdc3d4b-dfe3-4414-a09d-a11a568187de

### Key Vault Secrets
- `hp2-qa-client-secret` - CIAM app secret
- `db-qa-app-id` - Database service principal ID
- `db-qa-app-secret` - Database service principal secret

### Documentation References
- Full config: `docs/QA-CONFIGURATION-REFERENCE.md`
- Infrastructure: `docs/05-resource-groups-and-services.md`
- Custom domains: `docs/CUSTOM-DOMAINS-SETUP.md`
- Scaling: `docs/CONTAINER-APP-SCALING.md`

---

## Next Session Preparation

**When resuming, start with:**
1. Review this document to see what's completed
2. Continue with next incomplete chunk
3. Update status as you go

**Quick status check command:**
```bash
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "{image:properties.template.containers[0].image, revision:properties.latestRevisionName, status:properties.runningStatus}"
```

---

**Last Updated:** November 15, 2025  
**Updated By:** Ron  
**Current Chunk:** Ready to start Chunk 1
