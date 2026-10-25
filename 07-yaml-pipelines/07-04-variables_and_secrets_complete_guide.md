# 🔐 07.04 Variables & Secrets — Complete Guide

> CI/CD pipelines ko dynamic, reusable aur secure banane ke liye configurations, environment settings aur sensitive credentials (passwords, tokens, API keys) ko manage karna laazmi hota hai. Azure Pipelines mein variables aur secrets ko organize karne ke liye hierarchical tareeqay faraham kiye gaye hain taake sensitive data kabhi leak na ho.

---

## Variable Scopes & Precedence Overview

Azure Pipelines mein variables mukhtalif levels par define kiye ja sakte hain. Agar same variable multiple jagahon par define ho, toh **lowest (most specific) scope** hamesha jeet-ta hai:

```
[ Pipeline Level / Root YAML ]    (Broadest scope)
             │
             ▼
      [ Stage Level ]             (Stage ke andar override hota hai)
             │
             ▼
       [ Job Level ]              (Specific job ke liye)
             │
             ▼
      [ Step / Script ]           (Environment variables passed to commands)
```

> 🎯 **Precedence Order (Top overrides bottom):**
> 1. Runtime / Manual Parameters
> 2. Job-level variables
> 3. Stage-level variables
> 4. Root pipeline-level variables
> 5. Variable Groups (Library)

---

## 1. Defining Variables (`variables`)

YAML file mein variables define karne ke do aam tareeqay hain:

### A. Simple Key-Value Format:
Chhoti configuration ke liye direct dictionary format:

```yaml
variables:
  appName: 'payment-service'
  buildConfiguration: 'Release'
  nodeVersion: '20.x'
```

### B. List / Object Format (Recommended):
Jab aapko regular variables ke sath Variable Groups ya conditional variables mix karne hon:

```yaml
variables:
  - name: appName
    value: 'payment-service'
  - name: isProduction
    value: $[eq(variables['Build.SourceBranch'], 'refs/heads/main')]
  - group: global-infrastructure-vars   # Variable group link karna
```

### Variable Reference Expressions:

| Syntax Type | Syntax Example | Evaluation Timing | Typical Use Case |
| :--- | :--- | :--- | :--- |
| **Macro** | `$(appName)` | Task runtime | Tasks ke inputs, step display names, inline scripts |
| **Template** | `${{ variables.appName }}` | Compile / parse time | Template parameters, condition expressions, dynamic YAML |
| **Runtime** | `$[ variables.appName ]` | Job initialization | Job conditions, stage dependencies, cross-job outputs |

---

## 2. Variable Groups (Library)

**Variable Group** Azure DevOps portal ke **Pipelines > Library** section mein banta hai. Iska faida yeh hai ke ek bar banaye gaye variables ko muta'addid (multiple) pipelines ke andar direct reuse kiya ja sakta hai bina code modify kiye.

```
                  ┌─────────────────────────────────────────┐
                  │       Azure DevOps: Library             │
                  │   [ Variable Group: backend-vars ]      │
                  │   • DB_PORT: 5432                       │
                  │   • REDIS_HOST: redis.internal          │
                  └────────────────────┬────────────────────┘
                                       │
                   ┌───────────────────┴───────────────────┐
                   ▼                                       ▼
     [ Pipeline 1: Build-API ]               [ Pipeline 2: Deploy-API ]
     `variables: - group: backend-vars`      `variables: - group: backend-vars`
```

### YAML Integration:

```yaml
variables:
  - group: backend-vars           # Library se group attach kiya
  - name: localOverrideVar
    value: 'custom-build-flag'

steps:
  - script: |
      echo "Connecting to Redis at $(REDIS_HOST) on port $(DB_PORT)"
    displayName: 'Print Group Variables'
```

---

## 3. Azure Key Vault Integration

Production secrets (jaise Database passwords, Stripe private keys, SSL certs) ko Azure DevOps ke portal par plain text rakhne ke bajaye **Azure Key Vault** mein store karna enterprise standard hai.

```
[ Azure Key Vault ]  (Centralized, Audited HSM Storage)
         │
         ▼ (Managed Identity / Service Connection)
[ Azure DevOps: Library Variable Group ]  (Linked to Key Vault)
         │
         ▼
[ Azure Pipeline Task ]  (Fetched dynamically during execution)
```

### Setup Steps:
1. **Azure Portal:** Azure Key Vault banayein aur usme Secrets add karein (e.g. `DB-PROD-PASSWORD`).
2. **Azure DevOps Library:** Naya Variable Group banayein aur **"Link secrets from an Azure key vault"** enable karein.
3. **Service Connection:** Target Azure subscription aur Key Vault choose karein.
4. **Select Secrets:** Jin secrets ka access pipeline ko dena ho unhein choose karein.

