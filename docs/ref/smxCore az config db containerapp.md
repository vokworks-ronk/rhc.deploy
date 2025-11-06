[[smxCore]]

Steps to configure smxCore, in three sections:

- Concepts - explains the elements and goals, not complete
- actions - walk down the sections, a script for each section
- verification - scripts to verify the actions took place.  If troubleshooting an existing deploy walking the verifications may reveal an issue.  
# concepts

- sql server 
	- security group 

# actions

### create and assign users to Entra security group used to manage the sql server

#### create the security group

```
$GROUP_NAME = "smxcore-rg-smxcore-sqlsvr-admin"

az ad group create `
  --display-name "$GROUP_NAME" `
  --security-enabled true

az ad group owner add `
  --group "$GROUP_NAME" `
  --owner rkrueger@vokworks.onmicrosoft.com

az ad group owner add `
  --group "$GROUP_NAME" `
  --owner tbombadil@vokworks.onmicrosoft.com

az ad group member add `
  --group "$GROUP_NAME" `
  --member tbombadil@vokworks.onmicrosoft.com
```

#### view the security group

```run-powershell
$GROUP_NAME = "smxcore-rg-smxcore-sqlsvr-admin"

write-output "$GROUP_NAME"

write-output "id:"
az ad group show `
  --group "$GROUP_NAME" `
  --query "id" `
  --output tsv

write-output "owners:"
az ad group owner list `
  --group "$GROUP_NAME" `
  --query "[].userPrincipalName" `
  --output tsv

write-output "members:"
az ad group member list `
  --group "$GROUP_NAME" `
  --query "[].userPrincipalName" `
  --output tsv
```

```
smxcore-rg-smxcore-sqlsvr-admin
id:
423030c2-5bce-470e-be7e-2eb675c7b8c1
owners:
rkrueger@vokworks.onmicrosoft.com
tbombadil@vokworks.onmicrosoft.com
members:
tbombadil@vokworks.onmicrosoft.com
```

### create the Az SQL Server

*note: Currently, Azure SQL requires an admin password during the creation of the SQL server, even if you plan to use Azure Active Directory (AAD) authentication later. This is a mandatory requirement for creating the server.*

**✅ Best Practice: Use a Clearly Distinct SQL Admin Name**

Since the **SQL Server admin username** is a traditional SQL authentication login, it has **no connection to Azure AD users** unless explicitly configured later.

To avoid confusion, it’s better to use a **unique name** for the SQL admin:

```run-powershell
$ServerName="smxCore-sqlsvr"
$RGroup="smxCore-rg"
$Location="eastus"
$AdminUser = "sqlAdminGroot"
$AdminPassword = "IAmGroot!"

az sql server create `
--name $ServerName `
--resource-group $RGroup `
--location $Location `
--admin-user $AdminUser `
--admin-password $AdminPassword `
--identity-type SystemAssigned
```

```
{
  "administratorLogin": "sqlAdminGroot",
  "administratorLoginPassword": null,
  "administrators": null,
  "externalGovernanceStatus": "Disabled",
  "federatedClientId": null,
  "fullyQualifiedDomainName": "smxcore-sqlsvr.database.windows.net",
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr",
  "identity": null,
  "isIPv6Enabled": null,
  "keyId": null,
  "kind": "v12.0",
  "location": "eastus",
  "minimalTlsVersion": "1.2",
  "name": "smxcore-sqlsvr",
  "primaryUserAssignedIdentityId": null,
  "privateEndpointConnections": [],
  "publicNetworkAccess": "Enabled",
  "resourceGroup": "smxCore-rg",
  "restrictOutboundNetworkAccess": "Disabled",
  "state": "Ready",
  "tags": null,
  "type": "Microsoft.Sql/servers",
  "version": "12.0",
  "workspaceFeature": null
}
```
#### Assign the Security Group as the AD-Admin for the SQL Server

```run-powershell
$ServerName = "smxcore-sqlsvr"
$RGroup = "smxCore-rg"
$DisplayName = "smxcore-rg-smxcore-sqlsvr-admin"
$aadAdminObjectId = "423030c2-5bce-470e-be7e-2eb675c7b8c1"

az sql server ad-admin create `
--resource-group $RGroup `
--server $ServerName `
--display-name $DisplayName `
--object-id $aadAdminObjectId
```

```
{
  "administratorType": "ActiveDirectory",
  "azureAdOnlyAuthentication": null,
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr/administrators/ActiveDirectory",
  "login": "smxcore-rg-smxcore-sqlsvr-admin",
  "name": "ActiveDirectory",
  "resourceGroup": "smxCore-rg",
  "sid": "423030c2-5bce-470e-be7e-2eb675c7b8c1",
  "tenantId": "c63aa480-a9f6-41a8-aa48-076eb398b167",
  "type": "Microsoft.Sql/servers"
}
```

```
{
  "administratorType": "ActiveDirectory",
  "azureAdOnlyAuthentication": null,
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr/administrators/ActiveDirectory",
  "login": "Entra SQL Admin",
  "name": "ActiveDirectory",
  "resourceGroup": "smxCore-rg",
  "sid": "423030c2-5bce-470e-be7e-2eb675c7b8c1",
  "tenantId": "c63aa480-a9f6-41a8-aa48-076eb398b167",
  "type": "Microsoft.Sql/servers"
}
```

#### Set the database server Firewall rules

[[smxCore az db create firewall|Firewall Rules]]
### create the databases proper

```run-powershell
$ServerName = "smxcore-sqlsvr"
$RGroup = "smxCore-rg"
$databases = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")

