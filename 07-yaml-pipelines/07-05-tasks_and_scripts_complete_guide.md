# ⚙️ 07.05 Tasks & Scripts — Complete Guide

> Azure Pipelines ke andar actual kaam **Tasks** aur **Scripts** ke zariye execute hota hai. Tasks pre-packaged automation blocks hote hain jo complex operations (jaise artifacts publish karna, Docker build karna, ya cloud deployment) ko simplify karte hain, jabke scripts raw OS-level control aur custom logic provide karti hain.

---

## 1. Built-in Tasks (`task`)

Built-in tasks Microsoft ya Azure DevOps marketplace ke pre-configured reusable plugins hote hain. Inka faida yeh hota hai ke aapko raw CLI commands aur unki error handling khud nahi likhni parti.

### A. Task Structure & Syntax:
Task reference mein task ka naam aur version tag shamil hota hai: `TaskName@Version`.

```yaml
steps:
  - task: TaskName@Version
    displayName: 'Human Readable Action Name'
    inputs:
      inputKey1: 'value1'
      inputKey2: 'value2'
    condition: succeeded()
    continueOnError: false
```

### B. Core Essential Built-in Tasks:

| Task Identifier | Purpose / Kaam | Practical Use Case |
| :--- | :--- | :--- |
| `NodeTool@0` / `UsePythonVersion@0` | Tool Installer | Runner par specific language runtime version setup karna |
| `PublishPipelineArtifact@1` | Artifact Storage | Build output ko agle stages ke liye upload karna |
| `DownloadPipelineArtifact@2` | Artifact Retrieval | Pehle se build hua binary/drop folder download karna |
| `Docker@2` | Container Operations | Docker images build karna, login karna aur push karna |
| `AzureResourceManagerTemplateDeployment@3` | IaC Deployment | ARM templates ya Bicep files deploy karna |

```yaml
# Practical Example: Tool Installer + Artifact Publish
steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.11'
      addToPath: true

  - task: PublishPipelineArtifact@1
    inputs:
      targetPath: '$(Build.ArtifactStagingDirectory)'
      artifact: 'drop'
      publishLocation: 'pipeline'
```

---

## 2. Generic Script Step (`script`)

`script` step sabse simple shortcut hai jo runner machine ki **default command-line shell** ko invoke karta hai.

```
Linux / macOS Agent ──────► executes in bash
Windows Agent        ──────► executes in cmd.exe
```

### A. Syntax:
```yaml
steps:
  - script: echo "Hello from default shell!"
    displayName: 'Single Line Script'

  - script: |
      echo "Step 1: Running unit tests..."
      npm test
      echo "Step 2: Checking build status..."
    displayName: 'Multi-line Script'
```

### B. Use Cases & Limitations:
* **Best For:** Simple commands jo platform-agnostic hon ya direct utility commands (`npm install`, `go build`).
* **Trap:** Cross-platform pipelines mein masla karta hai; Windows agent par bash syntax (jaise `export VAR=1`) fail ho jayega kyunki wahan default `cmd.exe` chalta hai.

---

## 3. Bash Step (`bash`)

`bash` step explicitly **GNU Bash** shell ko call karta hai. Yeh Linux aur macOS agents par naturally natively chalta hai, jabke Windows agents par Azure DevOps iske liye built-in Git Bash runtime use karta hai.

### A. Syntax & Error Trapping:
```yaml
steps:
  - bash: |
      set -euo pipefail  # Strict error checking mode

      echo "Current User: $(whoami)"
      CURRENT_BRANCH="$(Build.SourceBranchName)"
      echo "Branch is: $CURRENT_BRANCH"

      if [ "$CURRENT_BRANCH" = "main" ]; then
        echo "Running production validation..."
      fi
    displayName: 'Execute Strict Bash Script'
    failOnStderr: false
```

### B. Key Advantages:
* **Deterministic Behavior:** Script Linux, Mac, aur Windows (via Git Bash) teeno par taqreeban ek hi tarah behave karegi.
* **Complex Logic:** Loops, shell arrays, regex checks aur native Linux CLI utilities (`sed`, `awk`, `curl`, `jq`) ke liye standard choice hai.

---

## 4. PowerShell Core Step (`pwsh`)

`pwsh` step modern cross-platform **PowerShell Core (PowerShell 7+)** ko run karta hai. 

> ⚠️ **`powershell` vs `pwsh`:**  
> - `powershell`: Legacy Windows PowerShell 5.1 (sirf Windows agents par chalega).  
> - `pwsh`: Modern PowerShell Core (Linux, macOS, aur Windows teeno par support hota hai).

