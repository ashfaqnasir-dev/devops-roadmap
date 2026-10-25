# 🚀 07.07 Deployment Jobs — Complete Guide

> Azure Pipelines mein ek aam build job (`job: ...`) aur ek **Deployment Job** (`deployment: ...`) mein wazeh farq hota hai. Deployment job makhsoos tor par Continuous Delivery (CD) ke liye design kiya gaya hai. Yeh target environments ke sath integrate hota hai, deployment history record karta hai, aur structured rollout lifecycle hooks (pre-deploy, deploy, routeTraffic, postRouteTraffic, on: failure) provide karta hai.

---

## 1. Deployment Jobs (`deployment`) vs Regular Jobs (`job`)

```
   [ Regular Job: 'job: MyJob' ]               [ Deployment Job: 'deployment: MyDeploy' ]
┌─────────────────────────────────┐        ┌───────────────────────────────────────────────┐
│ • Standard worker / CI build    │        │ • Specialized CD execution unit               │
│ • No concept of target env      │        │ • Attached to an 'environment' (Dev/Staging) │
│ • No built-in rollback hooks    │        │ • Lifecycle hooks (deploy, routeTraffic)      │
│ • Manual artifact download step │        │ • Auto-downloads artifacts by default         │
│ • Linear execution only         │        │ • Supports deployment strategies (canary/roll)│
└─────────────────────────────────┘        └───────────────────────────────────────────────┘
```

### Basic Syntax:
```yaml
jobs:
  - deployment: DeployWeb
    displayName: 'Deploy Frontend Service'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'production'     # Target environment identifier
    strategy:
      runOnce:
        deploy:
          steps:
            - script: echo "Deploying bundle to servers..."
```

---

## 2. Environments (`environment`)

**Environment** target infrastructure (Kubernetes cluster, VMs, Web Apps, ya generic logical target) ka ek named collection hota hai jahan application install hoti hai.

### A. Environment ke Fawaid:
1. **Deployment History & Auditability:** Portal par exact pata chalta hai ke kis pipeline run, commit aur developer ne is environment par code push kiya.
2. **Commit & Work Item Traceability:** Environment view se seedha related commits aur Azure Boards work items dekhe ja sakte hain.
3. **Security Boundary:** Har environment par alag user permissions aur gate policies lagai ja sakti hain.

### B. Targeting Resources (VMs & Kubernetes):
Environment sirf plain text naam hi nahi hota, balki iske andar physical resources bhi register ho sakte hain:

```yaml
environment:
  name: 'prod-k8s'
  resourceType: 'Kubernetes'
  resourceName: 'frontend-namespace'
```

---

## 3. Approvals & Checks (Security & Governance)

Azure DevOps portal ke **Pipelines > Environments** section mein target environment par automated aur manual checks configure kiye jaate hain. Jab pipeline is environment tak pohnchti hai, toh steps chalne se pehle yeh checks evaluate hotay hain:

```
Pipeline reaches Deployment Job
               │
               ▼
   [ Environment Approvals & Checks ]
   ├── ⏸️ Manual Approvals (Sign-off from Leads/QA)
   ├── ⏰ Business Hours (Only deploy 09:00 - 17:00 UTC)
   ├── 🔒 Exclusive Lock (Prevent overlapping deploys)
   └── 🔍 Azure Monitor Alerts (Check error spikes)
               │
      ┌────────┴────────┐
      ▼                 ▼
   Approved          Rejected
      │                 │
      ▼                 ▼
Deploy Steps Run     Pipeline Fails Safely
```

### Common Checks:
* **Manual Approvals:** Makhsoos users ya security groups ko email notification jata hai aur unka sign-off mandatory hota hai.
* **Branch Control:** Sirf `refs/heads/main` ya release tags se aane wale code ko production environment use karne ki ijazat dena.
* **Invoke REST API / Azure Function:** Third-party vulnerability scanners ya ServiceNow change tickets ko programmatically verify karna.

---

## 4. Deployment Strategies (`strategy`)

Deployment job ka sabse powerful feature iska `strategy` block hota hai jo mukhtalif rollout techniques ko control karta hai.

```
                      ┌───────────────────────────────────────┐
                      │         Deployment Strategies         │
                      └──────────────────┬────────────────────┘
          ┌──────────────────────────────┼──────────────────────────────┐
          ▼                              ▼                              ▼
      [ runOnce ]                    [ rolling ]                    [ canary ]
• Sabhi targets par ek sath    • Batch-by-batch update        • Chhote traffic slice par
• Simplest pattern             • Zero downtime for VM pools   • Progressive confidence test
```

### Strategy Lifecycle Hooks:
Har deployment strategy ke paas structured execution hooks hotay hain:

