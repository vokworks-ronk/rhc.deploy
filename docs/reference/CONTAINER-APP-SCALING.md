# Container App Scaling Configuration

## Overview

Azure Container Apps support automatic scaling with configurable minimum and maximum replicas. This document covers scaling strategies, cost implications, and configuration commands for different environments.

## Scaling Behavior

- **minReplicas = 0**: App scales to zero when idle (no instances running, no cost when not in use)
  - **Cold Start**: 5-15 seconds to spin up first instance when traffic arrives
  - **Use Case**: Development, QA, and cost-sensitive environments
  
- **minReplicas = 1+**: App always has at least one instance ready
  - **No Cold Start**: Instant response to first request
  - **Constant Cost**: Runs 24/7 even when idle
  - **Use Case**: Production, user-facing applications

- **maxReplicas**: Maximum number of instances during high traffic
  - Automatically scales based on HTTP traffic, CPU, memory, or custom metrics
  - Default: 10 replicas

## Current Resource Configuration

All container apps currently use:
- **CPU**: 0.5 vCPU per instance
- **Memory**: 1 GiB per instance
- **Workload Profile**: Consumption plan

## Cost Analysis

### Monthly Cost Per Always-On Instance

Based on East US 2 consumption plan pricing:

| Resource | Rate | Calculation | Monthly Cost |
|----------|------|-------------|--------------|
| vCPU | $0.000024/vCPU-second | 0.5 vCPU × 2,592,000 sec/month | ~$31.10 |
| Memory | $0.000003/GiB-second | 1 GiB × 2,592,000 sec/month | ~$7.78 |
| **Total per instance** | | | **~$38.88/month** |

### Cost Comparison

| Configuration | Monthly Cost (Idle) | Notes |
|--------------|---------------------|-------|
| minReplicas = 0 | ~$0 (only pay when active) | Cold starts on first request |
| minReplicas = 1 | ~$39 | Instant response, no cold starts |
| minReplicas = 2 | ~$78 | High availability, load distribution |

**Additional costs apply when scaling beyond minimum replicas during traffic spikes.**

## Recommended Configurations

### Production Environments

**Always set minReplicas = 1 for production** to ensure:
- No cold starts for users
- Instant application response
- Professional user experience
- Acceptable cost (~$39/month per app)

### QA Environments

**Default to minReplicas = 0** to save costs, but:
- Temporarily set to 1 during active testing sessions
- Set to 1 before demos or stakeholder reviews
- Can be changed instantly without code deployment

### Development Environments

**Keep minReplicas = 0** to minimize costs when not actively developing.

## Configuration Commands

### Check Current Scaling Configuration

```powershell
# Check scaling settings
az containerapp show `
  --name "rhc-smx-qa-app" `
  --resource-group "rhc-smx-qa-rg" `
  --query "properties.template.scale" -o json
```

### Update Scaling Configuration

#### SMX QA - Scale to Zero (Default)
```powershell
az containerapp update `
  --name "rhc-smx-qa-app" `
  --resource-group "rhc-smx-qa-rg" `
  --min-replicas 0 `
  --max-replicas 10
```

#### SMX QA - Keep Warm (Active Testing)
```powershell
az containerapp update `
  --name "rhc-smx-qa-app" `
  --resource-group "rhc-smx-qa-rg" `
  --min-replicas 1 `
  --max-replicas 10
```

#### HP2 QA - Scale to Zero (Default)
```powershell
az containerapp update `
  --name "rhc-hp2-qa-app" `
  --resource-group "rhc-hp2-qa-rg" `
  --min-replicas 0 `
  --max-replicas 10
```

#### HP2 QA - Keep Warm (Active Testing)
```powershell
az containerapp update `
  --name "rhc-hp2-qa-app" `
  --resource-group "rhc-hp2-qa-rg" `
  --min-replicas 1 `
  --max-replicas 10
```

#### SMX Production - Always On
```powershell
az containerapp update `
  --name "rhc-smx-production-app" `
  --resource-group "rhc-smx-production-rg" `
  --min-replicas 1 `
  --max-replicas 10
```

#### HP2 Production - Always On
```powershell
az containerapp update `
  --name "rhc-hp2-production-app" `
  --resource-group "rhc-hp2-production-rg" `
  --min-replicas 1 `
  --max-replicas 10
```

## Dynamic QA Scaling Strategy

For QA environments, you can implement a schedule-based approach:

### Business Hours (Mon-Fri 8am-6pm)
Set minReplicas = 1 for responsive testing:
```powershell
az containerapp update --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" --min-replicas 1
```

### Off Hours (Nights/Weekends)
Set minReplicas = 0 to save costs:
```powershell
az containerapp update --name "rhc-smx-qa-app" --resource-group "rhc-smx-qa-rg" --min-replicas 0
```

**Note**: You could automate this with Azure Automation or GitHub Actions scheduled workflows.

## Advanced Scaling Configuration

### Custom Scaling Rules

Container Apps support scaling based on:
- **HTTP traffic**: Default, scales based on concurrent requests
- **CPU/Memory**: Scale when resource utilization hits thresholds
- **Custom metrics**: Azure Monitor metrics, Service Bus queue length, etc.

Example with custom concurrent request threshold:
```powershell
az containerapp update `
  --name "rhc-smx-production-app" `
  --resource-group "rhc-smx-production-rg" `
  --min-replicas 1 `
  --max-replicas 10 `
  --scale-rule-name "http-rule" `
  --scale-rule-type "http" `
  --scale-rule-http-concurrency 50
```

### High Availability Configuration

For critical production workloads, consider:
- **minReplicas = 2**: Ensures redundancy during rolling updates
- **maxReplicas = 20+**: Handle traffic spikes during peak usage

## Monitoring and Optimization

### Check Active Replicas
```powershell
az containerapp revision list `
  --name "rhc-smx-qa-app" `
  --resource-group "rhc-smx-qa-rg" `
  --query "[].{Name:name, Replicas:properties.replicas, Active:properties.active}" -o table
```

### View Scaling Events
Check Application Insights or Container App logs to see:
- When scaling occurred
- Response times during cold starts
- Resource utilization patterns

### Cost Optimization Tips

1. **Review maxReplicas**: If you never scale beyond 3 instances, lower maxReplicas to 5
2. **Right-size resources**: If CPU/Memory usage is consistently low, consider reducing to 0.25 vCPU / 0.5 GiB
3. **QA scheduling**: Implement automated scaling schedules for QA environments
4. **Monitor actual usage**: Use Azure Cost Management to track container app costs

## Summary

| Environment | minReplicas | maxReplicas | Monthly Cost (Idle) | Use Case |
|-------------|-------------|-------------|---------------------|----------|
| **SMX Production** | 1 | 10 | ~$39 | Always-on for users |
| **HP2 Production** | 1 | 10 | ~$39 | Always-on for users |
| **SMX QA** | 0* | 10 | ~$0 | Scale to 1 during testing |
| **HP2 QA** | 0* | 10 | ~$0 | Scale to 1 during testing |

*Can be temporarily set to 1 for active testing sessions

**Total production cost for always-on**: ~$78/month for both SMX and HP2 production apps (idle baseline)

## References

- [Azure Container Apps Scaling](https://learn.microsoft.com/en-us/azure/container-apps/scale-app)
- [Azure Container Apps Pricing](https://azure.microsoft.com/en-us/pricing/details/container-apps/)
- [Container Apps Best Practices](https://learn.microsoft.com/en-us/azure/container-apps/best-practices)
