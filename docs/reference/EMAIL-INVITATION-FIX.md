# Email Invitation Configuration Fix

**Date:** November 15, 2025  
**Issue:** Invitation emails showing wrong URL and need text customization

---

## Problems Identified

1. **Wrong URL in invitation link**: Email shows `smx25dev-app.agreeablemoss-80fddddc.eastus2.azurecontainerapps.io` instead of `smx-qa.recalibratex.net`
2. **Email text customization**: Need to modify the invitation email wording

---

## Root Cause

The `CsysUserMgmt.Infrastructure.Services.EntraUserInvitationService` uses this code to generate the invitation URL:

```csharp
var baseUrl = _invitationOptions.BaseUrl ?? 
    "https://smx25dev-app.agreeablemoss-80fddddc.eastus2.azurecontainerapps.io";
var invitationUrl = $"{baseUrl}/invitation/accept/{invitationToken}";
```

Since `BaseUrl` is not configured in the QA environment, it falls back to the hardcoded dev URL.

---

## Solution 1: Fix the Base URL

### Add Environment Variable to Container App

```bash
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --set-env-vars "CsysUserMgmt__Invitation__BaseUrl=https://smx-qa.recalibratex.net"
```

**⚠️ Important:** Use double underscores (`__`) for environment variables to represent the JSON hierarchy.

### Verify Configuration

After deployment, the invitation URLs will use: `https://smx-qa.recalibratex.net/invitation/accept/{token}`

---

## Solution 2: Customize Email Template Text

The email template is defined in: `smx25\src\UnwashedMasses.Infrastructure\Services\EmailTemplateService.cs`

### Current Template (Method: `CreateInvitationTemplate`)

The template includes variables that get replaced:
- `{InviterName}` - Person who sent the invitation
- `{RecipientName}` - Person receiving the invitation  
- `{CompanyName}` - Organization name ("CELERASYS")
- `{InvitationUrl}` - Automatically added by CsysUserMgmt

### How to Modify the Text

Edit the `EmailTemplateService.cs` file in lines 222-350:

**HTML Content** (lines ~230-300):
```csharp
template.HtmlContent = @"
<!DOCTYPE html>
<html>
<head>
    ...styles...
</head>
<body>
    <div class='container'>
        <div class='header'>
            <h1>🏥 Welcome to {CompanyName}</h1>
            <p>Your healthcare platform invitation</p>
        </div>
        <div class='content'>
            <h2>Hello {RecipientName}!</h2>
            
            <!-- MODIFY THIS TEXT AS NEEDED -->
            <p>You've been invited by <span class='highlight'>{InviterName}</span> to join our secure healthcare platform.</p>
            
            <p>Click the button below to accept your invitation and get started:</p>
            <a href='{InvitationUrl}' class='button'>Accept Invitation</a>

            <h3>What happens next?</h3>
            <ul>
                <li>✅ Complete your account setup</li>
                <li>🔐 Set up secure authentication</li>
                <li>📋 Access your personalized dashboard</li>
                <li>🏥 Start managing healthcare data securely</li>
            </ul>

            <p><strong>Important:</strong> This invitation link is secure and will expire soon for your protection.</p>
            
            <p>If you can't click the button, copy and paste this link into your browser:</p>
            <p style='word-break: break-all; background-color: #f8f9fa; padding: 10px; border-radius: 5px;'>{InvitationUrl}</p>
        </div>
        <div class='footer'>
            <p><strong>{CompanyName}</strong> - Secure Healthcare Platform</p>
            <p>This email was sent to you because {InviterName} invited you to join our platform.</p>
            <p>If you believe this was sent in error, please contact your administrator.</p>
        </div>
    </div>
</body>
</html>";
```

**Plain Text Content** (lines ~300-320):
```csharp
template.PlainTextContent = @"Welcome to {CompanyName}!

Hello {RecipientName}!

You've been invited by {InviterName} to join our secure healthcare platform.

Accept your invitation: {InvitationUrl}

What happens next:
✅ Complete your account setup
🔐 Set up secure authentication  
📋 Access your personalized dashboard
🏥 Start managing healthcare data securely

Important: This invitation link is secure and will expire soon for your protection.

---
{CompanyName} - Secure Healthcare Platform
This email was sent to you because {InviterName} invited you to join our platform.
If you believe this was sent in error, please contact your administrator.";
```

### Subject Line

The subject is set in line ~234:
```csharp
Subject = $"You're Invited to Join {companyName}",
```

Change this to customize the subject line.

### Example Modifications

