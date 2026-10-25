# 🚀 06.03 Azure Pipelines — Complete Guide

> **Azure Pipelines** Microsoft Azure DevOps ka cloud-native CI/CD service hai jo kisi bhi language, platform, aur cloud (Azure, AWS, GCP, ya on-premise) par code build, test, aur automatically deploy karne ki sahulat deta hai.

---

## 1. YAML vs Classic Pipelines

Azure DevOps mein pipelines configure karne ke do mukhtalif andaz hain:

```
[ Classic Editor ] ──────── GUI Forms / Dropdowns (Stored in Azure DevOps DB)
                                 VS
[ YAML Pipelines ] ──────── Code as Configuration (Stored in Git Repository)
```

| Feature | YAML Pipelines (Modern & Recommended) | Classic Pipelines (Legacy UI) |
| :--- | :--- | :--- |
| **Storage** | Git repository ke andar `azure-pipelines.yml` file mein | Azure DevOps ke UI/web database ke andar |
| **Pipeline-as-Code** | **Yes** — Version controlled, branched, aur PR reviewable | **No** — GUI clicks se banti hai, diff dekhna mushkil |
| **Traceability** | Har commit aur branch ke sath pipeline ka version badal sakta hai | Single global config hoti hai sabhi branches ke liye |
| **Multi-Stage CI/CD** | CI aur CD dono ek hi YAML file mein stages ke zariye handle hotay hain | CI (Build) aur CD (Release) ke liye alag alag UI screens |
| **Industry Adoption** | 100% cloud-native standard | Phased out / deprecated ho raha hai |

> 💡 **Best Practice:** Production projects ke liye hamesha **YAML pipelines** chunein taake pipeline configuration ka mukammal audit trail aapke Git repo mein mojood rahe.

---

## 2. Build Pipelines (CI in YAML)

Build pipeline ka maqsad code compile karna, unit tests run karna, aur deployable **Build Artifact** generate karna hota hai.

### Standard YAML Hierarchy:
```
Pipeline (trigger, pool, variables)
  └── stages
        └── stage (Build)
              └── jobs
                    └── job (Compile & Test)
                          └── steps (checkout, script, task)
```

### Complete Practical Example:

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'

stages:
- stage: BuildAndTest
  displayName: 'Build and Unit Test'
  jobs:
  - job: Compile
    displayName: 'Compile Node.js Application'
    steps:
    - uses: actions/checkout@v4   # Agar GitHub ho, warna ADO automatic checkout karta hai
    
    - task: NodeTool@0
      displayName: 'Install Node.js 18.x'
      inputs:
        versionSpec: '18.x'

    - script: |
        npm ci
        npm run build
        npm test
      displayName: 'npm install, build & test'

    - task: PublishBuildArtifacts@1
      displayName: 'Publish Dist Artifact'
      inputs:
        PathtoPublish: '$(System.DefaultWorkingDirectory)/dist'
        ArtifactName: 'drop'
        publishLocation: 'Container'
```

---

## 3. Release Pipelines (CD in YAML vs Classic)

Release pipeline build stage se niklay hue artifact ko fetch karke targeted environments (Dev, Staging, Production) par deploy karti hai.

### Unified Multi-Stage YAML Pipeline (CI + CD):

```yaml
stages:
- stage: Build
  displayName: 'Build Stage'
  jobs:
  - job: BuildJob
    steps:
    - script: echo "Building app..."

- stage: DeployDev
  displayName: 'Deploy to Development'
  dependsOn: Build
  condition: succeeded()
  jobs:
  - deployment: DeployDevJob
    environment: 'development'
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo "Deploying artifact to Dev VM/K8s..."

- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: DeployDev
  condition: succeeded()
  jobs:
  - deployment: DeployProdJob
    environment: 'production' # Approvals yahan trigger honge
    strategy:
      runOnce:
        deploy:
          steps:
          - script: echo "Deploying live to Production..."
