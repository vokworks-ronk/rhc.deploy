# Application Branding and Build Info Enhancement

## Problem Statement

Currently, the application displays hardcoded values for the application name and version:
- **NavMenu (upper left)**: "smxCore" 
- **MainLayout (top right)**: "smxCore v1.0"
- **Home page (main heading)**: "Welcome to smxCore"
- **PageTitle (browser tab)**: "Home - smxCore"

This creates issues when deploying to different environments (Dev, QA, Production) and for different applications (SMX, HP2):
1. **Confusion**: All environments show the same name, making it unclear which environment you're viewing
2. **Lost confidence**: Can't quickly verify which version/build is actually deployed
3. **Manual changes required**: Need code changes to brand each application differently

## Proposed Solution

Implement a two-tier information display system:

### 1. Soft Configuration (Runtime) - Environment Branding
Use environment variables to configure application-specific branding:
- **Application Name**: Changes per environment (SMX QA, SMX Production, HP2 QA, etc.)
- **Version Number**: Semantic version (1.0, 2.0, etc.)

### 2. Hard Build Info (Compile-time) - Deployment Traceability  
Embed build-time constants that provide absolute confidence in what's deployed:
- **Git Commit SHA**: Short hash (7 characters) - exact code version
- **Build Number**: From GitHub Actions run number
- **Build Timestamp**: Already implemented

## Visual Changes

### Current Display

**Upper left corner (NavMenu):**
```
smxCore
```

**Top right area (MainLayout):**
```
smxCore v1.0
Build #7 - 2025-11-15 00:41:33 UTC
```

**Home page:**
```
Welcome to smxCore
A secure platform for healthcare data management and research.
```

**Browser tab:**
```
Home - smxCore
```

### Proposed Display

**Upper left corner (NavMenu):**
```
SMX QA
```

**Top right area (MainLayout):**
```
SMX QA v1.0 | Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC
```

Or more compact alternative:
```
SMX QA v1.0
Build #7 (a1b2c3d) | 2025-11-15 00:41:33 UTC
```

**Home page:**
```
Welcome to SMX QA
A secure platform for healthcare data management and research.
```

**Browser tab:**
```
Home - SMX QA
```

## Examples Per Environment

| Environment | Upper Left (NavMenu) | Top Right (MainLayout) |
|-------------|---------------------|------------------------|
| **SMX Dev** | `SMX Dev` | `SMX Dev v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |
| **SMX QA** | `SMX QA` | `SMX QA v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |
| **SMX Production** | `SMX Production` | `SMX Production v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |
| **HP2 Dev** | `HP2 Dev` | `HP2 Dev v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |
| **HP2 QA** | `HP2 QA` | `HP2 QA v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |
| **HP2 Production** | `HP2 Production` | `HP2 Production v1.0 \| Build #7 (a1b2c3d) - 2025-11-15 00:41:33 UTC` |

## Benefits

### 1. **Immediate Environment Identification**
- No confusion about which environment you're viewing
- Clear visual distinction between Dev, QA, and Production
- Prevents accidental changes in wrong environment

### 2. **Deployment Confidence**
- Git commit SHA provides exact code version deployed
- Can immediately locate exact commit in GitHub repository
- Build number provides deployment sequence tracking
- Timestamp shows when the build was created

### 3. **Debugging & Support**
- Support team can quickly identify: "What version is running?"
- Developers can trace issues to exact commit
- No ambiguity about deployed code

### 4. **Flexibility Without Rebuilds**
- Change branding via environment variables (no code rebuild needed)
- Same Docker image can be branded differently per environment
- Easier to manage multiple applications from same codebase

### 5. **Compliance & Audit**
- Clear audit trail of what code is running where
- Satisfies requirements for change tracking
- Version history is traceable

## Technical Implementation

### Configuration Changes

**1. Add to appsettings.json:**
```json
{
  "Branding": {
    "ApplicationName": "SMX",
    "Version": "1.0"
  }
}
```

**2. Environment Variables (per environment):**
```bash
# SMX QA
Branding__ApplicationName=SMX QA
Branding__Version=1.0

# SMX Production  
Branding__ApplicationName=SMX Production
Branding__Version=1.0

# HP2 QA
Branding__ApplicationName=HP2 QA
Branding__Version=1.0
```

### Code Changes

**1. Create Configuration Class (`BrandingOptions.cs`):**
```csharp
namespace smxCore.Web.Configuration
{
    public class BrandingOptions
    {
        public string ApplicationName { get; set; } = "smxCore";
        public string Version { get; set; } = "1.0";
    }
}
```

**2. Update BuildInfo.cs to include Git info:**
```csharp
namespace smxCore.Web.Infrastructure
{
    public static class BuildInfo
    {
        public const string BuildDateTime = "2025-11-15 00:41:33 UTC";
        public const string GitCommitSha = "a1b2c3d";  // NEW
        public const string BuildNumber = "7";         // NEW
    }
}
```

**3. Register Configuration in Program.cs:**
```csharp
builder.Services.Configure<BrandingOptions>(
    builder.Configuration.GetSection("Branding"));
```

**4. Update NavMenu.razor:**
```razor
@inject IOptions<BrandingOptions> BrandingOptions

<div class="top-row ps-3 navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="">@BrandingOptions.Value.ApplicationName</a>
    </div>
</div>
```

