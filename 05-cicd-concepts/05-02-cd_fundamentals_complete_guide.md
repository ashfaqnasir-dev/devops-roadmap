# 🚀 05.02 CD Fundamentals — Complete Guide

> **CD (Continuous Delivery / Continuous Deployment)** Continuous Integration (CI) ka agla marhala hai. Jahan CI ka maqsad code ko test aur compile karke verified artifact banana hai, wahan CD ka maqsad us artifact ko reliably aur safely mukhtalif deployment environments tak pohnchana hai.

---

## 1. Continuous Delivery vs Continuous Deployment

Dono ko aam guftagu mein "CD" pukara jata hai, magar production release step par dono mein ek ahem farq hota hai: **Manual Approval Gate (Insani Faisla)**.

```
                    CI Stage                  CD Stage
             ┌─────────────────────┐   ┌─────────────────────┐
Code Push ──►│ Build & Test Passed ├──►│ Deploy to Staging   │
             └─────────────────────┘   └──────────┬──────────┘
                                                  │
                 ┌────────────────────────────────┴────────────────────────────────┐
                 ▼                                                                 ▼
      [ Continuous Delivery ]                                           [ Continuous Deployment ]
                 │                                                                 │
                 ▼                                                                 ▼
      Manual Approval Button ⏸️                                         Fully Automated Push ⏩
                 │                                                                 │
                 ▼                                                                 ▼
      🚀 Deploy to Production                                           🚀 Deploy to Production
      (Human clicks "Approve")                                          (No human intervention)
```

| Khasiyat | Continuous Delivery | Continuous Deployment |
| :--- | :--- | :--- |
| **Production Rollout** | **Manual action zaroori hai** (Button click / Sign-off) | **Mukammal automated** (Bina kisi insani dakhal ke) |
| **Release State** | Code har waqt deployable state mein hota hai | Har passing build seedha production traffic handle karta hai |
| **Risk & Compliance** | Kam risk; business timing aur legal audits control mein rehte hain | Zyada automated testing aur mature rollback setup mangta hai |
| **Aam Use Cases** | FinTech, Healthcare, Enterprise core banking services | Web SaaS tools, streaming apps, developer tools |

> 💡 **Golden Rule:** Agar production par code bhejte waqt kisi manager, lead ya release engineer ko manual "Approve" dabana paray, toh woh **Continuous Delivery** hai. Agar master/main branch mein test pass hotay hi code seedha live users tak chala jaye, toh woh **Continuous Deployment** hai.

---

## 2. Release Pipeline (Step-by-Step Flow)

Release pipeline ka kaam verified binary ya container image ko safely end-user tak pohnchana hota hai:

```
[ Artifact Registry ]
  (Docker Image / Binaries)
         │
         ▼
[ 1. Deploy to Dev ] ──────► Smoke tests & verification
         │
         ▼
[ 2. Deploy to Staging ] ──► Integration, E2E & Load testing
         │
         ▼
[ 3. Approval Gate ] ──────► Security checks & QA sign-off
         │
         ▼
[ 4. Deploy to Prod ] ─────► Canary / Blue-Green / Rolling Rollout
         │
         ▼
[ 5. Observability ] ──────► Logs, metrics check & auto-rollback agar errors barhein
```

### Aham Marahil:
1. **Artifact Fetching:** Har environment ke liye naye sirey se code build nahi kiya jata; CI ka banaya hua verified artifact hi use hota hai (Build Once, Deploy Anywhere).
2. **Environment Configuration:** Us specific mahol ke configs (database URLs, feature flags) aur secrets inject karna.
3. **Deployment Strategy Execution:** Zero-downtime tareeqay (jaise Rolling update ya Blue-Green) se naye version ko live karna.
4. **Post-Deployment Verification:** Automated health probes (`/healthz` ya `/ready`) check karna.

---

## 3. Environment Stages (Dev, Staging, Prod)

Application ko direct live audience ke samne deploy karne ke bajaye alag alag maqasid ke liye banaye gaye environments se guzara jata hai:

```
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   Development    │  ──►  │  Staging (UAT)   │  ──►  │    Production    │
│ (Fast Iteration) │       │ (Exact Replica)  │       │  (Live Traffic)  │
└──────────────────┘       └──────────────────┘       └──────────────────┘
```

### A. Development (Dev)
* **Maqsad:** Naye features aur bug fixes ki initial testing.
* **Traffic & Data:** Dummy/mock data; koi real customer data nahi hota.
* **Uptime Expectation:** Kam; agar service crash bhi ho jaye toh business affect nahi hota.

### B. Staging / UAT (User Acceptance Testing)
* **Maqsad:** Production ka **exact replica**. Yahan release candidate ka final trial hota hai.
* **Traffic & Data:** Production jaisi configuration aur sanitized/anonymized data.
* **Users:** QA engineers, internal testers aur stakeholders.

### C. Production (Prod)
* **Maqsad:** Asal end-users aur real transactions ka platform.
* **Security & Access:** Sakht access controls (Least Privilege). Developers ko direct database ya cluster write access nahi hota.
* **Reliability:** High Availability (HA), autoscaling, continuous monitoring aur strict SLA/SLO.

---

## 4. Approval Gates (Compliance & Quality Control)

Approval gates woh safety barriers hain jo kisi risky ya imperfect release ko production mein dakhil hone se roktay hain.

### A. Approval Gates ki Iqsam:
1. **Manual Approvals (Human-in-the-Loop):**
   * Release Manager ya QA Lead status review karke pipeline mein deployment approve karta hai.
   * Regulated industries (SOC 2, PCI-DSS) mein audit trail banaye rakhne ke liye laazmi hota hai.
2. **Automated Quality Gates:**
   * **Test Coverage Threshold:** Agar unit test coverage $85\%$ se kam ho toh release ruk jaye.
   * **Security Scans:** SAST/DAST tools (SonarQube, Trivy) agar koi Critical CVE pakrein toh deploy block ho jaye.
   * **Performance Budgets:** Agar API response latency threshold se barh jaye toh pipeline reject ho jaye.

### B. Practical Example (GitHub Actions Environment with Protection):

```yaml
name: Production Release Pipeline

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy-production:
    runs-on: ubuntu-latest
    # Environment rule GitHub UI mein setup kiye gaye manual approvals ko trigger karega
    environment:
      name: production
      url: https://app.example.com
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Pull Production Artifact
        run: |
          echo "Pulling verified image: myapp:${{ github.ref_name }}"
          # docker pull myregistry.azurecr.io/myapp:${{ github.ref_name }}

      - name: Deploy to Kubernetes Cluster
        run: |
          echo "🚀 Deploying to Production cluster..."
          # kubectl apply -f k8s/production/
```

> 🎯 **Summary:** CI ka maqsad code ki **durustagi (quality)** sabit karna hai, jabke CD ka maqsad business value ko **mehfooz aur mustahkam (safe & consistent)** tareeqay se production tak muntaqil karna hai.

---
**Status:** ✅ Complete