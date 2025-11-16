# Environment Variables Inventory - All Three Apps

**Created**: October 6, 2025  
**Status**: ✅ Complete Inventory  
**Apps Analyzed**: smx25dev, hp225dev, core25a

---

## 📊 Complete Inventory

### **smx25dev-app** (Tenant A: cd21a3bf-622c-4725-8da7-2f8b9d265d14)

#### Authentication Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `EntraExternalId__ClientId` | Value | `eb3ed853-...` | ✅ Correct prefix |
| `EntraExternalId__TenantId` | Value | `cd21a3bf-...` | ✅ Correct prefix |
| `EntraExternalId__Instance` | Value | `https://smx25dev.ciamlogin.com/` | ✅ Correct prefix |
| `EntraExternalId__Domain` | Value | `smx25dev.onmicrosoft.com` | ✅ Correct prefix |
| `EntraExternalId__ClientSecret` | **Secret** | `graph-api-client-secret` | ✅ Using secret ref |
| `GraphApi__ClientId` | Value | `eb3ed853-...` | ⚠️ Duplicate - same as EntraExternalId |
| `GraphApi__TenantId` | Value | `cd21a3bf-...` | ⚠️ Duplicate - same as EntraExternalId |
| `GraphApi__ClientSecret` | **Secret** | `graph-api-client-secret` | ⚠️ Duplicate - same as EntraExternalId |
| `AzureAd__ClientId` | Value | `eb3ed853-...` | ❌ DEPRECATED - use EntraExternalId |
| `AzureAd__TenantId` | Value | `cd21a3bf-...` | ❌ DEPRECATED - use EntraExternalId |
| `AzureAd__ClientSecret` | **Secret** | `graph-api-client-secret` | ❌ DEPRECATED - use EntraExternalId |

**Issues:**
- ❌ Three different prefixes for same values: `EntraExternalId__`, `GraphApi__`, `AzureAd__`
- ⚠️ All pointing to same secret ref `graph-api-client-secret`
- ⚠️ Need to standardize on `EntraExternalId__` and remove others

#### Database Connection Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `DatabaseSettings__UseEnvironmentVariables` | Value | `true` | ✅ Good |
| `ConnectionStrings__DefaultConnection` | Value | Managed Identity auth | ✅ No password |
| `ConnectionStrings__CorpDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__HealthManagementDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__HealthProvidersDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__RxDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `SMXCORE_CORP_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Duplicate + password |
| `SMXCORE_HM2_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Legacy naming |
| `SMXCORE_HP2_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Legacy naming |
| `SMXCORE_RX_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Legacy naming |

**Issues:**
- ❌ Database passwords exposed in environment variables
- ⚠️ Duplicate connection strings with different naming patterns
- ⚠️ Mix of `ConnectionStrings__*` and `SMXCORE_*_DB_CONNECTION_STRING`
- ✅ DefaultConnection uses Managed Identity (no password)

#### Communication Services
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `CommunicationServices__ConnectionString` | **Secret** | `communication-services-connection-string` | ✅ Using secret ref |
| `CommunicationServices__FromAddress` | **Secret** | `email-service-from-address` | ⚠️ Email shouldn't be secret |
| `AzureCommunicationServices__ConnectionString` | **Secret** | `communication-services-connection-string` | ⚠️ Duplicate |

**Issues:**
- ⚠️ Two prefixes: `CommunicationServices__` and `AzureCommunicationServices__`
- ⚠️ Email address stored as secret (unnecessary)

#### Data Protection
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `DataProtection__KeyVaultUri` | Value | `https://smx25dev-kv.vault.azure.net/` | ✅ Good |
| `DataProtection__BlobUri` | Value | `https://smx25devstorage.blob.core.windows.net/...` | ✅ Good |
| `DataProtection__KeyId` | Value | `https://smx25dev-kv.vault.azure.net/keys/...` | ✅ Good |

#### Application Insights
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | **Secret** | `appinsights-connection-string` | ✅ Using secret ref |

#### Other Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `RESOURCE_GROUP_NAME` | Value | `smx25dev-rg` | ✅ Good |
| `DEPLOYMENT_TRIGGER` | Value | `20250908124908` | ℹ️ Deployment tracking |
| `RESTART_TRIGGER` | Value | ` ` (empty) | ℹ️ Manual restart trigger |
| `SECURITY_MODE` | Value | `MAXIMUM` | ℹ️ Custom config |

---

### **hp225dev-app** (Tenant A: cd21a3bf-622c-4725-8da7-2f8b9d265d14)

