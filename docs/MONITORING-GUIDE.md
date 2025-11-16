# 📊 Monitoring & Health Check Guide

**Last Updated:** November 14, 2025  
**Environment:** QA

---

## Overview

This guide explains how to monitor the health and performance of SMX and HP2 applications in the QA environment.

**Important:** The `/health` endpoint requires authentication in SMX/HP2, so traditional health checks don't work. Use the monitoring methods below instead.

---

## 🔍 Quick Health Checks

### Method 1: Container App Status (Fastest)

```bash
# Check if app is running
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.runningStatus" -o tsv

# Should return: "Running"
```

### Method 2: HTTP Response Test

```bash
# Test root URL - should return 302 redirect (indicates app is alive)
curl -I https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io

# Look for: HTTP/1.1 302 Found
# Location header should point to authentication endpoint
```

### Method 3: Revision Health

```bash
# Check revision health status
az containerapp revision list \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "[].{Revision:name,Active:properties.active,Health:properties.healthState,Replicas:properties.replicas}" \
  -o table
```

---

## 📈 Azure Monitor Metrics

Container Apps automatically reports metrics to Azure Monitor.

### Available Metrics

| Metric | Description | Good For |
|--------|-------------|----------|
| `Requests` | HTTP requests per second | Traffic monitoring |
| `Replicas` | Number of running replicas | Scaling validation |
| `RestartCount` | Container restarts | Stability issues |
| `UsageNanoCores` | CPU usage | Performance |
| `WorkingSetBytes` | Memory usage | Resource utilization |
| `RxBytes` / `TxBytes` | Network traffic | Data transfer |

### Query Metrics via CLI

```bash
# Get request count (last hour)
az monitor metrics list \
  --resource "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.App/containerApps/rhc-smx-qa-app" \
  --metric "Requests" \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --interval PT1M \
  --output table

# Get replica count
az monitor metrics list \
  --resource "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.App/containerApps/rhc-smx-qa-app" \
  --metric "Replicas" \
  --output table
```

### Portal Access

**Azure Monitor Metrics Portal:**
https://portal.azure.com/#@rhcqa.onmicrosoft.com/resource/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.App/containerApps/rhc-smx-qa-app/metrics

---

## 🔍 Application Insights

Application Insights provides detailed application telemetry including:
- Request rates and response times
- Dependency tracking (database calls)
- Exceptions and failures
- Custom events and traces

### Configuration

**SMX QA:**
- ✅ Application Insights: `rhc-smx-qa-insights`
- ✅ Connection configured in Container App environment variables
- ✅ Instrumentation Key: `8649e36e-eade-469f-920e-ea658ca187a6`

**HP2 QA:**
- ✅ Application Insights: `rhc-hp2-qa-insights`
- ✅ Instrumentation Key: `2d95180d-9339-4103-b084-c20da27aa655`

### Portal Access

**SMX Application Insights:**
https://portal.azure.com/#@rhcqa.onmicrosoft.com/resource/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/microsoft.insights/components/rhc-smx-qa-insights

**HP2 Application Insights:**
https://portal.azure.com/#@rhcqa.onmicrosoft.com/resource/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-hp2-qa-rg/providers/microsoft.insights/components/rhc-hp2-qa-insights

### Query Application Insights

```bash
# Get recent exceptions (last hour)
az monitor app-insights query \
  --app rhc-smx-qa-insights \
  --resource-group rhc-smx-qa-rg \
  --analytics-query "exceptions | where timestamp > ago(1h) | summarize count() by type" \
  --output table

# Get request statistics
az monitor app-insights query \
  --app rhc-smx-qa-insights \
  --resource-group rhc-smx-qa-rg \
  --analytics-query "requests | where timestamp > ago(1h) | summarize count(), avg(duration) by resultCode" \
  --output table
```

---

## 📋 Container App Logs

### View Application Logs

```bash
# SMX logs (last 50 lines)
az containerapp logs show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --tail 50 \
  --follow false

# HP2 logs
az containerapp logs show \
  --name "rhc-hp2-qa-app" \
  --resource-group "rhc-hp2-qa-rg" \
  --tail 50 \
  --follow false
```

### Stream Logs (Real-time)

```bash
# Stream SMX logs
az containerapp logs show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --follow true

# Press Ctrl+C to stop
```

### System Logs (Container Events)

```bash
# View Container App system events
az containerapp logs show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --type system \
  --tail 50
```

---

## 🚨 Alerting

### Create Alert Rules

#### 1. High Error Rate Alert

```bash
# Create action group (email notification)
az monitor action-group create \
  --name "smx-qa-alerts" \
  --resource-group "rhc-smx-qa-rg" \
  --short-name "SMXAlerts" \
  --email-receiver name="Admin" email-address="admin@recalibratex.net"

# Create alert rule for high error rate (>5% errors)
az monitor metrics alert create \
  --name "smx-qa-high-error-rate" \
  --resource-group "rhc-smx-qa-rg" \
  --scopes "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.App/containerApps/rhc-smx-qa-app" \
  --condition "count Requests where resultCode >= 500 > 10" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action smx-qa-alerts
```

