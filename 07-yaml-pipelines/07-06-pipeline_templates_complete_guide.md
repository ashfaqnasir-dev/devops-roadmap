# 🧩 07.06 Templates — Complete Guide

> CI/CD pipelines mein code duplication (bar bar wahi steps copy-paste karna) ek baray maintenance nightmare ko janam deta hai. **Templates** Azure Pipelines ka sabse powerful feature hain jo **DRY (Don't Repeat Yourself)** principle ko enforce karte hain. Iske zariye aap standardized, reusable building blocks bana sakte hain jo multiple pipelines aur repositories mein share ho sakte hain.

---

## Templates Architecture & Hierarchy Overview

Templates ko pipeline ke har structural level par reuse kiya ja sakta hai:

```
[ Root Pipeline: azure-pipelines.yml ]
         │
         ├──► [ Stage Template ]       (Complete lifecycle phase: e.g. Deploy to an Env)
         │           │
         │           └──► [ Job Template ]         (Isolated task runner: e.g. Build & Package)
         │                     │
         │                     └──► [ Step Template ]       (Reusable action list: e.g. Setup Node & Lint)
         │
         └──► [ Variable Template ]    (Shared global parameters & values)
```

### Key Concepts: Compile-Time Evaluation (`${{ }}`)
Templates runtime par nahi balki **pipeline parse / compile time** par expand (insert) hote hain. Iska matlab hai ke pipeline start hone se pehle hi template ka code main file ka hissa ban jata hai.

---

## 1. Step Templates (`steps`)

Step templates sabse chhotay aur sabse aam reusable blocks hote hain. Yeh un steps ka collection hote hain jo multiple jobs ya pipelines mein bar bar repeat hotay hain (jaise linter chalana, test execute karna, ya cache restore karna).

### A. Template File (`templates/steps-build-test.yml`):
```yaml
# Step template definition with parameters
parameters:
  - name: nodeVersion
    type: string
    default: '20.x'
  - name: runTests
    type: boolean
    default: true

steps:
  - task: NodeTool@0
    displayName: 'Setup Node.js ${{ parameters.nodeVersion }}'
    inputs:
      versionSpec: ${{ parameters.nodeVersion }}

  - script: npm ci
    displayName: 'Install Dependencies'

  - ${{ if eq(parameters.runTests, true) }}:
    - script: npm test
      displayName: 'Run Automated Tests'
```

### B. Calling Step Template (`azure-pipelines.yml`):
```yaml
jobs:
  - job: FrontendBuild
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - checkout: self
      
      # Step Template ko include karna:
      - template: templates/steps-build-test.yml
        parameters:
          nodeVersion: '18.x'
          runTests: true

      - script: npm run build
        displayName: 'Build Production Bundle'
```

---

## 2. Job Templates (`jobs`)

Job templates poori ek execution unit (agent machine, pool settings, aur steps) ko encapsulate karte hain. Yeh specific build matrices ya repeated worker tasks ke liye use hotay hain.

### A. Template File (`templates/job-docker-build.yml`):
```yaml
parameters:
  - name: jobName
    type: string
    default: 'BuildDocker'
  - name: imageRepository
    type: string
  - name: dockerfilePath
    type: string
    default: '$(Build.SourcesDirectory)/Dockerfile'

jobs:
  - job: ${{ parameters.jobName }}
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - checkout: self
      - script: |
          echo "Building image: ${{ parameters.imageRepository }}:$(Build.BuildId)"
          docker build -t ${{ parameters.imageRepository }}:$(Build.BuildId) -f ${{ parameters.dockerfilePath }} .
        displayName: 'Docker Build Script'
```

### B. Calling Job Template (`azure-pipelines.yml`):
```yaml
stages:
  - stage: BuildImages
    jobs:
      # Pehli image build karein
      - template: templates/job-docker-build.yml
        parameters:
          jobName: 'BuildBackend'
          imageRepository: 'myregistry.azurecr.io/backend-service'
          dockerfilePath: 'backend/Dockerfile'

      # Doosri image parallel build karein
      - template: templates/job-docker-build.yml
        parameters:
          jobName: 'BuildFrontend'
          imageRepository: 'myregistry.azurecr.io/frontend-ui'
          dockerfilePath: 'frontend/Dockerfile'
```

---

## 3. Stage Templates (`stages`)

Stage templates poore release workflow ya multi-environment deployment pattern ko standardize karne ke liye use hotay hain. For example: Dev, Staging aur Production ke liye exact same deployment logic chahiye, sirf connection strings aur variables alag hain.

### A. Template File (`templates/stage-deploy-env.yml`):
```yaml
parameters:
  - name: environmentName
    type: string
  - name: serviceConnection
    type: string
  - name: appName
    type: string

stages:
  - stage: Deploy_${{ parameters.environmentName }}
    displayName: 'Deploy to ${{ parameters.environmentName }}'
    jobs:
      - deployment: DeployApp
        environment: ${{ parameters.environmentName }} # Approval gates yahan apply hongi
        strategy:
          runOnce:
            deploy:
              steps:
                - script: |
                    echo "Connecting via ${{ parameters.serviceConnection }}"
                    echo "Deploying to target app ${{ parameters.appName }} in ${{ parameters.environmentName }}"
                  displayName: 'Execute Cloud Rollout'
```

### B. Calling Stage Template in Main Pipeline:
```yaml
trigger:
  - main

stages:
  # 1. Dev Deployment
  - template: templates/stage-deploy-env.yml
    parameters:
      environmentName: 'development'
      serviceConnection: 'Azure-Dev-Subscription'
      appName: 'dev-api-service'

  # 2. Staging Deployment
  - template: templates/stage-deploy-env.yml
    parameters:
      environmentName: 'staging'
      serviceConnection: 'Azure-Staging-Subscription'
      appName: 'staging-api-service'

  # 3. Production Deployment (With Gate Approvals)
  - template: templates/stage-deploy-env.yml
    parameters:
      environmentName: 'production'
      serviceConnection: 'Azure-Prod-Subscription'
      appName: 'prod-api-service'
```

---

## 4. Variable Templates (`variables`)

Jab aapko bohot se common variables (paths, version tags, standard naming flags) ko multiple pipelines mein share karna ho, toh unhein alag YAML variable templates mein rakha jata hai.

### A. Template File (`templates/vars-common.yml`):
```yaml
variables:
  defaultPool: 'ubuntu-latest'
  dotnetVersion: '8.0.x'
  artifactDirectory: '$(Build.ArtifactStagingDirectory)/drop'
  corporateTag: 'Enterprise-DevOps-Managed'
```

### B. Calling Variable Template (`azure-pipelines.yml`):
```yaml
variables:
  # Common variables include karein:
  - template: templates/vars-common.yml
  
  # Pipeline-specific local variables add karein:
  - name: localPipelineVar
    value: 'my-unique-setting'

pool:
  vmImage: $(defaultPool)

steps:
  - script: |
      echo "DotNet Target Version: $(dotnetVersion)"
      echo "Artifact Dir: $(artifactDirectory)"
    displayName: 'Print Reused Variables'
```

---

## 💡 Practical Cheatsheet: Template Rules & Best Practices

| Rule | Explanation / Why it Matters |
| :--- | :--- |
| **Strict Type Parameters** | Hamesha parameters mein `type: string / boolean / number / object` define karein taake input validation parse-time par ho sake. |
| **Cross-Repository Templates** | Agar templates kisi central DevOps repository mein hon, toh `resources.repositories` use karke unhein access kiya ja sakta hai (`template: file.yml@central-templates`). |
| **Security Enforcement** | Corporate security policies enforce karne ke liye aap developers ko restricted root pipeline template de sakte hain jisme security scan tasks pehle se mandatory shamil hon. |
| **Macro vs Template Syntax** | Template parameters ko expand karne ke liye hamesha `${{ parameters.name }}` use karein, `$(parameters.name)` nahi! |

---
**Status:** ✅ Complete