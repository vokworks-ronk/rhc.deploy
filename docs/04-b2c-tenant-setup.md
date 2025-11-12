# 🔐 Phase 4: External ID Tenant Configuration

**Status:** 🔄 In Progress  
**Prerequisites:** ✅ QA tenant created (`rhcqa.onmicrosoft.com`)  
**Estimated Time:** 60-90 minutes

**Current Progress:** Application registrations complete, configuring authentication flows

---

## 📋 Overview

This phase configures the QA tenant (`rhcqa.onmicrosoft.com`) with Microsoft Entra External ID features:
- User authentication flows for external users
- Multi-factor authentication (MFA) enforcement
- Invitation-only user provisioning
- Custom branding (optional)
- Application registrations for HP2 and SMX
- API permissions and scopes

> **Note:** We're using **Microsoft Entra External ID**, which replaces Azure AD B2C and provides enhanced features for external user management.

**Authentication Requirements:**
- ✅ Email/password authentication
- ✅ MFA required for all users
- ✅ Invitation-only sign-up (no self-service)
- ❌ No social identity providers (initially)
- ❌ No SAML/SSO (initially)

---

## 🎯 Checklist

### Pre-Configuration
- [X] Verify QA tenant created (`rhcqa.onmicrosoft.com`)
- [X] Document tenant ID (2604fd9a-93a6-448e-bdc9-25e3c2d671a2)
- [X] Verify Global Admin access

### User Flow Configuration
- [ ] Create sign-up/sign-in user flow
- [ ] Enable MFA (required)
- [ ] Configure email verification
- [ ] Set password complexity requirements
- [ ] Configure user attributes to collect

### Application Registrations
- [X] Register HP2 QA application
- [X] Register SMX QA application
- [X] Configure redirect URIs
- [X] Configure API permissions
- [X] Create client secrets (2-year expiration)
- [X] Document App IDs and secrets

### Custom Policies (Optional)
- [ ] Configure invitation-only policy
- [ ] Customize email templates
- [ ] Add custom branding

### Conditional Access (Optional)
- [ ] Configure trusted locations
- [ ] Set up device compliance
- [ ] Configure session controls

### Verification
- [ ] Test user flow
- [ ] Test MFA enrollment
- [ ] Verify invitation flow
- [ ] Update deployment-log.md

---

## 📝 B2C Configuration Information (Fill in after setup)

### Tenant Details
- **Tenant Domain:** `rhcqa.onmicrosoft.com`
- **Tenant ID:** `2604fd9a-93a6-448e-bdc9-25e3c2d671a2`
- **Tenant Type:** Microsoft Entra External ID (CIAM)

### User Flows Created
| Flow Name | Type | MFA | Status |
|-----------|------|-----|--------|
| `B2C_1_signupsignin_qa` | Sign up and sign in | Required | ⬜ |

### Application Registrations
| Application | App ID | Client Secret (Key Vault) | Redirect URI | Status |
|-------------|--------|---------------------------|--------------|--------|
| HP2 QA | `cfdc3d4b-dfe3-4414-a09d-a11a568187de` | `hp2-qa-client-secret` | `https://hp2-qa.recalibratex.net/signin-oidc` | ✅ |
| SMX QA | `f5c66c2e-400c-4af7-b397-c1c841504371` | `smx-qa-client-secret` | `https://smx-qa.recalibratex.net/signin-oidc` | ✅ |

---

## 🔧 Step 1: Configure B2C Basics

### Via Azure Portal

1. **Switch to B2C QA Tenant**
   - Click profile icon → Switch directory
   - Select `rhc-b2c-qa.onmicrosoft.com`

2. **Navigate to Azure AD B2C**
   - Search for "Azure AD B2C" in the search bar
   - Click on the Azure AD B2C service

3. **Verify Tenant Settings**
   - Go to **Overview**
   - Note the Tenant ID
   - Verify domain: `rhc-b2c-qa.onmicrosoft.com`

---

## 🔧 Step 2: Create Sign Up and Sign In User Flow

### Via Azure Portal

1. **Navigate to User Flows**
   - In Azure AD B2C, click **User flows** in the left menu
   - Click **+ New user flow**

2. **Select User Flow Type**
   - Choose **Sign up and sign in** (recommended)
   - Version: **Recommended**
   - Click **Create**

3. **Configure User Flow Basics**
   - **Name:** `signupsignin_qa`
     - System will prefix with `B2C_1_`, so full name: `B2C_1_signupsignin_qa`
   - **Identity providers:**
     - ✅ **Email signup** (check this)
     - ❌ Uncheck social identity providers

4. **Configure MFA**
   - **Multifactor authentication:**
     - **Type:** Select **Required**
     - **Method:** 
       - ✅ Email
       - ✅ Phone (SMS)
     - **Enforcement:** Required
   