#### Authentication Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `EntraExternalId__ClientId` | Value | `38e8adac-...` | ✅ Correct prefix |
| `EntraExternalId__TenantId` | Value | `cd21a3bf-...` | ✅ Correct prefix |
| `EntraExternalId__Instance` | Value | `https://smx25dev.ciamlogin.com/` | ✅ Same tenant as smx25 |
| `EntraExternalId__Domain` | Value | `smx25dev.onmicrosoft.com` | ✅ Same tenant as smx25 |
| `EntraExternalId__SignUpSignInPolicyId` | Value | `hp2signin` | ✅ App-specific policy |
| `EntraExternalId__ClientSecret` | **Secret** | `azuread-clientsecret` | ✅ Using secret ref |
| `GraphApi__ClientSecret` | **Secret** | `graph-api-client-secret` | ⚠️ Different secret than EntraExternalId |
| `AzureAd__ClientId` | **Secret** | `azuread-clientid` | ❌ DEPRECATED + Secret (should be value) |
| `AzureAd__TenantId` | Value | `cd21a3bf-...` | ❌ DEPRECATED |
| `AzureAd__ClientSecret` | **Secret** | `azuread-clientsecret` | ❌ DEPRECATED |
| `TenantId` | Value | `cd21a3bf-...` | ⚠️ Non-standard naming |
| `ExternalIdClientId` | Value | `38e8adac-...` | ⚠️ Non-standard naming |
| `ExternalIdInstance` | Value | `https://unwashedmasses2.ciamlogin.com/` | ⚠️ Non-standard + wrong URL |
| `ExternalIdDomain` | Value | `smx25dev.onmicrosoft.com` | ⚠️ Non-standard naming |
| `UserFlow` | Value | `hp2signin` | ⚠️ Non-standard naming |

**Issues:**
- ❌ FIVE different prefixes: `EntraExternalId__`, `AzureAd__`, `ExternalId`, `GraphApi__`, bare names
- ❌ `AzureAd__ClientId` is a SECRET when it should be a value
- ⚠️ `ExternalIdInstance` has wrong URL (`unwashedmasses2` vs actual `smx25dev`)
- ⚠️ Multiple secrets for similar purposes (`azuread-clientsecret`, `graph-api-client-secret`)

#### Database Connection Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `DatabaseSettings__UseEnvironmentVariables` | Value | `true` | ✅ Good |
| `ConnectionStrings__DefaultConnection` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__CorpDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__HealthManagementDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__HealthProvidersDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `ConnectionStrings__RxDatabase` | Value | `...Password=IAmGroot!...` | ❌ Password in env var |
| `SMXCORE_CORP_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Duplicate |
| `SMXCORE_CORE_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Legacy naming |
| `SMXCORE_HEALTHPROVIDERS_DB_CONNECTION_STRING` | Value | `...Password=IAmGroot!...` | ⚠️ Legacy naming |

**Issues:**
- ❌ All database passwords exposed in environment variables
- ⚠️ Duplicate connection strings with different naming patterns
- ⚠️ Unlike smx25, DefaultConnection also has password (not using Managed Identity)

#### Communication Services
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `CommunicationServices__ConnectionString` | **Secret** | `communicationservices-connectionstring` | ✅ Using secret ref |
| `CommunicationServices__FromAddress` | **Secret** | `communicationservices-fromaddress` | ⚠️ Email shouldn't be secret |
| `ConnectionStrings__CommunicationServices` | **Secret** | `communicationservices-connectionstring` | ⚠️ Duplicate with different prefix |

**Issues:**
- ⚠️ Three different ways to reference same connection string
- ⚠️ Email address stored as secret

#### Data Protection
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `DataProtection__KeyVaultUri` | Value | `https://hp225dev-kv.vault.azure.net/` | ✅ Good |
| `DataProtection__BlobUri` | Value | `https://hp225devstorage.blob.core.windows.net/...` | ✅ Good |
| `DataProtection__KeyId` | Value | `https://hp225dev-kv.vault.azure.net/keys/...` | ✅ Good |
| `KeyVaultName` | Value | `hp225dev-kv` | ⚠️ Redundant with KeyVaultUri |
| `StorageAccountName` | Value | `hp225devstorage` | ⚠️ Redundant with BlobUri |

#### Application Insights
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | Value | Full connection string | ❌ Should be secret ref |

**Issues:**
- ❌ Application Insights connection string exposed (contains key)