### A. Syntax:
```yaml
steps:
  - pwsh: |
      Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"
      
      $apiResponse = Invoke-RestMethod -Uri "https://api.github.com/zen"
      Write-Host "GitHub Zen: $apiResponse"
      
      $services = @("api", "auth", "worker")
      foreach ($s in $services) {
          Write-Output "Checking service status: $s"
      }
    displayName: 'Execute Cross-Platform PowerShell Core'
```

### B. Comparison: `script` vs `bash` vs `pwsh`

| Feature | `script` | `bash` | `pwsh` |
| :--- | :--- | :--- | :--- |
| **Shell Type** | Default OS Shell | GNU Bash / Git Bash | PowerShell Core 7+ |
| **Windows Behavior** | Runs in `cmd.exe` | Runs in Git Bash | Runs in `pwsh.exe` |
| **Linux/Mac Behavior** | Runs in `/bin/bash` | Runs in `/bin/bash` | Runs in `/usr/bin/pwsh` |
| **Data Handling** | Raw Strings / Text | Text streams (`jq`, `grep`) | Rich Objects & JSON |
| **Best For** | Fast single commands | DevOps Linux automation | Windows workloads & API/JSON scripting |

---

## 5. Custom Tasks (Marketplace & Extension Development)

Jab kisi internal enterprise team ko proprietary build steps bar bar darjanon repositories mein chalane hon, toh inline scripts copy-paste karne ke bajaye **Custom Azure DevOps Task** banaya jata hai.

```
[ Developer / DevOps Engineer ]
              │ (Codes extension)
              ▼
    [ TypeScript / Node.js ] ──► task.json + index.ts
              │
              ▼ (Packaged via 'tfx-cli')
    [ .vsix Extension File ]
              │
              ▼ (Published)
[ Azure DevOps Organization / Marketplace ]
              │
              ▼ (Referenced in pipeline)
    `task: MyEnterpriseScanner@1`
```

### A. Structure of a Custom Task:
Ek custom task folder mein 2 core files hoti hain:
1. **`task.json`:** Task ka metadata, input fields, display labels, aur execution entry point define karta hai.
2. **`index.ts` / `index.js`:** Actual execution script (Node.js engine use hota hai via `azure-pipelines-task-lib`).

#### Example `task.json`:
```json
{
  "$schema": "https://raw.githubusercontent.com/Microsoft/azure-pipelines-task-lib/master/tasks.schema.json",
  "id": "c1f7a2d4-1234-4567-89ab-cdef01234567",
  "name": "CustomSecurityScanner",
  "friendlyName": "Corporate Security Scanner",
  "description": "Scans internal compliance rules",
  "category": "Utility",
  "author": "DevOps Core Team",
  "version": {
    "Major": 1,
    "Minor": 0,
    "Patch": 0
  },
  "inputs": [
    {
      "name": "targetDirectory",
      "type": "string",
      "label": "Directory to scan",
      "defaultValue": "$(Build.SourcesDirectory)",
      "required": true
    }
  ],
  "execution": {
    "Node16": {
      "target": "index.js"
    }
  }
}
```

#### Example Implementation (`index.ts`):
```typescript
import tl = require('azure-pipelines-task-lib/task');

async function run() {
    try {
        const targetDir: string | undefined = tl.getInput('targetDirectory', true);
        console.log(`Scanning target directory: ${targetDir}`);

        // Custom validation logic here...
        
        tl.setResult(tl.TaskResult.Succeeded, 'Scanning completed without compliance breaches.');
    } catch (err: any) {
        tl.setResult(tl.TaskResult.Failed, err.message);
    }
}

run();
```

### B. Packaging & Publishing Workflow:
1. **Tool Install:** `npm install -g tfx-cli`
2. **Extension Package:** `tfx extension create --manifest-globs vss-extension.json`
3. **Upload:** Azure DevOps Visual Studio Marketplace publisher portal par upload karke apni organization ke sath share karein.

---

## 💡 Practical Cheatsheet: Which One to Choose?

```
Need a standard operation (Docker build, Artifact drop, Cloud deploy)?
  └──► Use a Built-in Task (`task: ...`)

Need quick, single commands for a specific Linux-only project?
  └──► Use `script:` or `bash:`

Need strict, deterministic shell scripts across mixed OS agents?
  └──► Use `bash:` with strict mode (`set -euo pipefail`)

Working heavily with JSON payloads, APIs, or Windows-first environments?
  └──► Use `pwsh:`

Need to standardize custom complex corporate compliance across 50+ repos?
  └──► Develop a Custom Extension Task (`task.json`)
```

---
**Status:** ✅ Complete