### Method 1: Variable Group ke zariye direct attach karna:
```yaml
variables:
  - group: prod-keyvault-secrets   # Linked Key Vault Group

steps:
  - script: echo "Database password fetched securely!"
    env:
      DB_PASS: $(DB-PROD-PASSWORD)
```

### Method 2: `AzureKeyVault@2` Task ke zariye dynamically pull karna:
```yaml
steps:
  - task: AzureKeyVault@2
    inputs:
      azureSubscription: 'Azure-Production-ServiceConnection'
      KeyVaultName: 'my-corp-keyvault'
      SecretsFilter: 'DB-PASSWORD,STRIPE-KEY'
      RunAsPreJob: true
```

---

## 4. Secret Variables & Log Masking

Azure Pipelines mein sensitive variables ko **Secret** mark kiya ja sakta hai (UI mein lock icon 🔒 click karke ya Key Vault se link karke).

### A. The Masking Rule:
Agar koi script secret variable ko console par print karne ki koshish kare, toh Azure Pipelines use khud-ba-khud mask kar deta hai:

```bash
# Output inside pipeline logs:
Connecting with token: ***
```

### B. Secret Variables are NOT automatically Environment Variables!
Yeh Azure Pipelines ka ek bohot ahem security guardrail hai: **Secret variables bash/cmd scripts mein automatically environment variable ban kar inject nahi hotay.**

```yaml
# ❌ Ghalt (Secret bash environment mein exist nahi karega, khali aayega):
steps:
  - script: |
      echo "Token is: $MY_SECRET_TOKEN"   # Output: Token is: (Empty!)

# ✅ Sahi (Explicitly 'env' block mein pass karein):
steps:
  - script: |
      echo "Token injected into script environment securely"
      ./deploy.sh
    env:
      MY_SECRET_TOKEN: $(MySecretToken)   # Mapping zaroori hai!
```

---

## 5. Runtime & Output Variables (Dynamic Values)

Aksar humein pipeline chalte waqt dynamic values generate karni padti hain (e.g. dynamic version tag, test calculation, ya Terraform output) jo agli jobs ya stages ko chahiye hoti hain.

### A. Setting an Output Variable in Same Job:
Bash script ke andar `vso[task.setvariable]` syntax use kiya jata hai:

```yaml
steps:
  - script: |
      GENERATED_VER="v2.1.$(Build.BuildId)"
      echo "##vso[task.setvariable variable=APP_VERSION]$GENERATED_VER"
    displayName: 'Generate Dynamic Version'

  - script: |
      echo "Version is: $(APP_VERSION)"
    displayName: 'Use in subsequent step'
```

### B. Passing Output Variables Across Jobs:
Doosri job ko variable bhejne ke liye `isOutput=true` lagana parta hai aur `dependencies` configure karni hoti hain:

```yaml
jobs:
  # Job 1: Calculate
  - job: JobA
    steps:
      - script: |
          echo "##vso[task.setvariable variable=DEPLOY_TARGET;isOutput=true]west-europe"
        name: stepA

  # Job 2: Consume
  - job: JobB
    dependsOn: JobA
    variables:
      targetRegion: $[ dependencies.JobA.outputs['stepA.DEPLOY_TARGET'] ]
    steps:
      - script: echo "Deploying to dynamic region $(targetRegion)"
```

### C. Passing Output Variables Across Stages:
Agar stage boundary cross karni ho toh syntax `stageDependencies` ban jata hai:

```yaml
stages:
  - stage: BuildStage
    jobs:
      - job: BuildJob
        steps:
          - script: |
              echo "##vso[task.setvariable variable=PACKAGE_ID;isOutput=true]pkg-884"
            name: ProduceOutput

  - stage: DeployStage
    dependsOn: BuildStage
    variables:
      packageId: $[ stageDependencies.BuildStage.BuildJob.outputs['ProduceOutput.PACKAGE_ID'] ]
    jobs:
      - job: DeployJob
        steps:
          - script: echo "Deploying package: $(packageId)"
```

---

## 💡 Practical Cheatsheet: Variables Best Practices

1. **Hardcode Zero Secrets:** Kabhi bhi API keys ya passwords direct YAML repo mein commit na karein.
2. **Always Use `env:` for Secrets:** Secret variables ko script steps mein `env:` key ke zariye explicitly pass karein.
3. **Use Variable Groups for Environments:** Har environment (Dev, Staging, Prod) ke liye alag variable group banayein taake YAML reuse ho sake.
4. **Key Vault for Production Secrets:** Production level secrets hamesha Azure Key Vault se pull karein jahan access audit trails mojood hon.

---
**Status:** ✅ Complete