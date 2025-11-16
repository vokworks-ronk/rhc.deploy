# Custom Domain Configuration Guide

**Purpose:** Configure custom domains for Container Apps  
**Applies to:** QA, Production environments  
**Last Updated:** November 14, 2025

---

## 📋 Overview

Each Container App can use a custom domain with automatic SSL/TLS certificate management.

**Custom Domain Pattern:**
- **SMX QA:** smx-qa.recalibratex.net
- **HP2 QA:** hp2-qa.recalibratex.net
- **SMX Production:** smx.recalibratex.net (or smx-prod.recalibratex.net)
- **HP2 Production:** hp2.recalibratex.net (or hp2-prod.recalibratex.net)

---

## 🔧 DNS Configuration Required

### Step 1: Get Verification Values

For each Container App, you need:

**SMX QA:**
```bash
# Get verification ID
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.customDomainVerificationId" -o tsv

# Get default hostname
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.configuration.ingress.fqdn" -o tsv
```

**Result:**
- Verification ID: `FB90A5FCA4BB780189A02B93C3B06A1DFC7D329F362E84C25D68E577BFB99273`
- Default hostname: `rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io`

**HP2 QA:**
```bash
# Get verification ID
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.customDomainVerificationId" -o tsv

# Get default hostname
az containerapp show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "properties.configuration.ingress.fqdn" -o tsv
```

### Step 2: Create DNS Records

In your DNS provider for `recalibratex.net`, create these records:

#### SMX QA (smx-qa.recalibratex.net)

```
# TXT record for domain verification
Name:  asuid.smx-qa
Type:  TXT
Value: FB90A5FCA4BB780189A02B93C3B06A1DFC7D329F362E84C25D68E577BFB99273
TTL:   3600

# CNAME record pointing to Container App
Name:  smx-qa
Type:  CNAME
Value: rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io
TTL:   3600
```

#### HP2 QA (hp2-qa.recalibratex.net)

```
# TXT record for domain verification
Name:  asuid.hp2-qa
Type:  TXT
Value: <HP2 verification ID from Step 1>
TTL:   3600

# CNAME record pointing to Container App
Name:  hp2-qa
Type:  CNAME
Value: <HP2 default hostname from Step 1>
TTL:   3600
```

#### SMX Production (smx.recalibratex.net)

```
# TXT record for domain verification
Name:  asuid.smx
Type:  TXT
Value: <SMX prod verification ID>
TTL:   3600

# CNAME record pointing to Container App
Name:  smx
Type:  CNAME
Value: <SMX prod default hostname>
TTL:   3600
```

#### HP2 Production (hp2.recalibratex.net)

```
# TXT record for domain verification
Name:  asuid.hp2
Type:  TXT
Value: <HP2 prod verification ID>
TTL:   3600

# CNAME record pointing to Container App
Name:  hp2
Type:  CNAME
Value: <HP2 prod default hostname>
TTL:   3600
```

### Step 3: Wait for DNS Propagation

Wait 5-15 minutes for DNS records to propagate. Verify with:

```bash
# Check TXT record
nslookup -type=TXT asuid.smx-qa.recalibratex.net

# Check CNAME record
nslookup -type=CNAME smx-qa.recalibratex.net
```

---

## 🚀 Azure Configuration

### SMX QA

```bash
# Add custom domain
az containerapp hostname add \
  --hostname "smx-qa.recalibratex.net" \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg"

# Bind with managed certificate (free SSL)
az containerapp hostname bind \
  --hostname "smx-qa.recalibratex.net" \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --environment "rhc-smx-qa-env" \
  --validation-method CNAME
```

### HP2 QA

```bash
# Add custom domain
az containerapp hostname add \
  --hostname "hp2-qa.recalibratex.net" \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg"

# Bind with managed certificate
az containerapp hostname bind \
  --hostname "hp2-qa.recalibratex.net" \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --environment "rhc-hp2-qa-env" \
  --validation-method CNAME
```

### SMX Production

```bash
# Add custom domain
az containerapp hostname add \
  --hostname "smx.recalibratex.net" \
  --name "<smx-prod-app-name>" \
  --resource-group "<smx-prod-rg>"

# Bind with managed certificate
az containerapp hostname bind \
  --hostname "smx.recalibratex.net" \
  --name "<smx-prod-app-name>" \
  --resource-group "<smx-prod-rg>" \
  --environment "<smx-prod-env>" \
  --validation-method CNAME
```

### HP2 Production

```bash
# Add custom domain
az containerapp hostname add \
  --hostname "hp2.recalibratex.net" \
  --name "<hp2-prod-app-name>" \
  --resource-group "<hp2-prod-rg>"

# Bind with managed certificate
az containerapp hostname bind \
  --hostname "hp2.recalibratex.net" \
  --name "<hp2-prod-app-name>" \
  --resource-group "<hp2-prod-rg>" \
  --environment "<hp2-prod-env>" \
  --validation-method CNAME
```

---

## 🔐 Update App Registrations

After custom domains are configured, add redirect URIs to CIAM app registrations.

### SMX QA