#### Other Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `RESOURCE_GROUP_NAME` | Value | `hp225dev-rg` | ✅ Good |
| `GITHUB_RUN_NUMBER` | Value | `98` | ✅ Build tracking |
| `BUILD_DATE` | Value | `2025-09-29 14:07 UTC` | ✅ Build tracking |
| `APP_VERSION` | Value | `0.1.98` | ✅ Version tracking |

---

### **core25a-app** (Tenant B: c2d3b408-b7f9-424d-889e-56c08aee7725)

#### Authentication Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `AzureAd__ClientId` | Value | `955fee32-...` | ❌ WRONG PREFIX - should be EntraExternalId |
| `AzureAd__TenantId` | Value | `c2d3b408-...` | ❌ WRONG PREFIX - should be EntraExternalId |
| `AzureAd__ClientSecret` | **Secret** | `graph-api-client-secret` | ❌ WRONG PREFIX - should be EntraExternalId |
| `EntraExternalId__ClientSecret` | **Secret** | `graph-api-client-secret` | ⚠️ Correct prefix but inconsistent with ClientId/TenantId |
| `GraphApi__ClientSecret` | **Secret** | `graph-api-client-secret` | ⚠️ Third copy of same secret |

**Issues:**
- ❌ **CRITICAL**: Uses `AzureAd__` prefix instead of `EntraExternalId__` for ClientId/TenantId
- ❌ **THIS IS THE LOGIN BUG**: Code expects `EntraExternalId__*` but env vars have `AzureAd__*`
- ⚠️ Has both prefixes for ClientSecret but not for ClientId/TenantId
- ⚠️ appsettings.json has correct `EntraExternalId` section but env vars override with wrong prefix

#### Database Connection Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `DefaultConnection` | **Secret** | `default-connection` | ✅ Using secret ref (good) |

**Issues:**
- ✅ Much cleaner than smx25/hp225 - only one connection string variable
- ✅ Uses secret reference instead of exposing password
- ⚠️ Missing `DatabaseSettings__UseEnvironmentVariables` (defaults to appsettings.json value)

#### Communication Services
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `CommunicationServices__ConnectionString` | **Secret** | `communication-services-connection-string` | ✅ Using secret ref |
| `CommunicationServices__FromAddress` | **Secret** | `email-service-from-address` | ⚠️ Email shouldn't be secret |

**Issues:**
- ✅ Consistent naming with `CommunicationServices__` prefix
- ⚠️ Email address stored as secret (unnecessary)

#### Other Variables
| Variable Name | Type | Value/Pattern | Issues |
|--------------|------|---------------|--------|
| `RESTART_TRIGGER` | Value | `20250820-075944` | ℹ️ Deployment tracking |

**Missing Variables:**
- ❌ No `APPLICATIONINSIGHTS_CONNECTION_STRING` (missing telemetry)
- ❌ No `DataProtection__*` variables (data protection not configured)
- ❌ No `RESOURCE_GROUP_NAME`
- ❌ No `EntraExternalId__Instance` (using appsettings.json value)
- ❌ No `EntraExternalId__Domain` (using appsettings.json value)

---

## 🔍 Cross-App Comparison

### Authentication Configuration

| Aspect | smx25dev | hp225dev | core25a |
|--------|----------|----------|---------|
| **Prefix Used** | Mixed: `EntraExternalId__`, `GraphApi__`, `AzureAd__` | Mixed: 5 different prefixes | ❌ `AzureAd__` (WRONG) |
| **ClientId Location** | Env var (value) | Env var (mix of value and secret) | ❌ Env var with WRONG prefix |
| **TenantId Location** | Env var (value) | Env var (value) | ❌ Env var with WRONG prefix |
| **ClientSecret Location** | Secret ref ✅ | Secret ref ✅ | Secret ref ✅ |
| **Instance URL** | Env var | Mixed (correct and wrong) | Missing from env vars |
| **Domain** | Env var | Env var | Missing from env vars |
| **Shared Tenant** | ✅ Yes (with hp225) | ✅ Yes (with smx25) | ❌ No (separate tenant) |

### Database Configuration

| Aspect | smx25dev | hp225dev | core25a |
|--------|----------|----------|---------|
| **Password Storage** | ❌ In env vars | ❌ In env vars | ✅ In secrets |
| **Connection String Pattern** | Duplicate (2 patterns) | Duplicate (2 patterns) | Single ✅ |
| **Managed Identity** | ✅ DefaultConnection only | ❌ None | Possible (not using) |
| **UseEnvironmentVariables** | ✅ `true` | ✅ `true` | From appsettings |

### Communication Services