**5. Update MainLayout.razor:**
```razor
@inject IOptions<BrandingOptions> BrandingOptions

@code {
    public string BuildDateTime => BuildInfo.BuildDateTime;
    public string GitCommitSha => BuildInfo.GitCommitSha;
    public string BuildNumber => BuildInfo.BuildNumber;
    public string ApplicationName => BrandingOptions.Value.ApplicationName;
    public string Version => BrandingOptions.Value.Version;
}

<div class="app-version">
    <div>@ApplicationName v@Version | Build #@BuildNumber (@GitCommitSha)</div>
    <div class="build-date">@BuildDateTime</div>
</div>
```

**6. Update Home.razor:**
```razor
@page "/"
@using Microsoft.AspNetCore.Authorization
@inject IOptions<BrandingOptions> BrandingOptions
@attribute [AllowAnonymous]

<PageTitle>Home - @BrandingOptions.Value.ApplicationName</PageTitle>

<div class="home-header">
    <h1>Welcome to @BrandingOptions.Value.ApplicationName</h1>
    <p class="lead">A secure platform for healthcare data management and research.</p>
</div>
```

### Build Pipeline Changes

**Update GitHub Actions workflow to inject Git info:**

```yaml
- name: Build and push Docker image
  env:
    GIT_COMMIT_SHA: ${{ github.sha }}
    BUILD_NUMBER: ${{ github.run_number }}
  run: |
    # Generate BuildInfo.cs with actual values
    cat > src/smxCore.Web/Infrastructure/BuildInfo.cs << EOF
    namespace smxCore.Web.Infrastructure
    {
        public static class BuildInfo
        {
            public const string BuildDateTime = "$(date -u +'%Y-%m-%d %H:%M:%S UTC')";
            public const string GitCommitSha = "${GIT_COMMIT_SHA:0:7}";
            public const string BuildNumber = "$BUILD_NUMBER";
        }
    }
    EOF
    
    # Build Docker image
    docker build -t myimage:latest .
```

## Deployment Configuration

### Container App Environment Variables

**SMX QA:**
```bash
az containerapp update \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --set-env-vars \
    "Branding__ApplicationName=SMX QA" \
    "Branding__Version=1.0"
```

**SMX Production:**
```bash
az containerapp update \
  --name "rhc-smx-production-app" \
  --resource-group "rhc-smx-production-rg" \
  --set-env-vars \
    "Branding__ApplicationName=SMX Production" \
    "Branding__Version=1.0"
```

**HP2 QA:**
```bash
az containerapp update \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --set-env-vars \
    "Branding__ApplicationName=HP2 QA" \
    "Branding__Version=1.0"
```

## Testing Plan

1. **Unit Tests**: Verify configuration is read correctly
2. **Integration Tests**: Verify values display in UI
3. **Manual Testing**: Deploy to QA and verify:
   - Upper left shows correct application name
   - Top right shows correct version and build info
   - Git commit SHA links to correct commit in GitHub
4. **Regression Testing**: Ensure no impact on existing functionality

## Rollout Plan

### Phase 1: Implementation (Sprint 1)
- Create `BrandingOptions` configuration class
- Update `BuildInfo.cs` structure
- Modify `NavMenu.razor` and `MainLayout.razor`
- Update GitHub Actions workflow

### Phase 2: Deployment (Sprint 1)
- Deploy to Dev environment first
- Verify display and functionality
- Deploy to QA environments
- Gather feedback

### Phase 3: Production (Sprint 2)
- Deploy to Production after QA validation
- Monitor for issues
- Document final configuration

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Configuration not set | App shows default "smxCore" | Provide sensible defaults in appsettings.json |
| Build info not generated | No commit SHA/build number shown | Add build pipeline validation step |
| UI layout issues | Text too long for display area | Design with responsive sizing, test with longest names |
| User confusion during transition | Questions about new display | Create user communication/training materials |

## Success Criteria

- ✅ Each environment displays correct application name in upper left
- ✅ Git commit SHA is displayed and accurate
- ✅ Build number is displayed and increments with each build
- ✅ No code changes required to rebrand for different environments
- ✅ Support team can identify deployed version in < 5 seconds
- ✅ No performance impact on application

## Future Enhancements

1. **Clickable Build Info**: Make commit SHA a link to GitHub commit
2. **Environment Badge**: Add colored badge (green=prod, yellow=qa, blue=dev)
3. **API Endpoint**: Expose version info via `/api/version` for monitoring
4. **Release Notes**: Link to release notes for current version

## Estimated Effort

- **Development**: 4-6 hours
- **Testing**: 2-3 hours  
- **Deployment**: 1-2 hours per environment
- **Documentation**: 1-2 hours

**Total**: ~1-2 days

## Questions for Team Discussion

1. **Display Format**: Prefer compact or detailed version info display?
2. **Footer Branding**: Should we also update the footer "smxCore Healthcare Systems"?
3. **Naming Convention**: Agree on naming (e.g., "SMX QA" vs "SMX - QA" vs "SMX (QA)")?
4. **Additional Info**: Any other build/version info we should display?
5. **Accessibility**: Any concerns about screen readers with the new format?

## Approval Needed From

- [ ] Development Team Lead - Technical approach
- [ ] Product Owner - UX/display format
- [ ] DevOps - Build pipeline changes
- [ ] QA - Testing plan
- [ ] IT/Operations - Deployment configuration

---

**Proposed By:** Ron  
**Date:** November 15, 2025  
**Status:** Pending Team Review
