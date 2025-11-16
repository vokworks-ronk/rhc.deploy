# {APP} {ENV} Deployment

**Environment:** {ENV} (Dev/QA/Prod)  
**Application:** {APP} (SMX/HP2)  
**Status:** ⏳ To be deployed  
**Last Updated:** {DATE}

---

## 📊 Quick Reference

| Resource | Value |
|----------|-------|
| **Container App** | `{app-name}` |
| **Resource Group** | `{rg-name}` |
| **URL** | https://{app-url} |
| **Custom Domain** | `{custom-domain}` |
| **Tenant** | `{tenant}.onmicrosoft.com` |
| **Tenant ID** | `{tenant-id}` |
| **Subscription** | `{subscription-name}` (`{subscription-id}`) |

---

## 🎯 Current Status

- [ ] Infrastructure created
- [ ] Authentication configured
- [ ] Database connected
- [ ] DataProtection configured
- [ ] Application Insights connected
- [ ] GitHub Actions deployment working
- [ ] Custom domain configured

---

## 🔧 Azure Resources

### Container Apps
- **App Name:** `{app-name}`
- **Environment:** `{env-name}`
- **Managed Identity:** `{principal-id}`

### Key Vault
- **Name:** `{kv-name}`
- **URI:** `https://{kv-name}.vault.azure.net/`

### Storage Account (if applicable)
- **Name:** `{storage-name}`
- **Blob Endpoint:** `https://{storage-name}.blob.core.windows.net/`

### Application Insights
- **Name:** `{appinsights-name}`
- **Instrumentation Key:** `{key}`

### Log Analytics
- **Name:** `{logs-name}`
- **Workspace ID:** `{workspace-id}`

---

## 🔐 Authentication

### CIAM/External ID Configuration
- **Instance:** `https://{tenant}.ciamlogin.com/`
- **Domain:** `{tenant}.onmicrosoft.com`
- **Client ID:** `{client-id}`
- **Client Secret:** Stored in Key Vault: `{secret-name}`

---

## 🗄️ Database

### Connection Details
- **Server:** `{sql-server}.database.windows.net`
- **Database:** `{database-name}`
- **Authentication:** Active Directory Service Principal
- **Service Principal ID:** Stored in Key Vault: `{sp-id-secret}`
- **Service Principal Secret:** Stored in Key Vault: `{sp-secret-secret}`

---

## 📋 Environment Variables Backup

**Last Backup:** {DATE}  
**File:** `env-vars-backup-{timestamp}.json`

---

## 📝 Deployment History

| Date | Action | Result | Notes |
|------|--------|--------|-------|
| {DATE} | Initial deployment | ⏳ Pending | |

---

## 🆘 Emergency Contacts

- **Azure Subscription Owner:** {NAME}
- **Database Admin:** {NAME}
- **DevOps Lead:** {NAME}