5. **Configure User Attributes**
   Select attributes to collect during sign-up:
   - ✅ Email Address (required)
   - ✅ Given Name (required)
   - ✅ Surname (required)
   - ✅ Display Name
   - ✅ Phone Number (for MFA)
   - Add custom attributes if needed (e.g., Organization, Role)

6. **Configure Application Claims**
   Select claims to return in token:
   - ✅ Email Addresses
   - ✅ Given Name
   - ✅ Surname
   - ✅ Display Name
   - ✅ User's Object ID
   - ✅ Identity Provider

7. **Create the User Flow**
   - Review all settings
   - Click **Create**
   - ⏳ Wait for user flow to be created (1-2 minutes)

### Verify User Flow

1. Click on the created user flow: `B2C_1_signupsignin_qa`
2. Click **Run user flow** (at the top)
3. **Application:** Select any (or create test app first)
4. Click **Run user flow**
5. Test the sign-up/sign-in experience
6. Verify MFA is enforced

---

## 🔧 Step 3: Configure Invitation-Only Sign-Up

By default, B2C allows anyone to sign up. For invitation-only:

### Option A: Custom Policy (Complex, Recommended for Production)

Custom policies allow full control but require XML editing. We'll document this for later.

### Option B: User Flow + Manual Approval (Simpler for QA)

1. **Keep the standard user flow**
2. **After sign-up, manually approve users**
3. **Or disable self-service sign-up and create users via:**
   - Azure Portal
   - Microsoft Graph API
   - Invitation emails

### Create Users via Portal (Invitation Flow)

1. **Navigate to Users**
   - In B2C tenant, go to **Users** → **All users**
   - Click **+ New user**

2. **Create User**
   - Select **Invite user**
   - **Email address:** Enter user's email
   - **First name:** Enter first name
   - **Last name:** Enter last name
   - **Message:** "You've been invited to Recalibrate Healthcare HP2/SMX"
   - Click **Invite**

3. **User Receives Email**
   - User clicks invitation link
   - Completes profile (password, MFA)
   - Can now sign in

### Create Users via Microsoft Graph

```powershell
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Switch to B2C tenant context
Select-MgProfile -Name "beta"

# Create invitation
$invitation = New-MgInvitation `
  -InvitedUserDisplayName "Dr. John Smith" `
  -InvitedUserEmailAddress "john.smith@example.com" `
  -InviteRedirectUrl "https://hp2-qa.recalibratex.net" `
  -SendInvitationMessage

# View invitation details
$invitation
```

---

## 🔧 Step 4: Register HP2 QA Application

### Via Azure Portal

1. **Navigate to App Registrations**
   - In B2C tenant, go to **App registrations**
   - Click **+ New registration**

2. **Register Application**
   - **Name:** `HP2 QA Application`
   - **Supported account types:**
     - Select: **Accounts in this organizational directory only (rhc-b2c-qa only - Single tenant)**
   - **Redirect URI:**
     - Platform: **Web**
     - URI: `https://hp2-qa.recalibratex.net/signin-oidc`
   - Click **Register**

3. **Note Application (Client) ID**
   - Copy the **Application (client) ID**
   - Document it in the table above

4. **Configure Authentication**
   - Click **Authentication** in left menu
   - **Front-channel logout URL:** `https://hp2-qa.recalibratex.net/signout-oidc`
   - **Implicit grant and hybrid flows:** ✅ ID tokens
   - Click **Save**

