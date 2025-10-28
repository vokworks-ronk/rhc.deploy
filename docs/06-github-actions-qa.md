# 🚀 Phase 6: GitHub Actions CI/CD for QA

**Status:** ⏳ Waiting for Phase 5  
**Prerequisites:** QA infrastructure created, repositories ready  
**Estimated Time:** 60-90 minutes

---

## 📋 Overview

This phase sets up automated deployment from GitHub to QA environment:

**Repositories:**
- `vokworks-ronk/hp225` → HP2 QA deployment
- `vokworks-ronk/smx25` → SMX QA deployment

**Deployment Flow:**
1. Push to `qa` branch in GitHub
2. GitHub Actions triggers
3. Build Docker image
4. Push to Container Registry (SMX) or GitHub Container Registry (HP2)
5. Deploy to Container Apps
6. Run smoke tests (optional)

**Security:**
- Use GitHub Secrets for credentials
- Deploy using Managed Identity where possible
- Minimal permission service principals

---

## 🎯 Checklist

### Pre-Configuration
- [ ] Verify Phase 5 complete (all resources created)
- [ ] Access to GitHub repositories
- [ ] Azure credentials for GitHub Actions

### GitHub Secrets Configuration
- [ ] Create service principal for deployments
- [ ] Store Azure credentials in GitHub Secrets
- [ ] Store ACR credentials (for SMX)
- [ ] Store Container App names and resource groups

### HP2 GitHub Actions
- [ ] Create/update `.github/workflows/deploy-qa.yml`
- [ ] Configure Docker build
- [ ] Configure Container App deployment
- [ ] Test deployment

### SMX GitHub Actions
- [ ] Create/update `.github/workflows/deploy-qa.yml`
- [ ] Configure Docker build
- [ ] Push to Azure Container Registry
- [ ] Configure Container App deployment
- [ ] Test deployment

### Branch Protection (Optional)
- [ ] Require PR reviews before merging to `qa`
- [ ] Require status checks to pass
- [ ] Configure CODEOWNERS

### Verification
- [ ] Test HP2 deployment from GitHub
- [ ] Test SMX deployment from GitHub
- [ ] Verify apps accessible at URLs
- [ ] Update deployment-log.md

---

## 🔧 Step 1: Create Service Principal for Deployments

We need a service principal that GitHub Actions will use to deploy.

### Create Service Principal

```bash
# Login to B2C QA tenant
az login --tenant rhc-b2c-qa.onmicrosoft.com
az account set --subscription "rhc-b2c-qa-sub"

# Create service principal with Contributor role on both resource groups
az ad sp create-for-rbac \
  --name "github-actions-qa-deployer" \
  --role "Contributor" \
  --scopes \
    "/subscriptions/<subscription-id>/resourceGroups/rhc-hp2-qa-rg" \
    "/subscriptions/<subscription-id>/resourceGroups/rhc-smx-qa-rg" \
  --sdk-auth

# Output will be JSON like:
# {
#   "clientId": "xxxxx",
#   "clientSecret": "xxxxx",
#   "subscriptionId": "xxxxx",
#   "tenantId": "xxxxx",
#   "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
#   "resourceManagerEndpointUrl": "https://management.azure.com/",
#   ...
# }

# SAVE THIS ENTIRE JSON OUTPUT - needed for GitHub Secrets
```

### Grant ACR Push Permission (for SMX)

```bash
# Get service principal ID
$spId = az ad sp list --display-name "github-actions-qa-deployer" --query "[0].id" -o tsv

# Grant AcrPush role for SMX Container Registry
az role assignment create \
  --assignee $spId \
  --role "AcrPush" \
  --scope "/subscriptions/<subscription-id>/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.ContainerRegistry/registries/rhcsmxqaacr"
```

---

## 🔧 Step 2: Configure GitHub Secrets

### For HP2 Repository (`hp225`)

