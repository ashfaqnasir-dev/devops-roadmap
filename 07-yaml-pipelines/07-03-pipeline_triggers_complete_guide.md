# ⚡ 07.03 Triggers — Complete Guide

> **Triggers** CI/CD pipeline ke woh automated switches ya listen-points hain jo tay karte hain ke pipeline kab, kin halaat mein, aur kis event par execute honi chahiye. Sahi trigger strategy build minutes bachat karti hai aur unwanted deployments ko rokti hai.

---

## Triggers Architecture Overview

```
                        ┌────────────────────────────────────────┐
                        │          Pipeline Event Bus            │
                        └───────────────────┬────────────────────┘
         ┌──────────────────┬───────────────┼───────────────┬──────────────────┐
         ▼                  ▼               ▼               ▼                  ▼
  Branch Push (CI)     File Path Filter   Pull Request     Scheduled (Cron)    Upstream Pipeline
  `trigger: branches`  `trigger: paths`   `pr: branches`   `schedules: cron`   `resources: pipelines`
```

---

## 1. Branch Triggers (`trigger: branches`)

Branch triggers push events ko monitor karte hain. Jab bhi developer kisi specified branch par code push ya merge karta hai, pipeline trigger ho jati hai.

### A. Basic Syntax:
```yaml
trigger:
  branches:
    include:
      - main
      - releases/*        # Wildcard: releases/v1.0, releases/v2.1 sab match honge
    exclude:
      - releases/archive-* # Specific branches ignore karne ke liye
```

### B. Disable Push Trigger (`none`):
Agar aap chahte hain ke `git push` par pipeline khud-ba-khud **kabhi na chaley** (sirf manually ya scheduled time par chaley):
```yaml
trigger: none
```

> 💡 **Best Practice:** Feature branches (e.g. `feature/*`) par direct push trigger lagane ke bajaye **PR trigger** lagana behtar hota hai taake har chhotay commit par build credits zaya na hon.

---

## 2. Path Triggers (`trigger: paths`)

Monorepos ya multi-service repositories mein har file change par poori pipeline chalana resources ka zaya hai. **Path triggers** batate hain ke kin files ya directories ke change hone par pipeline chale ya na chale.

```
Repository Root
├── frontend/     ──► Frontend Pipeline triggers only when files here change
├── backend/      ──► Backend Pipeline triggers only when files here change
└── docs/         ──► Excluded from all build pipelines
```

### Path Filter YAML Example:
```yaml
trigger:
  branches:
    include:
      - main
  paths:
    include:
      - src/api/**        # Sirf api folder ke andar koi change aye
      - package.json      # Dependencies update hon tab chaley
    exclude:
      - '**/*.md'         # Documentation files ignore karein
      - docs/**
      - .gitignore
```

> ⚠️ **Evaluation Rule:** Path filters hamesha branch filters ke sath mil kar evaluate hotay hain. Agar branch match kare **aur** path criteria bhi match kare, tab pipeline run hogi.

---

## 3. PR Triggers (`pr`)

Pull Request (PR) triggers us waqt chalte hain jab koi developer kisi target branch mein PR open karta hai ya existing PR par naye commits push karta hai.

### Maqsad:
Code ko main branch mein merge hone se pehle test aur validate karna (Quality Gate).

```yaml
# Main branch mein aane wali PRs ke liye validation
pr:
  branches:
    include:
      - main
      - develop
  paths:
    exclude:
      - docs/**

# PR triggers band karne ke liye:
pr: none
```

| Khasiyat | `trigger` (CI Push) | `pr` (Pull Request) |
| :--- | :--- | :--- |
| **Trigger Point** | Commit direct push hone ya merge hone par | PR open hone, reopen hone, ya update hone par |
| **Target Branch** | Current branch jahan code push hua | Target base branch jisme merge hona maqsood hai |
| **Typical Role** | Build banana aur deployment karna | Code analysis, linting, aur unit tests run karna |

> 📌 **Note for Azure Repos:** Azure Repos mein PR build triggers aksar YAML file ke bajaye **Branch Policies** (Build Validation) ke zariye enforce kiye jaate hain. GitHub repos ke sath yeh direct YAML `pr:` block se operate karta hai.

---

## 4. Scheduled Triggers (`schedules: cron`)

Scheduled triggers pipeline ko clock-time ke mutabiq automatically chalate hain (Unix Cron syntax use hota hai).

### Common Use Cases:
* **Nightly Regression:** Roz raat ko lambay E2E aur load tests chalana.
* **Security Scanning:** Weekly vulnerability scan (Trivy, SonarQube).
* **Environment Maintenance:** Non-production resources ka automated cleanup.

```yaml
schedules:
  - cron: '0 2 * * 1-5'   # Har Monday se Friday raat 2:00 AM (UTC)
    displayName: 'Nightly Weekday Regression Run'
    branches:
      include:
        - main
    always: true          # Chahe koi naya commit na bhi aya ho, tab bhi chaley
```

### Cron Syntax Quick Reference:
```
┌───────────── Minute (0 - 59)
│ ┌───────────── Hour (0 - 23)
│ │ ┌───────────── Day of the Month (1 - 31)
│ │ │ ┌───────────── Month (1 - 12)
│ │ │ │ ┌───────────── Day of the Week (0 - 6) (0 = Sunday)
│ │ │ │ │
* * * * *
```
* `0 0 * * *` — Rozana aadhi raat (12:00 AM UTC).
* `0 12 * * 0` — Har itwar dopehr 12:00 baje.

---

## 5. Pipeline Triggers (`resources: pipelines`)

Pipeline triggers (Downstream / Upstream chaining) tab use hotay hain jab ek pipeline ke kamyab hone par doosri pipeline ko automatically start karwana ho.

```
[ Upstream: Backend-CI-Pipeline ]
               │
               ▼ (Status: Succeeded ✅)
[ Downstream: Integration-Test-Pipeline / E2E Pipeline ]
```

### Example: Upstream Pipeline Resource Trigger
```yaml
# integration-tests-pipeline.yml

resources:
  pipelines:
    - pipeline: upstreamBackendCI       # Identifier name
      source: 'Backend-Build-Pipeline'  # Azure DevOps mein pipeline ka exact naam
      trigger:
        branches:
          include:
            - main
        stages:
          - BuildAndTest                 # Sirf is specific stage ke pass hone par chaley

trigger: none                           # Is pipeline ka apna push trigger off hai

pool:
  vmImage: 'ubuntu-latest'

steps:
  - script: echo "Running full system integration tests triggered by $(resources.pipeline.upstreamBackendCI.runName)"
    displayName: 'Run E2E Suite'
```

---

## 💡 Practical Cheatsheet: Triggers Decision Matrix

| Scenario | Recommended Trigger Configuration |
| :--- | :--- |
| Single-repo microservice | `trigger.paths.include: ['serviceA/**']` |
| PR quality gate | `pr.branches.include: ['main']` |
| Expensive security scans | `schedules.cron: '0 3 * * 0'` (Sunday early morning) |
| Microservice dependency test | `resources.pipelines.trigger` |
| Zero auto-trigger (Ops runbook) | `trigger: none` aur `pr: none` |

---
**Status:** ✅ Complete