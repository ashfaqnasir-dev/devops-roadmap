# ⚙️ 05.03 Pipeline Concepts — Complete Guide

> Ek CI/CD pipeline dar-asal commands, scripts aur rules ka ek automated chain (silsila) hoti hai. Har pipeline platform (GitHub Actions, GitLab CI, Jenkins, Azure DevOps) ka syntax thora alag ho sakta hai, lekin un sab ke bunyadi concepts aur architecture bilkul ek jaise hote hain.

---

## 1. Hierarchy: Stages, Jobs, Steps

Har pipeline ko logical blocks mein baanta jata hai taake execution organized, parallel, aur debug karne mein aasan rahe:

```
Pipeline (Workflow)
  │
  ├── Stage: Build
  │     └── Job: build-backend
  │           ├── Step 1: Checkout Code
  │           ├── Step 2: Setup Runtime (Node / Python / Go)
  │           └── Step 3: Run Build Script
  │
  ├── Stage: Test (Parallel Execution)
  │     ├── Job: unit-tests
  │     │     └── Steps...
  │     └── Job: linter-checks
  │           └── Steps...
  │
  └── Stage: Deploy (Depends on Test Stage)
        └── Job: deploy-prod
              └── Steps...
```

| Component | Level | Kaam & Behavior |
| :--- | :--- | :--- |
| **Pipeline (Workflow)** | Top Level | Poori automation file (e.g. `.github/workflows/ci.yml`). Yeh poore lifecycle ko represent karti hai. |
| **Stage** | Phase Level | Pipeline ke baray marahil (Build, Test, Deploy). Aam tor par agla stage tab shuru hota hai jab pichla stage pass ho jaye. |
| **Job** | Execution Unit | Ek specific task jo **ek alag machine (runner/container)** par chalta hai. By default jobs **parallel** chalti hain jab tak dependency (`needs:`) na lagayi jaye. |
| **Step** | Action Level | Job ke andar chalne wali individual shell commands ya pre-made actions/plugins jo **ek ke baad ek (sequentially)** chalti hain. |

---

## 2. Triggers (Events jo Pipeline Shuru Karte Hain)

Pipeline khud-ba-khud nahi chalti; use shuru hone ke liye kisi **Event (Trigger)** ki zaroorat hoti hai.

```
Trigger Event ──► Pipeline Starts ──► Jobs Execute
```

### A. Code Push (`push`)
Jab koi developer specific branch ya tag par code push kare:
* **Common Pattern:** Feature branches par sirf test chalein, jabke `main` branch par push hone se release pipeline chale.

### B. Pull Request / Merge Request (`pull_request`)
Jab koi developer PR open kare, update kare, ya re-open kare:
* **Purpose:** Code merge hone se pehle check karna ke naya code main branch ko break toh nahi karega.

### C. Scheduled / Cron (`schedule`)
Kisi makhsoos waqt par pipeline automatically chalana:
* **Use Case:** Raat ko heavy regression tests chalana, daily security vulnerability scans, ya backup jobs.
* **Syntax:** Standard Unix cron syntax (e.g., `0 2 * * *` = Har roz raat 2 baje).

### D. Manual Trigger (`workflow_dispatch` / `manual`)
Jab kisi button par click karke pipeline chalani ho (e.g. Production rollbacks ya on-demand staging deployment).

---

## 3. Agents / Runners (Hosted vs Self-Hosted)

Agent (ya Runner) woh machine (VM, Container, ya Bare-metal server) hoti hai jis par pipeline ke jobs physical tor par execute hote hain.

```
      Cloud Hosted Runners                      Self-Hosted Runners
┌───────────────────────────────┐       ┌───────────────────────────────┐
│ • Managed by GitHub/GitLab    │       │ • Managed by your team        │
│ • Fresh, clean VM every run   │       │ • Permanent server / K8s pod  │
│ • Zero maintenance            │       │ • Internal network access     │
│ • Usage limits & per-min cost │       │ • Hardware & cache control    │
└───────────────────────────────┘       └───────────────────────────────┘
```

| Feature | Cloud-Hosted (e.g., GitHub-hosted) | Self-Hosted (On-Prem / Private Cloud) |
| :--- | :--- | :--- |
| **Setup & Maintenance** | **Zero effort** (Cloud provider sab manage karta hai) | Server patches, Docker runtime, aur security khud sambhalni hoti hai |
| **Environment State** | Ephemeral (Har job ke baad VM destroy ho kar clean state milti hai) | Persistent ya Custom Ephemeral (Setup par depend karta hai) |
| **Network Access** | Public internet se private VPC mein jana mushkil hota hai | Corporate private VPCs aur databases se direct connect ho sakta hai |
| **Cost** | Per-minute billing (bara build time ho toh costly) | Apne server ka flat cost, execution minutes free hote hain |
| **Hardware Control** | Standard CPU/RAM options | Custom GPUs, high RAM, ya custom architecture (ARM/Apple Silicon) |

---

## 4. Variables & Secrets Management

Pipelines ko chalane ke liye configuration data aur sensitive credentials ki zaroorat hoti hai.

### A. Environment Variables (Non-Sensitive)
Woh settings jo plain text mein readable ho sakti hain:
* Application ports, environment names (`ENVIRONMENT=staging`), build flags (`NODE_ENV=production`).

### B. Secrets (Highly Sensitive Data)
Woh sensitive data jo kabhi bhi console logs ya git repository mein plain text mein nahi aana chahiye:
* Docker registry passwords, AWS Access Keys, SSH Private Keys, API tokens.
* **Platform Security:** GitHub/GitLab secrets ko memory mein encrypt rakhte hain aur logs mein unki value ko mask (`***`) kar dete hain.

### Example (GitHub Actions Syntax):
```yaml
name: CI Pipeline Example

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest # Agent / Runner type

    env:
      APP_ENV: staging    # Non-sensitive variable

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Login to Docker Hub
        run: |
          # Secrets use karte waqt mask rehte hain
          echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
```

---

## 5. Artifacts (Build Output Share Karna)

Ek job doosri job se bilkul isolated (alag machine) par chalti hai. Agar `build` job ne koi binary file, `.jar`, compiled React `dist/` folder, ya test coverage report banayi hai, toh agli job use direct access nahi kar sakti.

**Artifact** woh packaging mechanism hai jo build outputs ko temporarily save karta hai taake:
1. Agli jobs (jaise `deploy` job) use download karke use kar sakein.
2. Developers manual download karke test reports ya binaries inspect kar sakein.

```
[ Job 1: Build & Package ]
        │
        ▼ (Upload Step)
┌─────────────────────────────────┐
│     Shared Artifact Storage     │  (e.g., app-build-v1.2.zip)
└─────────────────────────────────┘
        │
        ▼ (Download Step)
[ Job 2: Deploy to Production ]
```

### Typical Use Cases:
* **Compiled code:** Frontend `dist/` ya `build/` folder.
* **Test results:** HTML code coverage reports aur JUnit XML test outputs.
* **Compiled binaries:** Go binaries, `.apk` files for mobile, ya packaged Helm charts.

---
**Status:** ✅ Complete