1. Go to: https://github.com/vokworks-ronk/hp225
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS_QA` | (entire JSON from service principal creation) | Azure credentials |
| `AZURE_SUBSCRIPTION_ID` | `<subscription-id>` | B2C QA subscription |
| `HP2_QA_RG` | `rhc-hp2-qa-rg` | Resource group name |
| `HP2_QA_APP_NAME` | `rhc-hp2-qa-app` | Container App name |
| `B2C_CLIENT_SECRET` | (from Phase 4) | B2C client secret |

### For SMX Repository (`smx25`)

1. Go to: https://github.com/vokworks-ronk/smx25
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add these secrets:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CREDENTIALS_QA` | (same JSON from service principal) | Azure credentials |
| `AZURE_SUBSCRIPTION_ID` | `<subscription-id>` | B2C QA subscription |
| `SMX_QA_RG` | `rhc-smx-qa-rg` | Resource group name |
| `SMX_QA_APP_NAME` | `rhc-smx-qa-app` | Container App name |
| `ACR_NAME` | `rhcsmxqaacr` | Container Registry name |
| `B2C_CLIENT_SECRET` | (from Phase 4) | B2C client secret |

---

## 🔧 Step 3: Create HP2 GitHub Actions Workflow

### Create `.github/workflows/deploy-qa.yml` in HP2 repository

```yaml
name: Deploy HP2 to QA

on:
  push:
    branches:
      - qa
  workflow_dispatch:  # Manual trigger

env:
  AZURE_CONTAINERAPP_NAME: ${{ secrets.HP2_QA_APP_NAME }}
  AZURE_RESOURCE_GROUP: ${{ secrets.HP2_QA_RG }}
  IMAGE_NAME: hp2-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'  # Adjust to your version
        
    - name: Restore dependencies
      run: dotnet restore
      
    - name: Build
      run: dotnet build --configuration Release --no-restore
      
    - name: Test
      run: dotnet test --no-build --verbosity normal
      
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_QA }}
        
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ghcr.io/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:qa-${{ github.sha }}
        cache-from: type=registry,ref=ghcr.io/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:buildcache
        cache-to: type=registry,ref=ghcr.io/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:buildcache,mode=max
        
    - name: Deploy to Azure Container Apps
      uses: azure/container-apps-deploy-action@v1
      with:
        containerAppName: ${{ env.AZURE_CONTAINERAPP_NAME }}
        resourceGroup: ${{ env.AZURE_RESOURCE_GROUP }}
        imageToDeploy: ghcr.io/${{ github.repository_owner }}/${{ env.IMAGE_NAME }}:qa-${{ github.sha }}
        
    - name: Get Container App URL
      run: |
        URL=$(az containerapp show \
          --name ${{ env.AZURE_CONTAINERAPP_NAME }} \
          --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
          --query properties.configuration.ingress.fqdn -o tsv)
        echo "::notice::HP2 QA deployed to https://$URL"
        
    - name: Azure Logout
      if: always()
      run: az logout
```

### Create Dockerfile in HP2 repository root (if not exists)

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore
COPY ["HP2.csproj", "./"]
RUN dotnet restore "HP2.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "HP2.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "HP2.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Copy published app
COPY --from=publish /app/publish .

# Set environment
ENV ASPNETCORE_URLS=http://+:80

ENTRYPOINT ["dotnet", "HP2.dll"]
```

---

## 🔧 Step 4: Create SMX GitHub Actions Workflow

### Create `.github/workflows/deploy-qa.yml` in SMX repository

```yaml
name: Deploy SMX to QA

on:
  push:
    branches:
      - qa
  workflow_dispatch:

env:
  AZURE_CONTAINERAPP_NAME: ${{ secrets.SMX_QA_APP_NAME }}
  AZURE_RESOURCE_GROUP: ${{ secrets.SMX_QA_RG }}
  ACR_NAME: ${{ secrets.ACR_NAME }}
  IMAGE_NAME: smx-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.0.x'
        
    - name: Restore dependencies
      run: dotnet restore
      
    - name: Build
      run: dotnet build --configuration Release --no-restore
      
    - name: Test
      run: dotnet test --no-build --verbosity normal
      
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS_QA }}
        
    - name: Log in to Azure Container Registry
      run: |
        az acr login --name ${{ env.ACR_NAME }}
        
    - name: Build and push Docker image to ACR
      run: |
        docker build -t ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:qa-${{ github.sha }} .
        docker push ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:qa-${{ github.sha }}
        
    - name: Deploy to Azure Container Apps
      uses: azure/container-apps-deploy-action@v1
      with:
        containerAppName: ${{ env.AZURE_CONTAINERAPP_NAME }}
        resourceGroup: ${{ env.AZURE_RESOURCE_GROUP }}
        imageToDeploy: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE_NAME }}:qa-${{ github.sha }}
        
    - name: Get Container App URL
      run: |
        URL=$(az containerapp show \
          --name ${{ env.AZURE_CONTAINERAPP_NAME }} \
          --resource-group ${{ env.AZURE_RESOURCE_GROUP }} \
          --query properties.configuration.ingress.fqdn -o tsv)
        echo "::notice::SMX QA deployed to https://$URL"
        
    - name: Azure Logout
      if: always()
      run: az logout