```

---

## 4. Agents & Agent Pools

Pipeline ke tasks physically kisi na kisi computer ya virtual machine par run hotay hain jise **Agent** kehte hain. Multiple agents ke group ko **Agent Pool** kaha jata hai.

```
                  ┌─────────────────────────────────────────┐
                  │               Agent Pool                │
                  ├────────────────────┬────────────────────┤
                  │  Microsoft-Hosted  │    Self-Hosted     │
                  │  • Ephemeral VM    │  • Private VM/K8s  │
                  │  • Clean each run  │  • Custom tools    │
                  │  • Azure-managed   │  • VPC access      │
                  └────────────────────┴────────────────────┘
```

| Khasiyat | Microsoft-Hosted Agents | Self-Hosted Agents |
| :--- | :--- | :--- |
| **Maintenance** | Microsoft OS, patches aur software khud update karta hai | OS updates, Docker setup, aur software aapko manage karna parta hai |
| **Lifecycle** | Ephemeral (har job ke baad VM delete ho kar fresh milti hai) | Persistent (build cache preserve rehti hai) |
| **Network Access** | Public internet se private on-prem ya VPC access karna mushkil | Corporate private network, internal database, aur LAN se seedha connect |
| **OS Options** | `ubuntu-latest`, `windows-latest`, `macos-latest` | Koi bhi Linux, Windows, macOS machine ya Docker container |

---

## 5. Service Connections

Azure Pipelines ko external systems (Azure Subscription, AWS, Docker Hub, Kubernetes, GitHub) se securely baat cheet karne ke liye credentials chahiye hotay hain. **Service Connection** authentication secrets ko centralized aur secure store karne ka zariya hai bina unhein YAML file mein likhe.

```
[ YAML Pipeline ] ──► (Calls Connection Name) ──► [ Service Connection ] ──► [ Azure Cloud / AWS ]
                                                         │
                                                (Workload Identity /
                                                 Service Principal)
```

### Popular Service Connection Types:
1. **Azure Resource Manager (ARM):** Azure subscription ya resource group ko target karne ke liye (Service Principal ya modern **Workload Identity Federation / OIDC** ke zariye).
2. **Docker Registry:** Docker Hub ya Azure Container Registry (ACR) par images push/pull karne ke liye.
3. **Kubernetes:** Kubeconfig ya Service Account ke zariye K8s cluster par deploy karne ke liye.
4. **SSH / Generic:** Linux servers par remote commands chalane ke liye.

### Example YAML Usage:
```yaml
- task: AzureWebApp@1
  inputs:
    azureSubscription: 'Prod-Azure-Subscription-ServiceConnection'
    appType: 'webAppLinux'
    appName: 'my-production-api'
    package: '$(System.ArtifactsDirectory)/**/*.zip'
```

---

## 6. Environments & Approvals

YAML pipelines mein **Environment** target resources (Virtual Machines, Kubernetes namespaces, Web Apps) ka logical collection hota hai jahan application deploy hoti hai.

### Key Capabilities:
* **Deployment History:** Dekhein kis commit aur pipeline run ne is environment par deploy kiya.
* **Checks & Approvals:** Production environment par code deploy hone se pehle safety controls lagana:
  * **Manual Approvals:** Senior engineers ya release managers ka sign-off.
  * **Business Hours:** Sirf subah 9 se shaam 5 ke darmiyan deployment allow karna.
  * **Exclusive Lock:** Ek waqt mein sirf ek hi deployment chalne dena.
  * **Invoke REST API / Azure Monitor Alerts:** Deployment rok dena agar live system par koi alert active ho.

```
Pipeline Run
     │
     ▼
Deploy to 'production' (Environment detected)
     │
     ├── ⏸️ Pipeline Paused: "Waiting for approval from @DevOpsLead"
     │
     ▼ (DevOps Lead clicks 'Approve' in Azure DevOps portal)
Deploy Steps Execute 🚀
```

---
**Status:** ✅ Complete