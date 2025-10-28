
# 🧱 Multi-Tenant Architecture for B2C Application Deployment

## 📍 Overview

This document outlines the proposed architecture for deploying a client-facing B2C application alongside a secure, isolated database environment. The design leverages multiple Microsoft Entra tenants to enforce identity boundaries, support development workflows, and maintain audit integrity.

---

## 🧠 Tenant Strategy

### 1. **Back Office Tenant (Existing)**
- **Type**: Microsoft Entra ID (Workforce)
- **Purpose**: Internal operations, Office 365, IT administration
- **Status**: Already provisioned
- **Notes**: Will serve as the control plane for IT accounts and billing

### 2. **B2C QA Tenant**
- **Type**: Microsoft Entra ID B2C
- **Purpose**: Testing and staging for the client-facing app
- **Access**: External identities only; no IT or internal accounts
- **Notes**: Used for UAT, dev cycles, and feature validation

### 3. **B2C Production Tenant**
- **Type**: Microsoft Entra ID B2C
- **Purpose**: Live deployment of the client-facing app
- **Access**: External identities only; hardened policies and MFA
- **Notes**: No direct access to database resources

### 4. **Database Tenant**
- **Type**: Microsoft Entra ID (Workforce)
- **Purpose**: Hosting Azure SQL and SQL Server Managed Instance
- **Access**: Restricted to IT accounts and service principals
- **Notes**: No B2C identities or app registrations permitted

---

## 🔐 Database Strategy

### Phase 1: Azure SQL Server
- Lightweight, cost-effective
- Used for initial deployment and testing
- Limitations: No replication, SQL Agent, or cross-db transactions

### Phase 2: SQL Server Managed Instance
- Full SQL Server feature set
- Required for DBA replication workflows
- Higher cost; deferred until production maturity
- Requires VNet integration and private endpoints

---

## 🔌 Identity and Access Model

- **No direct trust** between B2C tenants and the database tenant
- **Service principals or managed identities** from B2C tenants will be granted access to Azure SQL
- **SQL user creation** via:
  ```sql
  CREATE USER [app-identity] FROM EXTERNAL PROVIDER;
  ALTER ROLE db_datareader ADD MEMBER [app-identity];
  ALTER ROLE db_datawriter ADD MEMBER [app-identity];
  ```

---

## 🔑 Blazor Server App Connection Strings

### Using Managed Identity
```csharp
Server=tcp:<db-server>.database.windows.net,1433;
Database=<db-name>;
Authentication=Active Directory Managed Identity;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

### Using Service Principal
```csharp
Server=tcp:<db-server>.database.windows.net,1433;
Database=<db-name>;
Authentication=Active Directory Password;
User ID=<client-id>@<b2c-tenant>.onmicrosoft.com;
Password=<client-secret>;
Encrypt=True;
TrustServerCertificate=False;
Connection Timeout=30;
```

---

## 💳 Subscription and Billing Strategy

- All tenants will be linked to a **central billing account** under the existing Office 365 tenant
- Each tenant will receive its own **subscription** for isolation and cost tracking
- Subscription naming convention:
  - `contoso-b2c-qa-sub`
  - `contoso-b2c-prod-sub`
  - `contoso-db-core-sub`

---

## 🚫 Tenant Creation Constraints

- **Tenant creation must be done manually via Azure Portal**
- No supported API, CLI, or PowerShell method to create Entra tenants
- Post-creation tasks (subscriptions, RBAC, app registrations) can be fully scripted

---

## 🧩 Naming Conventions

| Tenant Purpose     | Suggested Domain Name             |
|--------------------|-----------------------------------|
| B2C QA             | `contoso-b2c-qa.onmicrosoft.com`  |
| B2C Production     | `contoso-b2c-prod.onmicrosoft.com`|
| Database           | `contoso-db-core.onmicrosoft.com` |

---

## 📦 Next Steps

This document will serve as the foundation for breaking the project into actionable steps:
- Tenant provisioning
- Subscription assignment
- Identity flow setup
- Database access scaffolding
- App connection string validation
- Audit and hash validation logic

---

## 📚 Comprehensive Deployment Documentation

This architecture document has been expanded into a complete deployment guide. See:

### Getting Started
- **`README.md`** - Start here! Quick start guide and overview
- **`QUICK-REFERENCE.md`** - Key information and command reference

### Phase-by-Phase Guides
- **`00-project-overview.md`** - Complete project context (all Q&A captured)
- **`01-tenant-creation.md`** - Create the 3 new tenants
- **`02-subscription-setup.md`** - Set up subscriptions and billing
- **`03-database-tenant-setup.md`** - Deploy SQL servers and databases
- **`04-b2c-tenant-setup.md`** - Configure B2C authentication and MFA
- **`05-resource-groups-and-services.md`** - Deploy Container Apps and services
- **`06-github-actions-qa.md`** - Set up CI/CD pipelines
- **`07-security-and-compliance.md`** - Security review and HIPAA/PCI-DSS

### Tracking
- **`deployment-log.md`** - Track your progress and document issues

### Automation
Each phase includes:
- ✅ Checklists
- 📜 Microsoft Graph scripts (preferred)
- 🔧 Azure CLI commands
- ⚡ PowerShell alternatives
- 🖥️ Azure Portal steps (fallback)

**Ready to deploy?** Start with `README.md`!

---

