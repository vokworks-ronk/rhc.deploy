# SMX QA - icelerasys Admin Configuration

**Date**: 2025-11-16 13:09:51
**Environment**: SMX QA (rhcqa tenant)
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
- **Resource Group**: rhc-smx-qa-rg
- **Subscription**: subs-rhcqa (3991b88f-785e-4e03-bac3-e6721b76140b)
- **Assignment ID**: 129b0f21-cc18-43ab-bf4a-117d39968cee
- **Created**: 2025-11-16T18:09:09.602054+00:00

## Verification Commands

### Verify Global Administrator Role
```powershell
# List all Global Administrators
az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles" | ConvertFrom-Json | Select-Object -ExpandProperty value | Where-Object { $_.displayName -eq 'Global Administrator' } | ForEach-Object { $roleId = $_.id; az rest --method GET --uri "https://graph.microsoft.com/v1.0/directoryRoles/$roleId/members" | ConvertFrom-Json | Select-Object -ExpandProperty value | Select-Object displayName, userPrincipalName }
```

### Verify Resource Group Owner Role
```powershell
# List all owners of rhc-smx-qa-rg
az role assignment list --resource-group rhc-smx-qa-rg --role Owner --query "[].{Principal:principalName, PrincipalId:principalId, Role:roleDefinitionName}" -o table
```

## Purpose

The icelerasys user is configured for administrative work with:
- Full tenant-level administrative access via Global Administrator role
- Full resource group management access via Owner role on rhc-smx-qa-rg

This allows the user to manage all aspects of the SMX QA environment including:
- Entra ID users and applications
- Azure resources in the rhc-smx-qa-rg resource group
- Container apps, databases, key vaults, and other services