foreach ($db in $databases) {
Write-Host "Creating database: $db..."
az sql db create `
--name $db `
--server $ServerName `
--resource-group $RGroup `
--max-size 2GB `
--service-objective "S0"
Write-Host "Created: $db"
}

Write-Host "All databases have been successfully created!"
```

```
Creating database: smxcore_corp_db...
{
  "autoPauseDelay": null,
  "availabilityZone": "NoPreference",
  "catalogCollation": "SQL_Latin1_General_CP1_CI_AS",
  "collation": "SQL_Latin1_General_CP1_CI_AS",
  "createMode": null,
  "creationDate": "2025-05-31T20:38:13.173000+00:00",
  "currentBackupStorageRedundancy": "Geo",
  "currentServiceObjectiveName": "S0",
  "currentSku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "databaseId": "dc3d76c2-23eb-4cf3-ae13-b619568531ce",
  "defaultSecondaryLocation": "westus",
  "earliestRestoreDate": null,
  "edition": "Standard",
  "elasticPoolId": null,
  "elasticPoolName": null,
  "encryptionProtector": null,
  "encryptionProtectorAutoRotation": null,
  "failoverGroupId": null,
  "federatedClientId": null,
  "freeLimitExhaustionBehavior": null,
  "highAvailabilityReplicaCount": null,
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr/databases/smxcore_corp_db",
  "identity": null,
  "isInfraEncryptionEnabled": false,
  "keys": null,
  "kind": "v12.0,user",
  "ledgerOn": false,
  "licenseType": null,
  "location": "eastus",
  "longTermRetentionBackupResourceId": null,
  "maintenanceConfigurationId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default",
  "managedBy": null,
  "manualCutover": null,
  "maxLogSizeBytes": null,
  "maxSizeBytes": 2147483648,
  "minCapacity": null,
  "name": "smxcore_corp_db",
  "pausedDate": null,
  "performCutover": null,
  "preferredEnclaveType": null,
  "readScale": "Disabled",
  "recoverableDatabaseId": null,
  "recoveryServicesRecoveryPointId": null,
  "requestedBackupStorageRedundancy": "Geo",
  "requestedServiceObjectiveName": "S0",
  "resourceGroup": "smxCore-rg",
  "restorableDroppedDatabaseId": null,
  "restorePointInTime": null,
  "resumedDate": null,
  "sampleName": null,
  "secondaryType": null,
  "sku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "sourceDatabaseDeletionDate": null,
  "sourceDatabaseId": null,
  "sourceResourceId": null,
  "status": "Online",
  "tags": null,
  "type": "Microsoft.Sql/servers/databases",
  "useFreeLimit": null,
  "zoneRedundant": false
}
Created: smxcore_corp_db
Creating database: smxcore_hm2_db...
{
  "autoPauseDelay": null,
  "availabilityZone": "NoPreference",
  "catalogCollation": "SQL_Latin1_General_CP1_CI_AS",
  "collation": "SQL_Latin1_General_CP1_CI_AS",
  "createMode": null,
  "creationDate": "2025-05-31T20:39:17.800000+00:00",
  "currentBackupStorageRedundancy": "Geo",
  "currentServiceObjectiveName": "S0",
  "currentSku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "databaseId": "a9a33dcc-73ea-4264-91fd-d60e1b8a9db1",
  "defaultSecondaryLocation": "westus",
  "earliestRestoreDate": null,
  "edition": "Standard",
  "elasticPoolId": null,
  "elasticPoolName": null,
  "encryptionProtector": null,
  "encryptionProtectorAutoRotation": null,
  "failoverGroupId": null,
  "federatedClientId": null,
  "freeLimitExhaustionBehavior": null,
  "highAvailabilityReplicaCount": null,
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr/databases/smxcore_hm2_db",
  "identity": null,
  "isInfraEncryptionEnabled": false,
  "keys": null,
  "kind": "v12.0,user",
  "ledgerOn": false,
  "licenseType": null,
  "location": "eastus",
  "longTermRetentionBackupResourceId": null,
  "maintenanceConfigurationId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default",
  "managedBy": null,
  "manualCutover": null,
  "maxLogSizeBytes": null,
  "maxSizeBytes": 2147483648,
  "minCapacity": null,
  "name": "smxcore_hm2_db",
  "pausedDate": null,
  "performCutover": null,
  "preferredEnclaveType": null,
  "readScale": "Disabled",
  "recoverableDatabaseId": null,
  "recoveryServicesRecoveryPointId": null,
  "requestedBackupStorageRedundancy": "Geo",
  "requestedServiceObjectiveName": "S0",
  "resourceGroup": "smxCore-rg",
  "restorableDroppedDatabaseId": null,
  "restorePointInTime": null,
  "resumedDate": null,
  "sampleName": null,
  "secondaryType": null,
  "sku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "sourceDatabaseDeletionDate": null,
  "sourceDatabaseId": null,
  "sourceResourceId": null,
  "status": "Online",
  "tags": null,
  "type": "Microsoft.Sql/servers/databases",
  "useFreeLimit": null,
  "zoneRedundant": false
}
Created: smxcore_hm2_db
Creating database: smxcore_hp2_db...
{
  "autoPauseDelay": null,
  "availabilityZone": "NoPreference",
  "catalogCollation": "SQL_Latin1_General_CP1_CI_AS",
  "collation": "SQL_Latin1_General_CP1_CI_AS",
  "createMode": null,
  "creationDate": "2025-05-31T20:40:25.103000+00:00",
  "currentBackupStorageRedundancy": "Geo",
  "currentServiceObjectiveName": "S0",
  "currentSku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "databaseId": "95d2613c-c98e-4517-9584-81eb1b9f1eca",
  "defaultSecondaryLocation": "westus",
  "earliestRestoreDate": null,
  "edition": "Standard",
  "elasticPoolId": null,
  "elasticPoolName": null,
  "encryptionProtector": null,
  "encryptionProtectorAutoRotation": null,
  "failoverGroupId": null,
  "federatedClientId": null,
  "freeLimitExhaustionBehavior": null,
  "highAvailabilityReplicaCount": null,
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.Sql/servers/smxcore-sqlsvr/databases/smxcore_hp2_db",
  "identity": null,
  "isInfraEncryptionEnabled": false,
  "keys": null,
  "kind": "v12.0,user",
  "ledgerOn": false,
  "licenseType": null,
  "location": "eastus",
  "longTermRetentionBackupResourceId": null,
  "maintenanceConfigurationId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default",
  "managedBy": null,
  "manualCutover": null,
  "maxLogSizeBytes": null,
  "maxSizeBytes": 2147483648,
  "minCapacity": null,
  "name": "smxcore_hp2_db",
  "pausedDate": null,
  "performCutover": null,
  "preferredEnclaveType": null,
  "readScale": "Disabled",
  "recoverableDatabaseId": null,
  "recoveryServicesRecoveryPointId": null,
  "requestedBackupStorageRedundancy": "Geo",
  "requestedServiceObjectiveName": "S0",
  "resourceGroup": "smxCore-rg",
  "restorableDroppedDatabaseId": null,
  "restorePointInTime": null,
  "resumedDate": null,
  "sampleName": null,
  "secondaryType": null,
  "sku": {
    "capacity": 10,
    "family": null,
    "name": "Standard",
    "size": null,
    "tier": "Standard"
  },
  "sourceDatabaseDeletionDate": null,
  "sourceDatabaseId": null,
  "sourceResourceId": null,
  "status": "Online",
  "tags": null,
  "type": "Microsoft.Sql/servers/databases",
  "useFreeLimit": null,
  "zoneRedundant": false
}
Created: smxcore_hp2_db
All databases have been successfully created!
```

#### add the security group as a user to the database

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")
$SEC_GROUP = "smxcore-rg-smxcore-sqlsvr-admin"

foreach ($DB in $DATABASES) {
Write-Host "Registering security group to database: $DB..."

sqlcmd -S $SERVER -d $DB -G -U $USER `
  -Q "CREATE USER [$SEC_GROUP] FROM EXTERNAL PROVIDER"
}

Write-Host "security group registered to all databases"
```

```
Registering security group to database: smxcore_corp_db...
Registering security group to database: smxcore_hm2_db...
Registering security group to database: smxcore_hp2_db...
security group registered to all databases
```
#### grant security group database control

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")
$SEC_GROUP = "smxcore-rg-smxcore-sqlsvr-admin"

foreach ($DB in $DATABASES) {
Write-Host "grant control security group on database: $DB..."

sqlcmd -S $SERVER -d $DB -G -U $USER `
  -Q "GRANT CONTROL ON DATABASE::[$DB] TO [$SEC_GROUP];"
}

Write-Host "security group control on all databases"
```

```
grant control security group on database: smxcore_corp_db...
grant control security group on database: smxcore_hm2_db...
grant control security group on database: smxcore_hp2_db...
security group control on all databases
```
#### register the container app as a user to the database

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")
$CONTAINER_APP = "smxcore-app"

foreach ($DB in $DATABASES) {
Write-Host "Registering container app to database: $DB..."

sqlcmd -S $SERVER -d $DB -G -U $USER `
  -Q "CREATE USER [$CONTAINER_APP] FROM EXTERNAL PROVIDER"
}

Write-Host "container app registered to all databases"
```

```
Registering container app to database: smxcore_corp_db...
Registering container app to database: smxcore_hm2_db...
Registering container app to database: smxcore_hp2_db...
container app registered to all databases
```
#### assign container database roles

*The db_owner is optional, most likely not present in production*

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")
$CONTAINER_APP = "smxcore-app"

foreach ($DB in $DATABASES) {
Write-Host "assign container app roles to database: $DB..."

sqlcmd -S $SERVER -d $DB -G -U $USER `
  -Q "ALTER ROLE db_datareader ADD MEMBER [$CONTAINER_APP];
      ALTER ROLE db_datawriter ADD MEMBER [$CONTAINER_APP];
      ALTER ROLE db_owner ADD MEMBER [$CONTAINER_APP];"
}
Write-Host "container app roles assigned to all databases"
```

```
assign container app roles to database: smxcore_corp_db...
assign container app roles to database: smxcore_hm2_db...
assign container app roles to database: smxcore_hp2_db...
4container app roles assigned to all databases
```

### configure container app

#### set connections strings

```run-powershell
$SERVER_NAME = "smxcore-sqlsvr"
$CONTAINER_APP_NAME = "smxcore-app"
$RGroup = "smxCore-rg"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")

foreach ($DB in $DATABASES) {
Write-Host "assign connection string for database: $DB..."

$CONNECTION_STRING_NAME = $DB.ToUpper() + "_CONNECTION_STRING"
$CONNECTION_STRING_VALUE = "Server=tcp:${SERVER_NAME}.database.windows.net,1433;Initial Catalog=${DB};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication='Active Directory Default'"

az containerapp update `
  --name $CONTAINER_APP_NAME `
  --resource-group $RGroup `
  --set-env-vars "$CONNECTION_STRING_NAME=$CONNECTION_STRING_VALUE" DatabaseSettings__UseEnvironmentVariables=true
}

Write-Host "container app connection string assignment complete"
```

```
assign connection string for database: smxcore_corp_db...

/ Running ..
| Running ..
\ Running ..
- Running ..
/ Running ..
| Running ..
[K{
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/containerapps/smxcore-app",
  "identity": {
    "principalId": "d38e1941-227f-4ec7-88ba-122b283b9527",
    "tenantId": "c63aa480-a9f6-41a8-aa48-076eb398b167",
    "type": "SystemAssigned"
  },
  "location": "East US",
  "name": "smxcore-app",
  "properties": {
    "configuration": {
      "activeRevisionsMode": "Single",
      "dapr": null,
      "identitySettings": [],
      "ingress": {
        "additionalPortMappings": null,
        "allowInsecure": false,
        "clientCertificateMode": null,
        "corsPolicy": null,
        "customDomains": null,
        "exposedPort": 0,
        "external": true,
        "fqdn": "smxcore-app.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
        "ipSecurityRestrictions": null,
        "stickySessions": null,
        "targetPort": 80,
        "traffic": [
          {
            "latestRevision": true,
            "weight": 100
          }
        ],
        "transport": "Auto"
      },
      "maxInactiveRevisions": null,
      "registries": [
        {
          "identity": "system",
          "passwordSecretRef": "",
          "server": "smxcoreacr.azurecr.io",
          "username": ""
        }
      ],
      "runtime": null,
      "secrets": null,
      "service": null
    },
    "customDomainVerificationId": "E129223AD4968402387D05A8CD1C9565276C107496979A589DE87D5CDDBE63DD",
    "delegatedIdentities": [],
    "environmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "eventStreamEndpoint": "https://eastus.azurecontainerapps.dev/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/containerApps/smxcore-app/eventstream",
    "latestReadyRevisionName": "smxcore-app--0000003",
    "latestRevisionFqdn": "smxcore-app--0000003.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
    "latestRevisionName": "smxcore-app--0000003",
    "managedEnvironmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "outboundIpAddresses": [
      "20.127.248.50",
      "20.241.171.30",
      "20.169.229.88",
      "20.169.229.46",
      "20.169.229.29",
      "20.169.229.38",
      "20.169.229.62",
      "20.169.229.109",
      "20.169.229.92",
      "20.169.229.27",
      "20.169.229.51",
      "20.169.229.42",
      "20.241.172.248",
      "48.216.192.198",
      "40.90.243.232",
      "40.90.242.126",
      "135.237.112.47",
      "51.8.74.190",
      "4.157.197.142",
      "172.210.91.191",
      "172.210.90.42",
      "40.90.243.227",
      "40.90.243.72",
      "20.241.172.250",
      "52.234.235.220",
      "57.152.55.92",
      "172.212.36.156",
      "172.210.121.45",
      "172.214.2.208",
      "20.246.203.138",
      "20.246.203.140",
      "13.82.216.169",
      "13.82.216.172",
      "13.82.216.149",
      "52.170.33.171",
      "20.231.246.122",
      "20.231.246.54",
      "40.121.19.105",
      "40.121.18.246",
      "40.121.18.166",
      "40.121.18.60",
      "40.121.18.21",
      "40.121.18.44",
      "40.121.18.41",
      "40.121.18.248",
      "40.121.18.82",
      "40.121.19.108",
      "20.231.247.19",
      "40.121.19.125",
      "40.121.18.46",
      "40.117.125.130",
      "40.121.18.52",
      "40.121.18.33",
      "40.121.18.238",
      "40.121.19.2",
      "40.121.19.122",
      "40.121.19.19",
      "40.121.18.114",
      "20.231.246.253",
      "40.121.18.255",
      "40.121.18.164",
      "40.117.121.106",
      "40.121.18.27",
      "40.121.18.156",
      "40.121.18.117",
      "40.121.18.197",
      "40.121.18.133",
      "40.121.18.112",
      "40.121.18.106",
      "20.241.227.6",
      "40.121.19.89",
      "40.121.19.83",
      "40.121.18.131",
      "40.121.18.201",
      "40.121.18.170",
      "40.121.18.242",
      "13.92.130.42",
      "40.121.19.42",
      "40.121.18.73",
      "40.121.18.43",
      "20.241.226.169",
      "40.121.19.74",
      "40.121.19.40",
      "40.121.18.62",
      "40.121.18.244",
      "4.157.229.108"
    ],
    "provisioningState": "Succeeded",
    "runningStatus": "Running",
    "template": {
      "containers": [
        {
          "env": [
            {
              "name": "configuration.ingress.targetPort"
            },
            {
              "name": "SMXCORE_CORP_DB_CONNECTION_STRING"
            },
            {
              "name": "DatabaseSettings__UseEnvironmentVariables"
            }
          ],
          "image": "smxcoreacr.azurecr.io/smxcore:latest",
          "name": "smxcore-app",
          "resources": {
            "cpu": 0.5,
            "ephemeralStorage": "2Gi",
            "memory": "1Gi"
          }
        }
      ],
      "initContainers": null,
      "revisionSuffix": "",
      "scale": {
        "cooldownPeriod": 300,
        "maxReplicas": 10,
        "minReplicas": null,
        "pollingInterval": 30,
        "rules": null
      },
      "serviceBinds": null,
      "terminationGracePeriodSeconds": null,
      "volumes": null
    },
    "workloadProfileName": "Consumption"
  },
  "resourceGroup": "smxCore-rg",
  "systemData": {
    "createdAt": "2025-05-27T22:28:58.5221607",
    "createdBy": "rkrueger@vokworks.onmicrosoft.com",
    "createdByType": "User",
    "lastModifiedAt": "2025-06-01T12:30:11.8542911",
    "lastModifiedBy": "rkrueger@vokworks.onmicrosoft.com",
    "lastModifiedByType": "User"
  },
  "type": "Microsoft.App/containerApps"
}
assign connection string for database: smxcore_hm2_db...

/ Running ..
| Running ..
\ Running ..
- Running ..
/ Running ..
| Running ..
[K{
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/containerapps/smxcore-app",
  "identity": {
    "principalId": "d38e1941-227f-4ec7-88ba-122b283b9527",
    "tenantId": "c63aa480-a9f6-41a8-aa48-076eb398b167",
    "type": "SystemAssigned"
  },
  "location": "East US",
  "name": "smxcore-app",
  "properties": {
    "configuration": {
      "activeRevisionsMode": "Single",
      "dapr": null,
      "identitySettings": [],
      "ingress": {
        "additionalPortMappings": null,
        "allowInsecure": false,
        "clientCertificateMode": null,
        "corsPolicy": null,
        "customDomains": null,
        "exposedPort": 0,
        "external": true,
        "fqdn": "smxcore-app.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
        "ipSecurityRestrictions": null,
        "stickySessions": null,
        "targetPort": 80,
        "traffic": [
          {
            "latestRevision": true,
            "weight": 100
          }
        ],
        "transport": "Auto"
      },
      "maxInactiveRevisions": null,
      "registries": [
        {
          "identity": "system",
          "passwordSecretRef": "",
          "server": "smxcoreacr.azurecr.io",
          "username": ""
        }
      ],
      "runtime": null,
      "secrets": null,
      "service": null
    },
    "customDomainVerificationId": "E129223AD4968402387D05A8CD1C9565276C107496979A589DE87D5CDDBE63DD",
    "delegatedIdentities": [],
    "environmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "eventStreamEndpoint": "https://eastus.azurecontainerapps.dev/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/containerApps/smxcore-app/eventstream",
    "latestReadyRevisionName": "smxcore-app--0000003",
    "latestRevisionFqdn": "smxcore-app--0000004.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
    "latestRevisionName": "smxcore-app--0000004",
    "managedEnvironmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "outboundIpAddresses": [
      "20.127.248.50",
      "20.241.171.30",
      "20.169.229.88",
      "20.169.229.46",
      "20.169.229.29",
      "20.169.229.38",
      "20.169.229.62",
      "20.169.229.109",
      "20.169.229.92",
      "20.169.229.27",
      "20.169.229.51",
      "20.169.229.42",
      "20.241.172.248",
      "48.216.192.198",
      "40.90.243.232",
      "40.90.242.126",
      "135.237.112.47",
      "51.8.74.190",
      "4.157.197.142",
      "172.210.91.191",
      "172.210.90.42",
      "40.90.243.227",
      "40.90.243.72",
      "20.241.172.250",
      "52.234.235.220",
      "57.152.55.92",
      "172.212.36.156",
      "172.210.121.45",
      "172.214.2.208",
      "20.246.203.138",
      "20.246.203.140",
      "13.82.216.169",
      "13.82.216.172",
      "13.82.216.149",
      "52.170.33.171",
      "20.231.246.122",
      "20.231.246.54",
      "40.121.19.105",
      "40.121.18.246",
      "40.121.18.166",
      "40.121.18.60",
      "40.121.18.21",
      "40.121.18.44",
      "40.121.18.41",
      "40.121.18.248",
      "40.121.18.82",
      "40.121.19.108",
      "20.231.247.19",
      "40.121.19.125",
      "40.121.18.46",
      "40.117.125.130",
      "40.121.18.52",
      "40.121.18.33",
      "40.121.18.238",
      "40.121.19.2",
      "40.121.19.122",
      "40.121.19.19",
      "40.121.18.114",
      "20.231.246.253",
      "40.121.18.255",
      "40.121.18.164",
      "40.117.121.106",
      "40.121.18.27",
      "40.121.18.156",
      "40.121.18.117",
      "40.121.18.197",
      "40.121.18.133",
      "40.121.18.112",
      "40.121.18.106",
      "20.241.227.6",
      "40.121.19.89",
      "40.121.19.83",
      "40.121.18.131",
      "40.121.18.201",
      "40.121.18.170",
      "40.121.18.242",
      "13.92.130.42",
      "40.121.19.42",
      "40.121.18.73",
      "40.121.18.43",
      "20.241.226.169",
      "40.121.19.74",
      "40.121.19.40",
      "40.121.18.62",
      "40.121.18.244",
      "4.157.229.108"
    ],
    "provisioningState": "Succeeded",
    "runningStatus": "Running",
    "template": {
      "containers": [
        {
          "env": [
            {
              "name": "configuration.ingress.targetPort"
            },
            {
              "name": "SMXCORE_CORP_DB_CONNECTION_STRING"
            },
            {
              "name": "DatabaseSettings__UseEnvironmentVariables"
            },
            {
              "name": "SMXCORE_HM2_DB_CONNECTION_STRING"
            }
          ],
          "image": "smxcoreacr.azurecr.io/smxcore:latest",
          "name": "smxcore-app",
          "resources": {
            "cpu": 0.5,
            "ephemeralStorage": "2Gi",
            "memory": "1Gi"
          }
        }
      ],
      "initContainers": null,
      "revisionSuffix": "",
      "scale": {
        "cooldownPeriod": 300,
        "maxReplicas": 10,
        "minReplicas": null,
        "pollingInterval": 30,
        "rules": null
      },
      "serviceBinds": null,
      "terminationGracePeriodSeconds": null,
      "volumes": null
    },
    "workloadProfileName": "Consumption"
  },
  "resourceGroup": "smxCore-rg",
  "systemData": {
    "createdAt": "2025-05-27T22:28:58.5221607",
    "createdBy": "rkrueger@vokworks.onmicrosoft.com",
    "createdByType": "User",
    "lastModifiedAt": "2025-06-01T12:30:28.8696022",
    "lastModifiedBy": "rkrueger@vokworks.onmicrosoft.com",
    "lastModifiedByType": "User"
  },
  "type": "Microsoft.App/containerApps"
}
assign connection string for database: smxcore_hp2_db...

/ Running ..
| Running ..
\ Running ..
- Running ..
/ Running ..
| Running ..
[K{
  "id": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/containerapps/smxcore-app",
  "identity": {
    "principalId": "d38e1941-227f-4ec7-88ba-122b283b9527",
    "tenantId": "c63aa480-a9f6-41a8-aa48-076eb398b167",
    "type": "SystemAssigned"
  },
  "location": "East US",
  "name": "smxcore-app",
  "properties": {
    "configuration": {
      "activeRevisionsMode": "Single",
      "dapr": null,
      "identitySettings": [],
      "ingress": {
        "additionalPortMappings": null,
        "allowInsecure": false,
        "clientCertificateMode": null,
        "corsPolicy": null,
        "customDomains": null,
        "exposedPort": 0,
        "external": true,
        "fqdn": "smxcore-app.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
        "ipSecurityRestrictions": null,
        "stickySessions": null,
        "targetPort": 80,
        "traffic": [
          {
            "latestRevision": true,
            "weight": 100
          }
        ],
        "transport": "Auto"
      },
      "maxInactiveRevisions": null,
      "registries": [
        {
          "identity": "system",
          "passwordSecretRef": "",
          "server": "smxcoreacr.azurecr.io",
          "username": ""
        }
      ],
      "runtime": null,
      "secrets": null,
      "service": null
    },
    "customDomainVerificationId": "E129223AD4968402387D05A8CD1C9565276C107496979A589DE87D5CDDBE63DD",
    "delegatedIdentities": [],
    "environmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "eventStreamEndpoint": "https://eastus.azurecontainerapps.dev/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/containerApps/smxcore-app/eventstream",
    "latestReadyRevisionName": "smxcore-app--0000003",
    "latestRevisionFqdn": "smxcore-app--0000005.politebeach-58e6fb6e.eastus.azurecontainerapps.io",
    "latestRevisionName": "smxcore-app--0000005",
    "managedEnvironmentId": "/subscriptions/d6d1bfa2-3561-4cbb-8f86-19a20b032a45/resourceGroups/smxCore-rg/providers/Microsoft.App/managedEnvironments/development",
    "outboundIpAddresses": [
      "20.127.248.50",
      "20.241.171.30",
      "20.169.229.88",
      "20.169.229.46",
      "20.169.229.29",
      "20.169.229.38",
      "20.169.229.62",
      "20.169.229.109",
      "20.169.229.92",
      "20.169.229.27",
      "20.169.229.51",
      "20.169.229.42",
      "20.241.172.248",
      "48.216.192.198",
      "40.90.243.232",
      "40.90.242.126",
      "135.237.112.47",
      "51.8.74.190",
      "4.157.197.142",
      "172.210.91.191",
      "172.210.90.42",
      "40.90.243.227",
      "40.90.243.72",
      "20.241.172.250",
      "52.234.235.220",
      "57.152.55.92",
      "172.212.36.156",
      "172.210.121.45",
      "172.214.2.208",
      "20.246.203.138",
      "20.246.203.140",
      "13.82.216.169",
      "13.82.216.172",
      "13.82.216.149",
      "52.170.33.171",
      "20.231.246.122",
      "20.231.246.54",
      "40.121.19.105",
      "40.121.18.246",
      "40.121.18.166",
      "40.121.18.60",
      "40.121.18.21",
      "40.121.18.44",
      "40.121.18.41",
      "40.121.18.248",
      "40.121.18.82",
      "40.121.19.108",
      "20.231.247.19",
      "40.121.19.125",
      "40.121.18.46",
      "40.117.125.130",
      "40.121.18.52",
      "40.121.18.33",
      "40.121.18.238",
      "40.121.19.2",
      "40.121.19.122",
      "40.121.19.19",
      "40.121.18.114",
      "20.231.246.253",
      "40.121.18.255",
      "40.121.18.164",
      "40.117.121.106",
      "40.121.18.27",
      "40.121.18.156",
      "40.121.18.117",
      "40.121.18.197",
      "40.121.18.133",
      "40.121.18.112",
      "40.121.18.106",
      "20.241.227.6",
      "40.121.19.89",
      "40.121.19.83",
      "40.121.18.131",
      "40.121.18.201",
      "40.121.18.170",
      "40.121.18.242",
      "13.92.130.42",
      "40.121.19.42",
      "40.121.18.73",
      "40.121.18.43",
      "20.241.226.169",
      "40.121.19.74",
      "40.121.19.40",
      "40.121.18.62",
      "40.121.18.244",
      "4.157.229.108"
    ],
    "provisioningState": "Succeeded",
    "runningStatus": "Running",
    "template": {
      "containers": [
        {
          "env": [
            {
              "name": "configuration.ingress.targetPort"
            },
            {
              "name": "SMXCORE_CORP_DB_CONNECTION_STRING"
            },
            {
              "name": "DatabaseSettings__UseEnvironmentVariables"
            },
            {
              "name": "SMXCORE_HM2_DB_CONNECTION_STRING"
            },
            {
              "name": "SMXCORE_HP2_DB_CONNECTION_STRING"
            }
          ],
          "image": "smxcoreacr.azurecr.io/smxcore:latest",
          "name": "smxcore-app",
          "resources": {
            "cpu": 0.5,
            "ephemeralStorage": "2Gi",
            "memory": "1Gi"
          }
        }
      ],
      "initContainers": null,
      "revisionSuffix": "",
      "scale": {
        "cooldownPeriod": 300,
        "maxReplicas": 10,
        "minReplicas": null,
        "pollingInterval": 30,
        "rules": null
      },
      "serviceBinds": null,
      "terminationGracePeriodSeconds": null,
      "volumes": null
    },
    "workloadProfileName": "Consumption"
  },
  "resourceGroup": "smxCore-rg",
  "systemData": {
    "createdAt": "2025-05-27T22:28:58.5221607",
    "createdBy": "rkrueger@vokworks.onmicrosoft.com",
    "createdByType": "User",
    "lastModifiedAt": "2025-06-01T12:30:46.692098",
    "lastModifiedBy": "rkrueger@vokworks.onmicrosoft.com",
    "lastModifiedByType": "User"
  },
  "type": "Microsoft.App/containerApps"
}
container app connection string assignment complete
```
#### restart container app
# verifications

### Verify the Azure AD Admin Is Set

- Should list the Active Directory administrator

```run-powershell
az sql server ad-admin list `
  --resource-group smxCore-rg `
  --server smxcore-sqlsvr
```

And check in the master db.  Look for type `X` an Entra group.

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$DATABASE = "master"
$USER = "tbombadil@vokworks.onmicrosoft.com"

sqlcmd -S $SERVER -d $DATABASE -G -U $USER -h -1 `
  -Q "SELECT name, type FROM sys.database_principals WHERE type <> 'R';"
```

```
dbo                                                                                                                              S   
guest                                                                                                                            S   
INFORMATION_SCHEMA                                                                                                               S   
sys                                                                                                                              S   
sqlAdminGroot                                                                                                                    S   
smxcore-rg-smxcore-sqlsvr-admin                                                                                                  X   
```
### verify database users

- **Run this in `smxcore_corp_db` and other dbs**
- Common values for `type` in `sys.database_principals`:
	- **`S`** – SQL user (local to the database)
	- **`U`** – Windows user
	- **`G`** – Windows group
	- **`R`** – Database role
	- **`E`** – **External users from Azure AD**
	- `X` - External Group (Entra security group)
- - Confirm Managed Identities present for
	- administration: `tbombadil` or a `security group`
	- container app: `smxcore-app`

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")

foreach ($DB in $DATABASES) {
Write-Host "... sys.data.principals from $DB ..."

sqlcmd -S $SERVER -d $DB -G -U $USER -h -1 `
  -Q "SELECT name, type FROM sys.database_principals WHERE type <> 'R';"
}
```

```
... sys.data.principals from smxcore_corp_db ...
dbo                                                                                                                              S   
guest                                                                                                                            S   
INFORMATION_SCHEMA                                                                                                               S   
sys                                                                                                                              S   
smxcore-rg-smxcore-sqlsvr-admin                                                                                                  X   
smxcore-app                                                                                                                      E   

(6 rows affected)
... sys.data.principals from smxcore_hm2_db ...
dbo                                                                                                                              S   
guest                                                                                                                            S   
INFORMATION_SCHEMA                                                                                                               S   
sys                                                                                                                              S   
smxcore-rg-smxcore-sqlsvr-admin                                                                                                  X   
smxcore-app                                                                                                                      E   

(6 rows affected)
... sys.data.principals from smxcore_hp2_db ...
dbo                                                                                                                              S   
guest                                                                                                                            S   
INFORMATION_SCHEMA                                                                                                               S   
sys                                                                                                                              S   
smxcore-rg-smxcore-sqlsvr-admin                                                                                                  X   
smxcore-app                                                                                                                      E   

(6 rows affected)
```
### admin user has `CONTROL` permissions on the databases

- **Run this in `smxcore_corp_db` or other dbs**
- Should show **`GRANT CONTROL`** on the databases, confirming full control.

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")
$USER = "tbombadil@vokworks.onmicrosoft.com"
$SEC_GROUP = "smxcore-rg-smxcore-sqlsvr-admin"

Write-Host "... $SEC_GROUP permission ..."
foreach ($DB in $DATABASES) {
Write-Host "... on $DB ..."

sqlcmd -S $SERVER -d $DB -G -U $USER -h -1 `
  -Q "SELECT permission_name FROM sys.database_permissions WHERE grantee_principal_id = USER_ID('$SEC_GROUP');"
}
```

```
... smxcore-rg-smxcore-sqlsvr-admin permission ...
... on smxcore_corp_db ...
CONTROL                                                                                                                         
CONNECT                                                                                                                         

(2 rows affected)
... on smxcore_hm2_db ...
CONTROL                                                                                                                         
CONNECT                                                                                                                         

(2 rows affected)
... on smxcore_hp2_db ...
CONTROL                                                                                                                         
CONNECT                                                                                                                         

(2 rows affected)
```
### container app has access to databases
Verify `smxcore-app` Has Been Assigned db Roles

- **Run this in `smxcore_corp_db` or other db**
- Should show **`db_datareader`, `db_datawriter`, and optionally `db_owner`**, confirming the correct role assignments.

```run-powershell
$SERVER = "smxcore-sqlsvr.database.windows.net"
$USER = "tbombadil@vokworks.onmicrosoft.com"
$CONTAINER_APP = "smxcore-app"
$DATABASES = @("smxcore_corp_db", "smxcore_hm2_db", "smxcore_hp2_db")

foreach ($DB in $DATABASES) {
Write-Host "... $CONTAINER_APP db roles on $DB ..."

sqlcmd -S $SERVER -d $DB -G -U $USER -h -1 `
  -Q "SELECT rp.name
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
WHERE dp.name = '$CONTAINER_APP';"
}
```

```
... smxcore-app db roles on smxcore_corp_db ...
db_owner                                                                                                                        
db_datareader                                                                                                                   
db_datawriter                                                                                                                   

(3 rows affected)
... smxcore-app db roles on smxcore_hm2_db ...
db_owner                                                                                                                        
db_datareader                                                                                                                   
db_datawriter                                                                                                                   

(3 rows affected)
... smxcore-app db roles on smxcore_hp2_db ...
db_owner                                                                                                                        
db_datareader                                                                                                                   
db_datawriter                                                                                                                   

(3 rows affected)
```

### container app has updated environment variables

- should show connection strings

```run-powershell
az containerapp show `
  --name smxcore-app `
  --resource-group smxCore-rg `
  --query "properties.template.containers[*].env"
```

```
[
  [
    {
      "name": "configuration.ingress.targetPort",
      "value": "80"
    },
    {
      "name": "SMXCORE_CORP_DB_CONNECTION_STRING",
      "value": "Server=tcp:smxcore-sqlsvr.database.windows.net,1433;Initial Catalog=smxcore_corp_db;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication='Active Directory Default'"
    },
    {
      "name": "DatabaseSettings__UseEnvironmentVariables",
      "value": "true"
    },
    {
      "name": "SMXCORE_HM2_DB_CONNECTION_STRING",
      "value": "Server=tcp:smxcore-sqlsvr.database.windows.net,1433;Initial Catalog=smxcore_hm2_db;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication='Active Directory Default'"
    },
    {
      "name": "SMXCORE_HP2_DB_CONNECTION_STRING",
      "value": "Server=tcp:smxcore-sqlsvr.database.windows.net,1433;Initial Catalog=smxcore_hp2_db;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication='Active Directory Default'"
    }
  ]
]
```
### check the log for errors

- no authentication connection errors
 
```run-powershell
az containerapp logs show `
  --tail 50 `
  --name smxcore-app `
  --resource-group smxCore-rg
```

# adding app insights

```
az containerapp secret set --name smxcore-app --resource-group smxCore-rg --secrets applicationinsights-connection-string="InstrumentationKey=acda4e1a-e910-4b43-82b0-44effedcfddb;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/;ApplicationId=68a36fe0-7447-47b5-a518-335f11194b79"
```

```
az containerapp update --name smxcore-app --resource-group smxCore-rg --set-env-vars "DatabaseSettings__UseEnvironmentVariables=true" "SMXCORE_CORP_DB_CONNECTION_STRING=secretref:smxcore-corp-db-connection" "SMXCORE_HM2_DB_CONNECTION_STRING=secretref:smxcore-hm2-db-connection" "SMXCORE_HP2_DB_CONNECTION_STRING=secretref:smxcore-hp2-db-connection" "APPLICATIONINSIGHTS_CONNECTION_STRING=secretref:applicationinsights-connection-string"
```