```bash
# Get current redirect URIs
az ad app show --id "f5c66c2e-400c-4af7-b397-c1c841504371" --query "web.redirectUris"

# Add custom domain redirect URI (if not already present)
az ad app update --id "f5c66c2e-400c-4af7-b397-c1c841504371" \
  --web-redirect-uris \
    "https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io/signin-oidc" \
    "https://smx-qa.recalibratex.net/signin-oidc"
```

### HP2 QA

```bash
# Add custom domain redirect URI
az ad app update --id "cfdc3d4b-dfe3-4414-a09d-a11a568187de" \
  --web-redirect-uris \
    "https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io/signin-oidc" \
    "https://hp2-qa.recalibratex.net/signin-oidc"
```

### SMX Production

```bash
az ad app update --id "<smx-prod-client-id>" \
  --web-redirect-uris \
    "https://<smx-prod-default-hostname>/signin-oidc" \
    "https://smx.recalibratex.net/signin-oidc"
```

### HP2 Production

```bash
az ad app update --id "<hp2-prod-client-id>" \
  --web-redirect-uris \
    "https://<hp2-prod-default-hostname>/signin-oidc" \
    "https://hp2.recalibratex.net/signin-oidc"
```

---

## ✅ Verification

### Check Custom Domain Status

```bash
# SMX QA
az containerapp hostname list \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  -o table

# HP2 QA
az containerapp hostname list \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  -o table
```

**Expected Output:**
```
BindingType    Name
-------------  -----------------------
SniEnabled     smx-qa.recalibratex.net
```

### Check Certificate Status

```bash
# SMX QA
az containerapp env certificate list \
  --name "rhc-smx-qa-env" \
  --resource-group "rhc-smx-qa-rg" \
  --query "[?contains(subjectName, 'smx-qa')]" \
  -o table

# HP2 QA
az containerapp env certificate list \
  --name "rhc-hp2-qa-env" \
  --resource-group "rhc-hp2-qa-rg" \
  --query "[?contains(subjectName, 'hp2-qa')]" \
  -o table
```

### Test HTTPS Access

```bash
# SMX QA
curl -I https://smx-qa.recalibratex.net

# HP2 QA
curl -I https://hp2-qa.recalibratex.net

# SMX Production
curl -I https://smx.recalibratex.net

# HP2 Production
curl -I https://hp2.recalibratex.net
```

**Expected:** HTTP 302 redirect to authentication (if not logged in) or HTTP 200 (if logged in)

---

## 📝 Current Status

### QA Environment

| App | Custom Domain | Status | Certificate | Updated |
|-----|---------------|--------|-------------|---------|
| SMX QA | smx-qa.recalibratex.net | ✅ Configured | Managed (auto-renewing) | Nov 14, 2025 |
| HP2 QA | hp2-qa.recalibratex.net | ⏳ Pending | - | - |

### Production Environment

| App | Custom Domain | Status | Certificate | Updated |
|-----|---------------|--------|-------------|---------|
| SMX Prod | smx.recalibratex.net | ⏳ Not configured | - | - |
| HP2 Prod | hp2.recalibratex.net | ⏳ Not configured | - | - |

---

## 🚨 Important Notes

### Certificate Provisioning Time
- **Initial setup:** Up to 20 minutes for certificate to be issued
- **Auto-renewal:** Automatic before expiration (no action needed)
- **Validation:** Uses DNS CNAME validation (TXT record required initially)

### DNS Propagation
- **Typical time:** 5-15 minutes
- **Maximum time:** Up to 48 hours (rare)
- **Verification:** Use `nslookup` or online DNS checkers

### HTTPS Only
- Custom domains automatically enforce HTTPS
- HTTP requests redirect to HTTPS
- Managed certificates are free and auto-renewing

### Multiple Domains
- Container Apps support multiple custom domains
- Each domain gets its own managed certificate
- All domains work simultaneously (no primary/secondary)

---

## 🔧 Troubleshooting

### "TXT record not found" Error

**Problem:** DNS verification failing  
**Solution:**
1. Verify TXT record exists: `nslookup -type=TXT asuid.smx-qa.recalibratex.net`
2. Wait longer for DNS propagation
3. Check DNS provider settings (some need @ or root domain specified differently)

### Certificate Stuck in "Provisioning"

**Problem:** Certificate not issuing after 20 minutes  
**Solution:**
1. Verify CNAME record points to correct Container App hostname
2. Ensure no conflicting DNS records (A records, etc.)
3. Delete and re-add the custom domain binding
4. Contact Azure support if issue persists

### Authentication Fails on Custom Domain

**Problem:** Login redirect errors  
**Solution:**
1. Verify redirect URI added to CIAM app registration
2. Check redirect URI exactly matches: `https://smx-qa.recalibratex.net/signin-oidc`
3. Wait for app registration changes to propagate (~5 minutes)

---

## 📚 Related Documentation

- **QA-CONFIGURATION-REFERENCE.md** - Complete QA configuration
- **PRODUCTION-DEPLOYMENT-CHECKLIST.md** - Production deployment steps
- **06-github-actions-qa.md** - GitHub Actions and deployment

---

**Document Version:** 1.0  
**Last Updated:** November 14, 2025  
**Status:** SMX QA custom domain configured and working
