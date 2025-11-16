# Backup Azure Container App Environment Variables
# Use this BEFORE making any changes to environment variables

param(
    [Parameter(Mandatory=$true)]
    [string]$AppName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet('smx-dev', 'smx-qa', 'smx-prod', 'hp2-dev', 'hp2-qa', 'hp2-prod')]
    [string]$Environment
)

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupFile = "deployments/$Environment/env-vars-backup-$timestamp.json"

Write-Host "🔄 Backing up environment variables..." -ForegroundColor Cyan
Write-Host "   App: $AppName" -ForegroundColor Gray
Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor Gray
Write-Host "   Environment: $Environment" -ForegroundColor Gray

# Create directory if it doesn't exist
$backupDir = Split-Path $backupFile -Parent
if (!(Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
}

# Backup environment variables
try {
    az containerapp show `
        --name $AppName `
        --resource-group $ResourceGroup `
        --query "properties.template.containers[0].env" `
        -o json > $backupFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Backup saved: $backupFile" -ForegroundColor Green
        
        # Show what was backed up
        $envVars = Get-Content $backupFile | ConvertFrom-Json
        Write-Host "   Backed up $($envVars.Count) environment variables" -ForegroundColor Gray
        
        # Offer to commit
        Write-Host ""
        $commit = Read-Host "Commit backup to git? (y/n)"
        if ($commit -eq 'y') {
            git add $backupFile
            git commit -m "Backup $Environment env vars before changes - $timestamp"
            Write-Host "✅ Backup committed to git" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "✅ Safe to proceed with changes" -ForegroundColor Green
        Write-Host "   Use: az containerapp update --set-env-vars (NOT --replace-env-vars)" -ForegroundColor Yellow
    }
    else {
        Write-Host "❌ Failed to backup environment variables" -ForegroundColor Red
        Write-Host "   DO NOT PROCEED with changes" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host "   DO NOT PROCEED with changes" -ForegroundColor Red
    exit 1
}
