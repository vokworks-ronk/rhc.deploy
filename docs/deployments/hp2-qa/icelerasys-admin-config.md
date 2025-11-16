# HP2 QA - icelerasys Admin Configuration

**Date**: 2025-11-16 13:13:37
**Environment**: HP2 QA (rhcqa tenant)
**User**: icelerasys@rhcqa.onmicrosoft.com
**User Object ID**: d741e1a6-e97c-4da0-b270-0679f29e5e7f

## Configuration Summary

### 1. Entra ID Global Administrator Role
- **Status**: ✅ Assigned
- **Role**: Global Administrator
- **Scope**: Tenant-wide (rhcqa.onmicrosoft.com)
- **Tenant ID**: 2604fd9a-93a6-448e-bdc9-25e3c2d671a2

### 2. Resource Group Owner Role
- **Status**: ✅ Assigned
- **Role**: Owner
- **Resource Group**: rhc-hp2-qa-rg
- **Subscription**: subs-rhcqa (3991b88f-785e-4e03-bac3-e6721b76140b)
- **Assignment ID**: 3deb7eb2-1f60-4e59-a1b2-ff69af9159cf
- **Created**: 2025-11-16T18:13:10.951025+00:00

## Verification Commands

### Verify Resource Group Owner Role
```powershell
# List all owners of rhc-hp2-qa-rg
az role assignment list --resource-group rhc-hp2-qa-rg --role Owner --query "[].{Principal:principalName, PrincipalId:principalId, Role:roleDefinitionName}" -o table
```

## Purpose

The icelerasys user is configured for administrative work with:
- Full tenant-level administrative access via Global Administrator role
- Full resource group management access via Owner role on rhc-hp2-qa-rg

This allows the user to manage all aspects of the HP2 QA environment including:
- Entra ID users and applications
- Azure resources in the rhc-hp2-qa-rg resource group
- Container apps, databases, key vaults, storage accounts, and other services