| Aspect | smx25dev | hp225dev | core25a |
|--------|----------|----------|---------|
| **Connection String** | ✅ Secret ref | ✅ Secret ref | ✅ Secret ref |
| **From Address** | ⚠️ Secret (unnecessary) | ⚠️ Secret (unnecessary) | ⚠️ Secret (unnecessary) |
| **Naming Consistency** | ⚠️ Two prefixes | ⚠️ Three names | ✅ Consistent |

### Telemetry & Monitoring

| Aspect | smx25dev | hp225dev | core25a |
|--------|----------|----------|---------|
| **App Insights** | ✅ Secret ref | ❌ Exposed value | ❌ Not configured |
| **Build Tracking** | ✅ DEPLOYMENT_TRIGGER | ✅ GITHUB_RUN_NUMBER, BUILD_DATE, APP_VERSION | ❌ Only RESTART_TRIGGER |
| **Resource Group Name** | ✅ Yes | ✅ Yes | ❌ No |

---

## 🚨 Critical Issues Summary

### **Priority 1 - BLOCKING (Fix Immediately)**

1. **core25a Login Failure** ❌
   - **Issue**: Env vars use `AzureAd__ClientId` but code expects `EntraExternalId__ClientId`
   - **Impact**: Login completely broken
   - **Fix**: Rename `AzureAd__*` to `EntraExternalId__*`

### **Priority 2 - SECURITY (Fix This Week)**

2. **Database Passwords Exposed** ❌ (smx25, hp225)
   - **Issue**: All database connection strings contain passwords in plain env vars
   - **Impact**: Security risk, password rotation difficult
   - **Fix**: Move to secret references

3. **Application Insights Key Exposed** ❌ (hp225)
   - **Issue**: Full App Insights connection string with key in plain env var
   - **Impact**: Telemetry data accessible
   - **Fix**: Move to secret reference

### **Priority 3 - INCONSISTENCY (Fix Next Sprint)**

4. **Multiple Naming Conventions** ⚠️ (All apps)
   - **Issue**: 5+ different prefixes for authentication across apps
   - **Impact**: Confusing, error-prone, hard to maintain
   - **Fix**: Standardize on `EntraExternalId__` everywhere

5. **Duplicate Configuration** ⚠️ (smx25, hp225)
   - **Issue**: Same values stored under multiple variable names
   - **Impact**: Sync issues, wasted resources, confusion
   - **Fix**: Remove duplicates, use single source of truth

6. **Email Addresses as Secrets** ⚠️ (All apps)
   - **Issue**: `FromAddress` stored as secret when it's not sensitive
   - **Impact**: Unnecessary complexity
   - **Fix**: Make it a regular env var

---

## ✅ Recommended Standardization

### **Authentication Section** (All Apps)

**ONLY use `EntraExternalId__` prefix:**

```yaml
# Environment Variables (all apps)
EntraExternalId__Instance: "https://{tenant}.ciamlogin.com/"
EntraExternalId__Domain: "{tenant}.onmicrosoft.com"
EntraExternalId__TenantId: "{guid}"
EntraExternalId__ClientId: "{guid}"
EntraExternalId__SignUpSignInPolicyId: "signupsignin1"  # or app-specific

# Secret References (all apps)
EntraExternalId__ClientSecret:
  secretRef: "entra-client-secret"
```

**REMOVE these deprecated variables:**
- ❌ `AzureAd__*`
- ❌ `GraphApi__*` (unless actually calling Graph API separately)
- ❌ `ExternalId*` (non-standard)
- ❌ `TenantId` (bare)
- ❌ `UserFlow` (use EntraExternalId__SignUpSignInPolicyId)

---

### **Database Section** (All Apps)

```yaml
# Environment Variable
DatabaseSettings__UseEnvironmentVariables: "true"

# Secret References (per database)
ConnectionStrings__DefaultConnection:
  secretRef: "default-connection"
ConnectionStrings__CorpDatabase:
  secretRef: "corp-database-connection"
ConnectionStrings__HealthManagementDatabase:
  secretRef: "healthmanagement-database-connection"
ConnectionStrings__HealthProvidersDatabase:
  secretRef: "healthproviders-database-connection"
ConnectionStrings__RxDatabase:
  secretRef: "rx-database-connection"
```

**REMOVE these duplicates:**
- ❌ `SMXCORE_CORP_DB_CONNECTION_STRING`
- ❌ `SMXCORE_HM2_DB_CONNECTION_STRING`
- ❌ `SMXCORE_HP2_DB_CONNECTION_STRING`
- ❌ `SMXCORE_RX_DB_CONNECTION_STRING`
- ❌ `SMXCORE_CORE_DB_CONNECTION_STRING`
- ❌ `SMXCORE_HEALTHPROVIDERS_DB_CONNECTION_STRING`