**To change the greeting:**
```csharp
// Before:
<h2>Hello {RecipientName}!</h2>

// After (more formal):
<h2>Dear {RecipientName},</h2>

// Or (more casual):
<h2>Hi {RecipientName}!</h2>
```

**To change the invitation message:**
```csharp
// Before:
<p>You've been invited by <span class='highlight'>{InviterName}</span> to join our secure healthcare platform.</p>

// After:
<p><strong>{InviterName}</strong> has invited you to access the {CompanyName} healthcare management system.</p>
```

**To modify the button text:**
```csharp
// Before:
<a href='{InvitationUrl}' class='button'>Accept Invitation</a>

// After:
<a href='{InvitationUrl}' class='button'>Get Started</a>
```

---

## Testing After Changes

### 1. Update Container App Configuration

```bash
# Add BaseUrl configuration
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --set-env-vars "CsysUserMgmt__Invitation__BaseUrl=https://smx-qa.recalibratex.net"
```

This will create a new revision. Wait for it to deploy.

### 2. If You Modified the Email Template

If you changed `EmailTemplateService.cs`, you need to:

1. Commit changes to Git
2. Push to `qa` branch
3. GitHub Actions will automatically build and deploy

Or manually deploy:
```bash
cd C:\Users\rrkru\local\wip\rhc\smx25

# Build new image
docker build -t smx25:latest .

# Tag for ACR
docker tag smx25:latest <your-acr>.azurecr.io/smx25:latest

# Push to ACR
docker push <your-acr>.azurecr.io/smx25:latest

# Container App will auto-update if configured for continuous deployment
```

### 3. Test the Invitation

Send a test invitation and verify:

✅ Email subject line is correct  
✅ Invitation button link uses `https://smx-qa.recalibratex.net/invitation/accept/...`  
✅ Copy/paste link also uses `https://smx-qa.recalibratex.net/invitation/accept/...`  
✅ Email text matches your customizations  
✅ Clicking the button takes you to the correct QA environment  

---

## Configuration Reference

### Complete CsysUserMgmt Configuration Section

Add to appsettings.json or environment variables:

```json
{
  "CsysUserMgmt": {
    "Invitation": {
      "ExpirationDays": 1,
      "BaseUrl": "https://smx-qa.recalibratex.net",
      "SenderDisplayName": "CELERASYS Administrator"
    }
  }
}
```

### As Environment Variables

```bash
CsysUserMgmt__Invitation__ExpirationDays=1
CsysUserMgmt__Invitation__BaseUrl=https://smx-qa.recalibratex.net
CsysUserMgmt__Invitation__SenderDisplayName=CELERASYS Administrator
```

---

## For Production Deployment

When deploying to production, use the production domain:

```bash
az containerapp update \
  --name "rhc-smx-prod-app" \
  --resource-group "rhc-smx-prod-rg" \
  --set-env-vars "CsysUserMgmt__Invitation__BaseUrl=https://smx.recalibratex.net"
```

---

## Additional Notes

### Where Invitation is Sent

The invitation is sent from:
- **Code**: `CsysUserMgmt.Infrastructure.Services.EntraUserInvitationService.SendInvitationAsync()`
- **Called by**: `InvitationController.SendInvitation()` in your SMX app
- **Template**: `UnwashedMasses.Infrastructure.Services.EmailTemplateService.CreateInvitationTemplate()`

### Template Variables Available

You can use these variables in your email template:
- `{InviterName}` - Populated from the user who sends the invitation
- `{RecipientName}` - Populated from the `displayName` parameter
- `{CompanyName}` - Currently hardcoded to "CELERASYS" (can be made configurable)
- `{InvitationUrl}` - Automatically added by CsysUserMgmt service

### Company Name Customization

The company name is passed when calling `CreateInvitationTemplate()`. To make it configurable:

1. Add to appsettings.json:
```json
{
  "CompanyInfo": {
    "Name": "CELERASYS",
    "FullName": "CELERASYS Healthcare Platform"
  }
}
```

2. Inject `IConfiguration` and read the value when creating the template

---

## Summary of Changes Needed

**Immediate (No Code Changes):**
1. ✅ Add `CsysUserMgmt__Invitation__BaseUrl` environment variable

**Optional (Code Changes):**
2. ⚠️ Modify `EmailTemplateService.cs` for custom text
3. ⚠️ Update subject line if desired
4. ⚠️ Make company name configurable (optional)

**After making changes:**
- Commit and push to Git (for code changes)
- GitHub Actions will deploy automatically
- Test with a real invitation email
