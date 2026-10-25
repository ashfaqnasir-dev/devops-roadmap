# 🏗️ 07.02 Pipeline Structure — Complete Guide

> Modern CI/CD platforms (khasosan **Azure Pipelines** aur **GitHub Actions**) mein pipeline ek structured tree hierarchy ki tarah organize hoti hai. Root configuration se le kar individual command execution tak har block ki apni makhsoos zimmedari aur scope hota hai.

---

## Complete Pipeline Architecture (Hierarchy)

Pipeline ka structural flow top-down is tarah work karta hai:

```
[ trigger ]   ──► Pipeline kab shuru hogi? (Events, Branches, Tags)
[ variables ] ──► Pipeline ke global values & configurations
[ pool ]      ──► Pipeline kin machines par run hogi (Hosted / Self-hosted)
   │
   └──► [ stages ]        ──► Major phases (e.g., Build, Test, Deploy)
           │
           └──► [ jobs ]          ──► Independent execution units on specific agents
                   │
                   └──► [ steps ]         ──► Sequential actions (checkout, tasks, scripts)
```

---

## 1. `trigger` (Pipeline Kab Run Hogi?)

`trigger` batata hai ke repository mein kis event (push, tag, ya branch update) par pipeline automatically execute honi chahiye.

### A. Branch Triggers (Push Events):

```yaml
# Specific branches include aur exclude karna
trigger:
  branches:
    include:
      - main
      - releases/*
    exclude:
      - releases/old-*
  paths:
    include:
      - src/**          # Sirf tab chaley jab 'src' folder change ho
    exclude:
      - README.md       # Docs change hone par pipeline na chaley
```

### B. Disable CI Trigger (Manual Only):

```yaml
trigger: none   # Automatic push trigger band; sirf manual ya PR par chalegi
```

### C. Tag Triggers (Releases ke liye):

```yaml
trigger:
  tags:
    include:
      - v1.*
      - release-*
```

---

## 2. `pool` (Jobs Kahan Run Honge?)

`pool` define karta hai ke tasks chalane ke liye kon si virtual machine ya container agent assign kiya jayega.

### A. Microsoft-Hosted Agents:

Aap cloud provider ki clean, managed VM choose karte hain:

```yaml
pool:
  vmImage: 'ubuntu-latest'     # Options: 'windows-latest', 'macos-latest'
```

### B. Self-Hosted Agent Pool:

Aapki apni private VM ya on-premise server pool:

```yaml
pool:
  name: 'Default'             # Azure DevOps Agent Pool ka naam
  demands:
    - Agent.OS -equals Linux
    - docker                   # Wahi agent uthaye jis par Docker installed ho
```

> 💡 **Scope Rule:** Agar `pool` root level par define ho toh tamam jobs par apply hoga. Agar kisi job ko Windows aur doosri ko Linux chahiye ho, toh `pool` ko individual job level par bhi override kiya ja sakta hai.

---

## 3. `variables` (Configuration & Values Management)

Variables pipeline ke andar dynamic values, paths, aur environment flags store karne ke liye use hotay hain.

```yaml
variables:
  # 1. Simple Key-Value
  buildConfiguration: 'Release'
  appVersion: '1.2.0'

  # 2. Variable Groups (Library / Azure Key Vault secrets)
  - group: prod-credentials-group

  # 3. Conditional / Environment-based Variables
  - name: environmentName
    value: $[ coalesce(variables['customEnv'], 'development') ]
```

### Syntax for Referencing Variables:
* **Macro Syntax (Most Common):** `$(buildConfiguration)` — Task inputs aur scripts mein evaluate hota hai.
* **Template Expression:** `${{ variables.appVersion }}` — Pipeline parse time par replace hota hai.
* **Runtime Expression:** `$[ variables.myVar ]` — Job start hone se pehle evaluate hota hai.

---

## 4. `stages` (Major Pipeline Milestones)

`stages` pipeline ka sabse bara logical division hote hain (jaise *Build*, *Test*, *Staging*, *Production*).