---

### **Communication Services Section** (All Apps)

```yaml
# Environment Variable (not secret)
CommunicationServices__FromAddress: "donotreply@{domain}"

# Secret Reference
CommunicationServices__ConnectionString:
  secretRef: "communication-services-connection"
```

**REMOVE these:**
- ❌ `AzureCommunicationServices__*` (use `CommunicationServices__`)
- ❌ `ConnectionStrings__CommunicationServices` (wrong prefix)
- ⚠️ `CommunicationServices__FromAddress` as secret (make it regular value)

---

### **Telemetry Section** (All Apps)

```yaml
# Secret Reference
APPLICATIONINSIGHTS_CONNECTION_STRING:
  secretRef: "appinsights-connection"

# Build Tracking (optional but useful)
GITHUB_RUN_NUMBER: "{number}"
BUILD_DATE: "{timestamp}"
APP_VERSION: "{version}"
```

---

### **Data Protection Section** (All Apps)

```yaml
DataProtection__KeyVaultUri: "https://{app}-{env}-kv.vault.azure.net/"
DataProtection__BlobUri: "https://{app}{env}storage.blob.core.windows.net/dataprotection/keys.xml"
DataProtection__KeyId: "https://{app}-{env}-kv.vault.azure.net/keys/dataprotection-keys"
```

---

### **Operational Variables** (All Apps)

```yaml
RESOURCE_GROUP_NAME: "{app}-{env}-rg"
DEPLOYMENT_TRIGGER: "{timestamp}"  # Optional: force restart
```

---

## 📋 Action Plan

### **Phase 1: Fix core25a Login** ✅ **COMPLETED October 6, 2025**

**Status**: ✅ Fixed and deployed

**Commands Executed:**
```bash
# Switched to core25a tenant
az account set --subscription "subs-core25a"

# Added correct EntraExternalId variables
az containerapp update --name core25a-app --resource-group core25a-rg \
  --set-env-vars \
    EntraExternalId__Instance='https://Core25a2.ciamlogin.com/' \
    EntraExternalId__Domain='Core25a2.onmicrosoft.com' \
    EntraExternalId__TenantId='65900b34-1871-47ba-8bf0-68c775bf586d' \
    EntraExternalId__ClientId='ef108c11-b506-4fee-b14e-2be49b3798fa'

# Removed deprecated AzureAd__ClientSecret variable
az containerapp update --name core25a-app --resource-group core25a-rg \
  --remove-env-vars "AzureAd__ClientSecret"
```

**Result:**
- New revision deployed: `core25a-app--0000032`
- Authentication variables now use correct `EntraExternalId__*` prefix
- Login should now work correctly

**Verification Needed:**
- [ ] Test login at https://core25a-app.livelyocean-fe5b55be.eastus2.azurecontainerapps.io/Account/Login
- [ ] Confirm no authentication errors in Application Insights
- [ ] Verify user can complete full authentication flow

---

### **Phase 2: Secure Database Passwords** ⏸️ **DEFERRED**

**Status**: ⏸️ Deferred until after core25a validation

**Rationale**:
- **Test First**: Use core25a to validate the configuration approach
- **Risk Mitigation**: Don't touch smx25/hp225 (production apps) until pattern is proven
- **Security Context**: While not ideal, passwords in env vars are still protected by Azure RBAC
- **Phased Rollout**: Fix blocking issues first (authentication), then security improvements

**Scope When Implemented:**
Move all database connection strings to Key Vault secret references for smx25 and hp225:
- smx25: Corp, HealthManagement, HealthProviders, Rx databases
- hp225: DefaultConnection, Corp, HealthManagement, HealthProviders, Rx databases

**Priority**: 🟡 Important but not blocking - address after core25a validation

---

### **Phase 3: Standardize All Variables** ⏸️ **DEFERRED**

**Status**: ⏸️ Deferred until Phase 1 validated and Phase 2 complete

Apply recommended standardization across all three apps:
- Remove duplicate variables (`GraphApi__*`, `AzureAd__*`, `SMXCORE_*_DB_CONNECTION_STRING`)
- Standardize on `EntraExternalId__*` prefix only
- Move email addresses from secrets to regular env vars
- Add missing operational variables (RESOURCE_GROUP_NAME, build tracking)

---

**Created**: October 6, 2025  
**Last Updated**: October 6, 2025  
**Next Review**: After Phase 1 fix verification