```

### Create Dockerfile in SMX repository root (if not exists)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["SMX.csproj", "./"]
RUN dotnet restore "SMX.csproj"

COPY . .
RUN dotnet build "SMX.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SMX.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:80

ENTRYPOINT ["dotnet", "SMX.dll"]
```

---

## 🔧 Step 5: Create QA Branches

### In HP2 Repository

```bash
# Clone repository
git clone https://github.com/vokworks-ronk/hp225.git
cd hp225

# Create qa branch from main/master
git checkout -b qa
git push -u origin qa
```

### In SMX Repository

```bash
# Clone repository
git clone https://github.com/vokworks-ronk/smx25.git
cd smx25

# Create qa branch
git checkout -b qa
git push -u origin qa
```

---

## 🔧 Step 6: Test Deployments

### Test HP2 Deployment

```bash
# In hp225 repository
git checkout qa

# Make a small change (e.g., update README)
echo "# QA Deployment Test" >> README.md
git add README.md
git commit -m "Test QA deployment"
git push origin qa

# Watch GitHub Actions:
# Go to: https://github.com/vokworks-ronk/hp225/actions
# Watch the workflow run
```

### Test SMX Deployment

```bash
# In smx25 repository
git checkout qa

# Make a small change
echo "# QA Deployment Test" >> README.md
git add README.md
git commit -m "Test QA deployment"
git push origin qa

# Watch GitHub Actions:
# Go to: https://github.com/vokworks-ronk/smx25/actions
```

---

## 🔧 Step 7: Configure Custom Domains

Once deployments work, configure custom domains.

### Add Custom Domain to HP2

```bash
# Add custom domain to Container App
az containerapp hostname add \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --hostname "hp2-qa.recalibratex.net"

# Get validation TXT record
az containerapp hostname list \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg"

# Add TXT record to DNS (recalibratex.net)
# Record type: TXT
# Name: asuid.hp2-qa
# Value: (from command above)

# Add CNAME record
# Record type: CNAME
# Name: hp2-qa
# Value: rhc-hp2-qa-app.<random>.eastus2.azurecontainerapps.io

# Wait for DNS propagation (5-15 minutes)

# Bind certificate (Container Apps auto-generates free managed certificate)
az containerapp hostname bind \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --hostname "hp2-qa.recalibratex.net" \
  --environment "rhc-hp2-qa-env" \
  --validation-method CNAME
```

### Add Custom Domain to SMX

```bash
# Same process for SMX
az containerapp hostname add \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --hostname "smx-qa.recalibratex.net"

# Add DNS records for smx-qa.recalibratex.net
# Then bind certificate
az containerapp hostname bind \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --hostname "smx-qa.recalibratex.net" \
  --environment "rhc-smx-qa-env" \
  --validation-method CNAME
```

### Update B2C Redirect URIs

After custom domains are working:

1. Go to Azure Portal → B2C QA Tenant
2. **App registrations** → **HP2 QA Application**
3. **Authentication** → Add redirect URI:
   - `https://hp2-qa.recalibratex.net/signin-oidc`
4. Repeat for SMX:
   - `https://smx-qa.recalibratex.net/signin-oidc`

---

## 🔧 Step 8: Add Health Checks (Optional but Recommended)

### Add Health Check Endpoint to Apps

In your Blazor app's `Program.cs`:

```csharp
app.MapHealthChecks("/health");
```

### Configure Container App Health Probes