### Khasiyat:
* Har stage aam tor par ek naya boundary create karta hai.
* By default, stages **sequentially (ek ke baad ek)** run hotay hain agar `dependsOn` use kiya jaye.
* Approvals, security checks aur environment gates hamesha **Stage** ya deployment job level par lagte hain.

```yaml
stages:
  - stage: Build
    displayName: 'Compile & Unit Test'
    jobs:
      - job: BuildJob
        steps:
          - script: echo "Building..."

  - stage: Production
    displayName: 'Deploy to Production'
    dependsOn: Build            # Pehle 'Build' stage pass hona zaroori hai
    condition: succeeded()      # Agar pichla stage fail hua toh yeh nahi chalega
    jobs:
      - job: DeployJob
        steps:
          - script: echo "Deploying..."
```

---

## 5. `jobs` (Execution Units on Agents)

Har stage ke andar ek ya muta'addid (multiple) `jobs` hoti hain. 

### A. Core Rules of Jobs:
1. **Isolated Machines:** Har job ko ek **alag runner/agent** milta hai.
2. **Parallel by Default:** Ek stage ke andar agar 3 jobs hain, toh woh **simultaneously (parallel)** execute hongi jab tak unke darmiyan dependency na set ki jaye.
3. **Clean Workspace:** Job 1 ki local files Job 2 ko tab tak nahi milti jab tak unhein **Artifacts** ke zariye share na kiya jaye.

```yaml
jobs:
  - job: TestBackend
    displayName: 'Backend API Tests'
    steps:
      - script: npm run test:backend

  - job: TestFrontend
    displayName: 'Frontend UI Tests'
    # Yeh job TestBackend ke parallel chalegi (time bachega)
    steps:
      - script: npm run test:frontend
```

---

## 6. `steps` (Individual Sequential Tasks)

`steps` job ke andar chalne wale chhotay practical actions hote hain jo bilkul **line-by-line (sequentially)** execute hotay hain.

Steps teen qisam ke ho sakte hain:

```yaml
steps:
  # 1. Inline Shell Scripts (`script` ya `bash`)
  - script: |
      echo "Starting setup..."
      mkdir -p output/
    displayName: 'Run Inline Shell Commands'

  # 2. Built-in Tasks (`task`)
  - task: NodeTool@0
    displayName: 'Install Node.js'
    inputs:
      versionSpec: '20.x'

  # 3. Reusable Templates (`template`)
  - template: templates/security-scan.yml
```

---

## 💡 Complete Production-Ready YAML Template

Yeh ek complete pipeline hai jisme tamam components (`trigger`, `pool`, `variables`, `stages`, `jobs`, `steps`) aapas mein integrate hain:

```yaml
# 1. Pipeline Trigger
trigger:
  branches:
    include:
      - main

# 2. Global Agent Pool
pool:
  vmImage: 'ubuntu-latest'

# 3. Global Variables
variables:
  nodeVersion: '20.x'
  artifactName: 'drop'

# 4. Stages Hierarchy
stages:
  # ================= Stage 1: Build & Quality =================
  - stage: BuildAndTest
    displayName: 'Build and Verify'
    jobs:
      - job: Compile
        displayName: 'Install, Build & Test'
        steps:
          - task: NodeTool@0
            displayName: 'Setup Node.js Environment'
            inputs:
              versionSpec: $(nodeVersion)

          - script: |
              npm ci
              npm run build
              npm test
            displayName: 'Execute Build & Test Scripts'

          - task: PublishPipelineArtifact@1
            displayName: 'Upload Build Artifact'
            inputs:
              targetPath: '$(System.DefaultWorkingDirectory)/dist'
              artifact: $(artifactName)

  # ================= Stage 2: Production Release =================
  - stage: DeployProd
    displayName: 'Production Deployment'
    dependsOn: BuildAndTest
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - deployment: DeployApp
        displayName: 'Deploy Web App'
        environment: 'production'     # Approval gates yahan trigger hongi
        strategy:
          runOnce:
            deploy:
              steps:
                - download: current
                  artifact: $(artifactName)

                - script: |
                    echo "🚀 Deploying artifact to live production servers..."
                  displayName: 'Deploy Steps'
```

---
**Status:** ✅ Complete