5. **Create Client Secret**
   - Click **Certificates & secrets**
   - Click **+ New client secret**
   - **Description:** `HP2 QA Client Secret`
   - **Expires:** 24 months (or custom)
   - Click **Add**
   - **⚠️ IMPORTANT:** Copy the secret **Value** immediately (you can't see it again!)
   - Document it securely (will store in Key Vault later)

6. **Configure API Permissions**
   - Click **API permissions**
   - Default Microsoft Graph permissions are fine for basic auth
   - If you need custom scopes, add them here

### Via Azure CLI (Microsoft Graph)

```bash
# Login to B2C QA tenant
az login --tenant rhc-b2c-qa.onmicrosoft.com

# Create app registration
az ad app create \
  --display-name "HP2 QA Application" \
  --sign-in-audience "AzureADMyOrg" \
  --web-redirect-uris "https://hp2-qa.recalibratex.net/signin-oidc" \
  --web-home-page-url "https://hp2-qa.recalibratex.net"

# Note the appId from output
# Create client secret
az ad app credential reset \
  --id <app-id> \
  --append \
  --years 2

# Note the password (client secret) from output
```

---

## 🔧 Step 5: Register SMX QA Application

Repeat the same process for SMX:

### Via Azure Portal

1. **App registrations** → **+ New registration**
2. **Name:** `SMX QA Application`
3. **Redirect URI:** `https://smx-qa.recalibratex.net/signin-oidc`
4. **Register** and note Application ID
5. Create client secret
6. Document both securely

---

## 🔧 Step 6: Configure Password Policies

### Via Azure Portal

1. **Navigate to User Flows**
   - Click on `B2C_1_signupsignin_qa`
   - Click **Properties**

2. **Password Configuration**
   - **Password complexity:**
     - ✅ Require at least 12 characters
     - ✅ Require lowercase letters
     - ✅ Require uppercase letters
     - ✅ Require numbers
     - ✅ Require special characters
   - **Password expiration:** 90 days (recommended for healthcare)
   - **Prevent password reuse:** Last 5 passwords
   - Click **Save**

---

## 🔧 Step 7: Configure Custom Branding (Optional)

### Add Company Branding

1. **Navigate to Company Branding**
   - In B2C tenant, search for "Company branding"
   - Click **Configure**

2. **Upload Assets**
   - **Banner logo:** Upload Recalibrate Healthcare logo (280x60px recommended)
   - **Background image:** Optional
   - **Background color:** Use brand color (#XXXXXX)
   - **Square logo:** For mobile (240x240px)

3. **Customize Text**
   - **Sign-in page text:** "Sign in to Recalibrate Healthcare"
   - **Username label:** "Email address"
   - **Password label:** "Password"

4. **Save Changes**

---

## 🔧 Step 8: Configure Email Settings

### Customize Email Templates

1. **Navigate to User Flows**
   - Click `B2C_1_signupsignin_qa`
   - Click **Languages**
   - Select **English**
   - Click **Email verification page**

2. **Customize Email Content**
   - Edit email templates for:
     - Email verification
     - Password reset
     - MFA enrollment
   - Add company logo and branding
   - Click **Save**

### Configure Custom Email Provider (Optional)

For production, use Azure Communication Services (already have `hp225dev-email-services` and `smx25dev-email`):

1. **Navigate to Azure Communication Services**
2. Link to B2C tenant for custom email domains
3. Configure SPF/DKIM records for deliverability

---

## 🔧 Step 9: Test User Flow End-to-End

### Test Sign-Up Flow

1. **Navigate to User Flows**
   - Click `B2C_1_signupsignin_qa`
   - Click **Run user flow**

2. **Test Flow**
   - Click **Run user flow**
   - Opens new browser window
   - Click **Sign up now**
   - Enter test email address
   - Fill in required fields
   - **MFA Challenge appears** ✅
   - Complete MFA enrollment
   - Sign-up completes
   - User is created

3. **Verify User Created**
   - Go back to Azure Portal
   - Navigate to **Users** → **All users**
   - Find the test user
   - Verify attributes are populated

### Test Sign-In Flow

1. **Run user flow again**
2. Sign in with test user credentials
3. **MFA Challenge appears** ✅
4. Complete MFA
5. Successfully signed in ✅

---

## 📊 Connection Configuration for Blazor Apps

### appsettings.json Configuration

#### HP2 QA Configuration

```json
{
  "AzureAdB2C": {
    "Instance": "https://rhcqa.ciamlogin.com",
    "Domain": "rhcqa.onmicrosoft.com",
    "TenantId": "2604fd9a-93a6-448e-bdc9-25e3c2d671a2",
    "ClientId": "cfdc3d4b-dfe3-4414-a09d-a11a568187de",
    "ClientSecret": "<hp2-client-secret>",
    "SignUpSignInPolicyId": "B2C_1_signupsignin_qa",
    "CallbackPath": "/signin-oidc",
    "SignedOutCallbackPath": "/signout-callback-oidc"
  },
  "ConnectionStrings": {
    "CorpDatabase": "Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=corp_db;Authentication=Active Directory Managed Identity;Encrypt=True;",
    "HP2Database": "Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=hp2_db;Authentication=Active Directory Managed Identity;Encrypt=True;"
  }
}
```

#### SMX QA Configuration

```json
{
  "AzureAdB2C": {
    "Instance": "https://rhcqa.ciamlogin.com",
    "Domain": "rhcqa.onmicrosoft.com",
    "TenantId": "2604fd9a-93a6-448e-bdc9-25e3c2d671a2",
    "ClientId": "f5c66c2e-400c-4af7-b397-c1c841504371",
    "ClientSecret": "<smx-client-secret>",
    "SignUpSignInPolicyId": "B2C_1_signupsignin_qa",
    "CallbackPath": "/signin-oidc",
    "SignedOutCallbackPath": "/signout-callback-oidc"
  },
  "ConnectionStrings": {
    "CorpDatabase": "Server=tcp:rhc-qa-sqlsvr.database.windows.net,1433;Database=corp_db;Authentication=Active Directory Managed Identity;Encrypt=True;"
  }
}
```

**⚠️ Note:** Store `ClientSecret` in Azure Key Vault, not in appsettings.json!

---

## 🔐 Security Best Practices

### 1. Store Secrets in Key Vault

Never commit secrets to source control. Use Azure Key Vault:

```csharp
// In Program.cs or Startup.cs
builder.Configuration.AddAzureKeyVault(
    new Uri($"https://{keyVaultName}.vault.azure.net/"),
    new DefaultAzureCredential());
```

### 2. Use Managed Identity

Prefer Managed Identity over client secrets for database access.

### 3. Enable Audit Logging

1. **Navigate to Diagnostic Settings**
   - In B2C tenant, go to **Monitoring** → **Diagnostic settings**
   - Click **+ Add diagnostic setting**

2. **Configure Logging**
   - **Name:** `b2c-qa-audit-logs`
   - **Logs to collect:**
     - ✅ AuditLogs
     - ✅ SignInLogs
     - ✅ NonInteractiveUserSignInLogs
   - **Destination:**
     - ✅ Send to Log Analytics workspace
     - Select workspace (create one if needed)
   - Click **Save**

### 4. Configure Token Lifetime

1. **Navigate to User Flows**
2. Click `B2C_1_signupsignin_qa`
3. Click **Properties**
4. **Token configuration:**
   - **Access token lifetime:** 60 minutes
   - **Refresh token lifetime:** 14 days
   - **Sliding window refresh token:** Enabled
5. Click **Save**

---

## 🔍 Verification Checklist

### User Flow Verification
- [ ] Sign-up flow works end-to-end
- [ ] MFA is enforced during sign-up
- [ ] MFA is enforced during sign-in
- [ ] Email verification works
- [ ] Password complexity requirements enforced
- [ ] User attributes collected correctly

### Application Registration Verification
- [ ] HP2 app registered with correct redirect URI
- [ ] SMX app registered with correct redirect URI
- [ ] Client secrets created and documented
- [ ] Application IDs documented

### Security Verification
- [ ] Audit logging enabled
- [ ] Token lifetimes configured
- [ ] Password policies configured
- [ ] MFA required for all users

---

## ⚠️ Common Issues & Troubleshooting

### Issue: "User flow test fails"

**Solution:**
1. Check all required fields are configured
2. Verify email provider is working
3. Check MFA settings aren't too restrictive
4. Review error message in browser console

### Issue: "Can't register application"

**Solution:**
1. Verify you're in the correct tenant (B2C QA)
2. Check you have Application Administrator role
3. Try again in incognito window

### Issue: "MFA not enforcing"

**Solution:**
1. Check user flow MFA setting is "Required" not "Optional"
2. Verify user flow is the latest version
3. Test with a new user (existing users may be grandfathered)

### Issue: "Redirect URI mismatch error"

**Solution:**
1. Verify redirect URI exactly matches in app registration
2. Check for http vs https
3. Check for trailing slashes
4. URIs are case-sensitive

---

## 📊 What We've Accomplished

After completing this phase:

✅ **B2C Tenant Configured:**
- User flows created with MFA enforcement
- Email/password authentication enabled
- Invitation-only user provisioning

✅ **Applications Registered:**
- HP2 QA app registered
- SMX QA app registered
- Client secrets created and documented

✅ **Security Configured:**
- MFA required for all users
- Password policies enforced
- Audit logging enabled
- Token lifetimes configured

✅ **Ready for Application Deployment:**
- Apps can authenticate users via B2C
- Configuration settings documented
- Ready to integrate with Blazor apps

---

## 📝 Update Deployment Log

```markdown
## 2025-10-XX - Phase 4: B2C Tenant Configuration

**Completed by:** Ron

### User Flows Created
- [x] B2C_1_signupsignin_qa (with MFA required)

### Applications Registered
- [x] HP2 QA Application (App ID: xxxxx)
- [x] SMX QA Application (App ID: xxxxx)
- [x] Client secrets created and stored securely

### Security Configuration
- [x] MFA enforcement enabled
- [x] Password policies configured
- [x] Audit logging enabled
- [x] Token lifetimes configured

**Status:** ✅ Complete
**Issues:** None
**Notes:** B2C tenant fully configured, ready for app deployment
```

---

## ➡️ Next Steps

Once B2C tenant is configured:

**👉 Proceed to:** `05-resource-groups-and-services.md`

This will create the Azure resources (Container Apps, Key Vault, etc.) for HP2 and SMX in the QA environment.

---

**Document Version:** 1.0  
**Last Updated:** October 27, 2025  
**Phase Status:** ⏳ Waiting for Phase 1
