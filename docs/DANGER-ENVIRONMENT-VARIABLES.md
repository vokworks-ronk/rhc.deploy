⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️

# 🚨 DANGER: Azure Container App Environment Variables 🚨

⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️

## ❌ NEVER USE THIS COMMAND ❌

```powershell
# ❌❌❌ THIS WILL DESTROY ALL YOUR ENVIRONMENT VARIABLES ❌❌❌
az containerapp update --replace-env-vars "SomeVar=value"
# ❌❌❌ DO NOT USE --replace-env-vars ❌❌❌
```

**What happens:** `--replace-env-vars` **DELETES ALL EXISTING VARIABLES** and replaces them with only the ones you specify.

**Result:** Your app stops working. Authentication breaks. Database connections fail. Hours/days lost.

**Real incident (November 15, 2025):**
> "Oh no! The --replace-env-vars wiped out all the other environment variables! 
> That's why it's still broken. I need to use --set-env-vars to ADD to existing 
> vars, not replace them. But now they're all gone."
>
> Two different Claude agents made this mistake. Lost a full day of work.

---

## ✅ ALWAYS USE THIS INSTEAD ✅

```powershell
# ✅✅✅ THIS SAFELY ADDS/UPDATES VARIABLES ✅✅✅
az containerapp update --set-env-vars "SomeVar=value"
# ✅✅✅ USE --set-env-vars TO ADD TO EXISTING ✅✅✅
```

**What happens:** `--set-env-vars` **ADDS OR UPDATES** the variables you specify while **KEEPING ALL OTHERS**.

**Result:** Your app keeps working. Only the variables you changed are affected.

---

## 🛡️ MANDATORY BACKUP BEFORE ANY CHANGES 🛡️

**BEFORE running ANY `az containerapp update` command:**

```powershell
# 1. Run the backup script (takes 5 seconds)
.\docs\backup-env-vars.ps1 `
  -AppName smx25dev-app `
  -ResourceGroup smx25dev-rg `
  -Environment smx-dev

# 2. Script will:
#    - Backup all env vars to JSON file
#    - Timestamp it
#    - Offer to commit to git
#    - Tell you it's safe to proceed

# 3. ONLY THEN make your changes
az containerapp update --set-env-vars "MyVar=value"
```

---

## 📋 Quick Reference

| Command | Effect | Safe? |
|---------|--------|-------|
| `--set-env-vars "A=1"` | Adds/updates A, keeps all others | ✅ YES |
| `--set-env-vars "A=1" "B=2"` | Adds/updates A and B, keeps others | ✅ YES |
| `--replace-env-vars "A=1"` | **DELETES EVERYTHING**, only keeps A | ❌ NEVER |
| `--replace-env-vars "A=1" "B=2"` | **DELETES EVERYTHING**, only A and B exist | ❌ NEVER |

---

## 🆘 If You Made a Mistake

If you accidentally used `--replace-env-vars`:

1. **DON'T PANIC** (but hurry)
2. **Check backup files:**
   ```powershell
   ls docs\deployments\{env}\env-vars-backup-*.json | sort LastWriteTime -Descending
   ```
3. **Restore from backup** (use the most recent one before the disaster)
4. **Check git history** for configuration reference docs

---

## 🎯 Why This Matters

**Environment variables that get lost:**
- Authentication config (AzureAd__*, EntraExternalId__*)
- Database connections (ConnectionStrings__*)
- DataProtection config (DataProtection__*)
- Application Insights (APPLICATIONINSIGHTS_CONNECTION_STRING)
- All custom app settings
- **Literally everything**

**Time to recover without backup:**
- Best case: 2-4 hours (if you have reference docs)
- Worst case: 1-2 days (if you don't)

**Time to backup before changes:**
- 5 seconds

---

## 🔐 The Safe Workflow

```powershell
# 1️⃣ BACKUP (ALWAYS)
.\docs\backup-env-vars.ps1 -AppName {app} -ResourceGroup {rg} -Environment {env}

# 2️⃣ UPDATE (with --set-env-vars)
az containerapp update \
  --name {app} \
  --resource-group {rg} \
  --set-env-vars "MyNewVar=value" "AnotherVar=value2"

# 3️⃣ VERIFY (check it worked)
az containerapp show \
  --name {app} \
  --resource-group {rg} \
  --query "properties.template.containers[0].env[?name=='MyNewVar']"

# 4️⃣ DOCUMENT (update deployment docs)
# Add to deployments/{env}/DEPLOYMENT.md
```

---

## 🚨 Emergency Checklist

Before running `az containerapp update`:

- [ ] Did I run the backup script?
- [ ] Did the backup complete successfully?
- [ ] Am I using `--set-env-vars` (NOT `--replace-env-vars`)?
- [ ] Do I know what I'm changing and why?
- [ ] Can I revert if something breaks?

**If you can't check all boxes: STOP and get help.**

---

⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️

**Remember:** Losing env vars is not a theoretical risk. It happened. Don't let it happen again.

⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