#### 2. Container Restart Alert

```bash
# Alert when container restarts
az monitor metrics alert create \
  --name "smx-qa-restart-alert" \
  --resource-group "rhc-smx-qa-rg" \
  --scopes "/subscriptions/3991b88f-785e-4e03-bac3-e6721b76140b/resourceGroups/rhc-smx-qa-rg/providers/Microsoft.App/containerApps/rhc-smx-qa-app" \
  --condition "total RestartCount > 5" \
  --window-size 15m \
  --evaluation-frequency 5m \
  --action smx-qa-alerts
```

---

## 📊 Dashboards

### Create Custom Dashboard

1. Go to Azure Portal: https://portal.azure.com
2. Click "Dashboard" in left menu
3. Click "+ Create" → "Custom"
4. Add tiles:
   - Container App status
   - Request rate metrics
   - Error rate metrics
   - Application Insights failures

### Pre-built Queries

**Top 10 Slowest Requests (Application Insights):**
```kusto
requests
| where timestamp > ago(1h)
| where success == true
| top 10 by duration desc
| project timestamp, name, url, duration, resultCode
```

**Failed Authentication Attempts:**
```kusto
traces
| where timestamp > ago(1h)
| where message contains "authentication failed" or message contains "AADSTS"
| summarize count() by bin(timestamp, 5m)
```

**Database Connection Errors:**
```kusto
exceptions
| where timestamp > ago(1h)
| where type contains "SqlException" or outerMessage contains "database"
| project timestamp, type, outerMessage, problemId
```

---

## ✅ Health Check Checklist

Use this checklist for daily monitoring:

### Daily Checks (5 minutes)

- [ ] Container App status: `Running`
- [ ] Active revision is healthy
- [ ] No excessive restarts (< 5 per day)
- [ ] Application Insights shows no critical errors
- [ ] Request success rate > 95%

### Weekly Checks (15 minutes)

- [ ] Review error trends in Application Insights
- [ ] Check database connection patterns
- [ ] Review authentication failures
- [ ] Verify average response time < 2 seconds
- [ ] Check resource utilization (CPU/Memory)
- [ ] Review audit logs for security events

### Monthly Checks (30 minutes)

- [ ] Review all alert rules and adjust thresholds
- [ ] Check for application insights connection issues
- [ ] Verify log retention settings
- [ ] Review scaling patterns and adjust min/max replicas
- [ ] Update dashboards with new metrics
- [ ] Check Key Vault secret expiration dates

---

## 🔧 Troubleshooting

### App Not Responding

```bash
# 1. Check status
az containerapp show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" --query "properties.runningStatus"

# 2. Check recent logs
az containerapp logs show --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" --tail 100

# 3. Check revision health
az containerapp revision list --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg"

# 4. Restart if needed
az containerapp revision restart --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg"
```

### High Error Rate

```bash
# Check Application Insights for exceptions
az monitor app-insights query \
  --app rhc-smx-qa-insights \
  --resource-group rhc-smx-qa-rg \
  --analytics-query "exceptions | where timestamp > ago(1h) | summarize count() by type, outerMessage" \
  --output table
```

### Authentication Issues

```bash
# Check logs for AADSTS errors
az containerapp logs show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --tail 100 \
  --follow false | grep -i "AADSTS\|authentication\|failed"
```

### Database Connection Issues

```bash
# Check environment variables
az containerapp show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --query "properties.template.containers[0].env[?contains(name, 'Database')]"

# Check logs for SQL errors
az containerapp logs show \
  --name "rhc-smx-qa-app" \
  --resource-group "rhc-smx-qa-rg" \
  --tail 100 | grep -i "sql\|database\|connection"
```

---

## 📞 Quick Reference

### SMX QA Resources

| Resource | Value |
|----------|-------|
| Container App | `rhc-smx-qa-app` |
| Resource Group | `rhc-smx-qa-rg` |
| Application Insights | `rhc-smx-qa-insights` |
| URL | https://rhc-smx-qa-app.mangobay-bcba1c5a.eastus2.azurecontainerapps.io |
| Log Analytics Workspace | `rhc-smx-qa-logs` |

### HP2 QA Resources

| Resource | Value |
|----------|-------|
| Container App | `rhc-hp2-qa-app` |
| Resource Group | `rhc-hp2-qa-rg` |
| Application Insights | `rhc-hp2-qa-insights` |
| URL | https://rhc-hp2-qa-app.blackdesert-17ce6cff.eastus2.azurecontainerapps.io |
| Log Analytics Workspace | `rhc-hp2-qa-logs` |

---

**Document Version:** 1.0  
**Last Updated:** November 14, 2025  
**Status:** ✅ Complete
