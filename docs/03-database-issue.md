
## summary

we are trying to create databases and having issues.

```
$lamAdminGroupId = (az ad group show --group "db-lam-sqlsvr-admin" --query id -o tsv); az sql server create --name "rhcdb-lam-sqlsvr" --resource-group "db-lam-rg" --location "eastus2" --enable-ad-only-auth --external-admin-principal-type "Group" --external-admin-name "db-lam-sqlsvr-admin" --external-admin-sid $lamAdminGroupId --assign-identity
(InvalidResourceLocation) The resource 'rhcdb-lam-sqlsvr' already exists in location 'eastus' in resource group 'db-lam-rg'. A resource with the same name cannot be created in location 'eastus2'. Please select a new resource name.
Code: InvalidResourceLocation
Message: The resource 'rhcdb-lam-sqlsvr' already exists in location 'eastus' in resource group 'db-lam-rg'. A resource with the same name cannot be created in location 'eastus2'. Please select a new resource name.
```

## reference

03-database-tenant-setup.md

## correct connection info

```
PS C:\Users\rrkru\local\wip\rhc\arch> az account show
{
  "environmentName": "AzureCloud",
{
  "environmentName": "AzureCloud",
  "environmentName": "AzureCloud",
  "homeTenantId": "4ed17c8b-26b0-4be9-a189-768c67fd03f5",
  "id": "a73a2d39-598b-4671-a3a6-2028c59f3d40",
  "isDefault": true,
  "managedByTenants": [],
  "name": "subs-rhcdbase",
  "state": "Enabled",
  "tenantId": "4ed17c8b-26b0-4be9-a189-768c67fd03f5",
  "user": {
    "name": "ron@recalibratehealthcare.com",
    "type": "user"
  }
}
```

## mssupport

### 2024-11-11 ms supprot says

Hello Ronald,

Thank you for your response.

Apologies for any inconvenience caused.

I completely understand your requirement and have expedited your request further.

Currently, your request is under review with our Azure Capacity team. 

We understand the importance of addressing this promptly and will keep you updated on any progress. 

**Regarding the EAST US2 issue with the error message:**

I have limited details about the specific error, but based on my understanding, it appears that an SQL Server resource with the same name, **rhcdb-lam-sqlsvr**, has been created in two regions—EAST US and EAST US2—under the same resource group **db-lam-rg**.

In the EAST US region, the SQL Server name is **rhcdb-lam-sqlsvr**, and in the EAST US2 region, the SQL Server name is also **rhcdb-lam-sqlsvr**.

Please note that a resource with the same name cannot be created in multiple locations under the same resource group. This is likely the reason for the failure.

I hope this clarifies the issue. If not, I will engage the relevant technical team for further assistance with the problem you’re facing.

We Look forward for your response.