| Hook | Maqsad | Practical Action |
| :--- | :--- | :--- |
| `preDeploy` | Deployment se pehle initialization | Health checks, load balancer se drain karna, backups lena |
| `deploy` | Actual installation | Binaries copy karna, container image update karna |
| `routeTraffic` | Traffic muntaqil karna | Load balancer routing update karna ya DNS switch karna |
| `postRouteTraffic` | Traffic switch hone ke baad | Latency monitor karna, smoke tests chalana |
| `on: failure` | Masla aane par | Automatic rollback scripts trigger karna |
| `on: success` | Kamyabi par | Purane containers terminate karna, notification bhejna |

---

### A. `runOnce` Strategy (Default)
Yeh sabse basic strategy hai jo tamam steps ko ek hi dafa execute karti hai:

```yaml
strategy:
  runOnce:
    preDeploy:
      steps:
        - script: echo "Pre-deployment checks: Ensuring DB connection is alive..."
    deploy:
      steps:
        - script: echo "Applying database migrations and deploying app..."
    routeTraffic:
      steps:
        - script: echo "Switching ingress traffic to new version..."
    on:
      failure:
        steps:
          - script: echo "🚨 Deployment failed! Alerting On-Call Engineer..."
```

---

### B. `rolling` Strategy (Batch-by-Batch VM Updates)
Virtual Machine pools ke liye useful hai jahan servers ko batches mein divide karke ek ek karke update kiya jata hai taake downtime na aaye:

```yaml
strategy:
  rolling:
    maxParallel: 2   # Ek waqt mein 2 VMs update hongi (ya percentage: '25%')
    preDeploy:
      steps:
        - script: echo "Taking batch nodes out of Load Balancer target group..."
    deploy:
      steps:
        - script: echo "Installing latest application update on target nodes..."
    routeTraffic:
      steps:
        - script: echo "Adding batch nodes back to Load Balancer..."
```

---

### C. `canary` Strategy (Progressive Rollout)
Naye version ko pehle chhotay percentage (e.g. 10%) par live karke baseline metrics verify kiye jaate hain, phir bache hue traffic ko step-by-step update kiya jata hai:

```yaml
strategy:
  canary:
    increments: [10, 25, 100]   # Pehle 10% servers, phir 25%, phir 100%
    deploy:
      steps:
        - script: echo "Deploying canary increment..."
    postRouteTraffic:
      steps:
        - script: |
            echo "Checking error rate and response latency..."
            # Agar error rate > 1% ho toh exit 1 karein (triggering on: failure)
    on:
      failure:
        steps:
          - script: echo "Canary degraded! Reverting traffic to stable version..."
```

---

## 5. Rollback Strategies (`on: failure`)

Rollback ka maqsad kisi failed release ke baad system ko foran aakhri stable state (last known good state) par wapis lana hota hai bina lambe debug cycles ke.

```
Step Fails in `deploy` or `postRouteTraffic`
                   │
                   ▼ (Catches Failure)
          [ on: failure Hook ]
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
[ Automated Rollback ]    [ Alert Incident Room ]
• Revert K8s deployment   • Fire PagerDuty / Slack alert
• Flip Blue/Green routing • Lock pipeline for triage
```

### Complete Working Rollback Example in YAML:

```yaml
jobs:
  - deployment: DeployProduction
    displayName: 'Production Blue-Green Deployment'
    pool:
      vmImage: 'ubuntu-latest'
    environment: 'production'
    strategy:
      runOnce:
        deploy:
          steps:
            - script: |
                echo "Deploying new version to Green slot..."
                # az webapp deployment slot create / deploy command
              displayName: 'Deploy to Staging Slot'

        routeTraffic:
          steps:
            - script: |
                echo "Testing green slot health before traffic swap..."
                curl --fail https://myapp-staging.azurewebsites.net/healthz
                echo "Swapping staging slot with production slot..."
                # az webapp deployment slot swap ...
              displayName: 'Run Health Check and Swap Slots'

        on:
          failure:
            steps:
              - script: |
                  echo "❌ CRITICAL: Rollout failed or health checks returned non-200!"
                  echo "Executing rollback: Swapping back to original stable slot..."
                  # az webapp deployment slot swap --action reset / swap back
                displayName: 'Automated Immediate Rollback'

              - script: |
                  curl -X POST -H 'Content-type: application/json' \
                    --data '{"text":"🚨 Production Deployment Failed! Rollback triggered automatically."}' \
                    $(SLACK_WEBHOOK_URL)
                displayName: 'Send Failure Notification'
```

---

## 💡 Practical Cheatsheet: Deployment Jobs Best Practices

1. **Never use regular `job:` for Prod:** Production deploys ke liye hamesha `deployment:` job use karein taake audit history aur approvals active rahein.
2. **Health Check in `postRouteTraffic`:** Traffic switch hone ke foran baad automated endpoint ping check (`/healthz`) lazmi chalayein.
3. **Keep Rollbacks Tested:** Rollback script ko disaster drills mein test karein; failure ke waqt untested rollback mazeed issues create kar sakta hai.
4. **Use Artifact Auto-Download:** Deployment jobs pichle stage ke publish kiye gaye artifacts ko khud-ba-khud download kar lete hain, unhein manually fetch karne ki zaroorat nahi hoti.

---
**Status:** ✅ Complete