```bash
# Update HP2 with health probe
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --health-probe-path "/health" \
  --health-probe-interval 30 \
  --health-probe-timeout 5 \
  --health-probe-failure-threshold 3

# Same for SMX
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --health-probe-path "/health" \
  --health-probe-interval 30 \
  --health-probe-timeout 5 \
  --health-probe-failure-threshold 3
```

---

## 🔍 Verification Steps

### 1. Check GitHub Actions Status

- [ ] HP2 workflow runs successfully
- [ ] SMX workflow runs successfully
- [ ] No errors in build/deploy steps
- [ ] Deployment completes in < 10 minutes

### 2. Verify Applications Are Running

```bash
# Check HP2 status
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.runningStatus" -o tsv

# Should return: "Running"

# Check SMX status
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.runningStatus" -o tsv
```

### 3. Test Application URLs

```bash
# Test HP2
curl https://hp2-qa.recalibratex.net/health

# Test SMX
curl https://smx-qa.recalibratex.net/health
```

### 4. Test End-to-End Authentication

1. Open `https://hp2-qa.recalibratex.net` in browser
2. Should redirect to B2C login
3. Sign in with test user
4. MFA challenge appears
5. Successfully authenticated and redirected back
6. Repeat for SMX

### 5. Verify Database Connectivity

Check Container App logs to ensure database connections work:

```bash
# View HP2 logs
az containerapp logs show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --tail 50

# Look for successful database connections
```

---

## 🔄 Deployment Workflow Summary

```
┌─────────────────┐
│  Developer      │
│  Pushes to QA   │
│  branch         │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GitHub Actions │
│  Triggered      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build & Test   │
│  .NET App       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build Docker   │
│  Image          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Push to        │
│  Registry       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deploy to      │
│  Container App  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Health Check   │
│  Verify         │
└─────────────────┘
```

---

## ⚠️ Common Issues & Troubleshooting

### Issue: "Authentication failed" in GitHub Actions

**Solution:**
- Verify `AZURE_CREDENTIALS_QA` secret is correct
- Check service principal hasn't expired
- Verify service principal has Contributor role

### Issue: "ACR login failed"

**Solution:**
- Check ACR name is correct
- Verify service principal has AcrPush role
- Try regenerating ACR admin credentials

### Issue: "Container App deployment timeout"

**Solution:**
- Check Container App logs for errors
- Verify Docker image builds correctly
- Check health probe isn't failing

### Issue: "Custom domain not working"

**Solution:**
- Verify DNS records propagated (use `nslookup` or `dig`)
- Check TXT record is correct
- Wait 15-30 minutes for DNS propagation
- Verify CNAME points to correct Container App URL

---

## 📊 What We've Accomplished

After completing this phase:

✅ **CI/CD Pipeline Configured:**
- GitHub Actions workflows for HP2 and SMX
- Automated build, test, and deployment
- Push to QA branch triggers deployment

✅ **Deployment Automation:**
- Docker images built automatically
- Pushed to registries (ACR/GHCR)
- Deployed to Container Apps

✅ **Custom Domains:**
- hp2-qa.recalibratex.net configured
- smx-qa.recalibratex.net configured
- HTTPS with managed certificates

✅ **Fully Automated QA:**
- Code changes automatically deployed
- No manual deployment steps needed
- Fast feedback loop for testing

---

## 📝 Update Deployment Log

```markdown
## 2025-10-XX - Phase 6: GitHub Actions CI/CD

**Completed by:** Ron

### GitHub Actions Configured
- [x] HP2 workflow: deploy-qa.yml
- [x] SMX workflow: deploy-qa.yml
- [x] GitHub Secrets configured
- [x] Service principal created for deployments

### Deployments Working
- [x] HP2 deploying automatically on push to qa branch
- [x] SMX deploying automatically on push to qa branch
- [x] Custom domains configured
- [x] HTTPS working with managed certificates

**HP2 QA URL:** https://hp2-qa.recalibratex.net
**SMX QA URL:** https://smx-qa.recalibratex.net

**Status:** ✅ Complete
**Notes:** Full CI/CD pipeline operational, QA environment fully automated
```

---

## ➡️ Next Steps

Once CI/CD is working:

**👉 Proceed to:** `07-security-and-compliance.md`

This will review security configurations and compliance requirements (HIPAA, PCI-DSS).

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** ⏳ Waiting for Phase 5
