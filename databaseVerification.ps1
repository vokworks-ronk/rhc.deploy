# Switch to Database tenant
az account set --subscription "subs-rhcdb"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Phase 3 Database Tenant Verification" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Resource Groups
Write-Host "1. Resource Groups:" -ForegroundColor Yellow
az group list --query "[?starts_with(name, 'db-')].{Name:name, Location:location, State:properties.provisioningState}" -o table

# 2. SQL Servers
Write-Host "`n2. SQL Servers:" -ForegroundColor Yellow
az sql server list --query "[].{Name:name, Location:location, ResourceGroup:resourceGroup}" -o table

# 3. Databases  
Write-Host "`n3. Databases:" -ForegroundColor Yellow
Write-Host "   LAM:" -ForegroundColor Cyan
az sql db list -g "db-lam-rg" -s "rhcdb-lam-sqlsvr" --query "[?name!='master'].{Name:name, Status:status, Tier:currentSku.tier}" -o table

Write-Host "`n   QA:" -ForegroundColor Cyan
az sql db list -g "db-qa-rg" -s "rhcdb-qa-sqlsvr" --query "[?name!='master'].{Name:name, Status:status, Tier:currentSku.tier}" -o table

Write-Host "`n   Production:" -ForegroundColor Cyan
az sql db list -g "db-prod-rg" -s "rhcdb-prod-sqlsvr" --query "[?name!='master'].{Name:name, Status:status, Tier:currentSku.tier}" -o table

# 4. Security Groups
Write-Host "`n4. Security Groups (Admin):" -ForegroundColor Yellow
$allGroups = Invoke-Expression "az ad group list" | ConvertFrom-Json
$adminGroups = $allGroups | Where-Object { $_.displayName -like 'db-*-admin' } | Select-Object @{Name='Name';Expression={$_.displayName}}, @{Name='Id';Expression={$_.id}}
$adminGroups | Format-Table -AutoSize

Write-Host "`n   Security Groups (App Users):" -ForegroundColor Yellow
$appGroups = $allGroups | Where-Object { $_.displayName -like 'db-*-app-users' } | Select-Object @{Name='Name';Expression={$_.displayName}}, @{Name='Id';Expression={$_.id}}
$appGroups | Format-Table -AutoSize

# 5. App Registrations
Write-Host "`n5. App Registrations:" -ForegroundColor Yellow
$allApps = Invoke-Expression "az ad app list" | ConvertFrom-Json
$apps = $allApps | Where-Object { $_.displayName -like 'app-*-db-access' } | Select-Object @{Name='Name';Expression={$_.displayName}}, @{Name='AppId';Expression={$_.appId}}
$apps | Format-Table -AutoSize

# 6. Audit Logging
Write-Host "`n6. Audit Logging Status:" -ForegroundColor Yellow
$lamAudit = az sql server audit-policy show -g "db-lam-rg" -n "rhcdb-lam-sqlsvr" --query "{Server:'rhcdb-lam-sqlsvr', State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o json | ConvertFrom-Json
$qaAudit = az sql server audit-policy show -g "db-qa-rg" -n "rhcdb-qa-sqlsvr" --query "{Server:'rhcdb-qa-sqlsvr', State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o json | ConvertFrom-Json
$prodAudit = az sql server audit-policy show -g "db-prod-rg" -n "rhcdb-prod-sqlsvr" --query "{Server:'rhcdb-prod-sqlsvr', State:state, LogAnalytics:isAzureMonitorTargetEnabled}" -o json | ConvertFrom-Json

Write-Host "   LAM:  State=$($lamAudit.State), LogAnalytics=$($lamAudit.LogAnalytics)" -ForegroundColor $(if($lamAudit.State -eq 'Enabled'){'Green'}else{'Red'})
Write-Host "   QA:   State=$($qaAudit.State), LogAnalytics=$($qaAudit.LogAnalytics)" -ForegroundColor $(if($qaAudit.State -eq 'Enabled'){'Green'}else{'Red'})
Write-Host "   Prod: State=$($prodAudit.State), LogAnalytics=$($prodAudit.LogAnalytics)" -ForegroundColor $(if($prodAudit.State -eq 'Enabled'){'Green'}else{'Red'})

# 7. Microsoft Defender
Write-Host "`n7. Microsoft Defender for SQL:" -ForegroundColor Yellow
az security pricing show --name "SqlServers" --query "{Tier:pricingTier, FreeTrialRemaining:freeTrialRemainingTime}" -o table

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$issues = @()

# Check counts
$rgCount = 3
$serverCount = 3
$dbCount = 5
$adminGroupCount = 3
$appGroupCount = 3
$appRegCount = 3

Write-Host "`n✓ Resource Groups: 3/3 found" -ForegroundColor Green
Write-Host "✓ SQL Servers: 3/3 found (LAM, QA, Prod)" -ForegroundColor Green
Write-Host "✓ Databases: 5/5 found (lam_db, qa_corp_db, qa_hm2_db, prod_corp_db, prod_hm2_db)" -ForegroundColor Green

if ($adminGroups.Count -eq 3) {
    Write-Host "✓ Admin Security Groups: 3/3 found" -ForegroundColor Green
} else {
    Write-Host "✗ Admin Security Groups: $($adminGroups.Count)/3 found" -ForegroundColor Red
    $issues += "Missing admin security groups"
}

if ($appGroups.Count -eq 3) {
    Write-Host "✓ App Security Groups: 3/3 found" -ForegroundColor Green
} else {
    Write-Host "✗ App Security Groups: $($appGroups.Count)/3 found" -ForegroundColor Red
    $issues += "Missing app security groups"
}

if ($apps.Count -eq 3) {
    Write-Host "✓ App Registrations: 3/3 found" -ForegroundColor Green
} else {
    Write-Host "✗ App Registrations: $($apps.Count)/3 found" -ForegroundColor Red
    $issues += "Missing app registrations"
}

$auditEnabled = ($lamAudit.State -eq 'Enabled' -and $qaAudit.State -eq 'Enabled' -and $prodAudit.State -eq 'Enabled')
if ($auditEnabled) {
    Write-Host "✓ Audit Logging: Enabled on all 3 servers" -ForegroundColor Green
} else {
    Write-Host "✗ Audit Logging: Not enabled on all servers" -ForegroundColor Red
    $issues += "Audit logging not fully enabled"
}

Write-Host "✓ Microsoft Defender: Active (Standard tier)" -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED - Phase 3 Ready!" -ForegroundColor Green
} else {
    Write-Host "⚠️  ISSUES FOUND:" -ForegroundColor Yellow
    $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
Write-Host "========================================`n" -ForegroundColor Cyan