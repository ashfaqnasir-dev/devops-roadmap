# 📦 06.05 Azure Artifacts — Complete Guide

> **Azure Artifacts** Azure DevOps ka fully integrated package management service hai. Yeh teams ko code libraries, internal shared packages, aur third-party dependencies ko store, host, aur secure tareeqay se share karne ki sahulat deta hai. Iske zariye private **NuGet**, **npm**, **Maven**, **Python (PyPI)**, aur **Universal Packages** manage kiye jaate hain.

---

## 1. Feeds (Packages Ka Central Storehouse)

**Feed** ek organizational container ya repository hota hai jahan aapke tamam packages publish aur store hotay hain. Developers aur CI/CD pipelines isi feed se packages download (consume) ya upload (publish) karte hain.

```
┌─────────────────────────────────────────────────────────────┐
│                 Azure Artifacts Feed                        │
│                                                             │
│   ┌──────────────┐   ┌──────────────┐   ┌───────────────┐   │
│   │ NuGet (.NET) │   │  npm (Node)  │   │ PyPI (Python) │   │
│   └──────────────┘   └──────────────┘   └───────────────┘   │
│                                                             │
│         ▲ Upstream Caching                                  │
│         │                                                   │
│   [ nuget.org / npmjs.com / pypi.org (Public Registries) ]  │
└─────────────────────────────────────────────────────────────┘
```

### A. Feed Visibility Scopes:
1. **Project-Scoped Feed:**
   * Feed sirf usi specific Azure DevOps Project ke users aur pipelines ke liye accessible hoti hai.
   * Fine-grained control aur team-level separation ke liye behtareen hai.
2. **Organization-Scoped Feed:**
   * Poori organization ke multiple projects is feed ke packages aapas mein share kar sakte hain.
   * Common corporate shared libraries ke liye mufeed hai.

### B. Feed Views & Package Lifecycle:
Feed views ke zariye aap production-ready packages ko experimental/draft builds se alag rakhte hain bina alag feed banaye:
* `@local`: Tamam packages jo feed mein direct publish hue.
* `@prerelease`: Testing aur staging ke liye verified packages.
* `@release`: Stable, production-ready packages jinko QA aur leads ne approve kiya ho.

---

## 2. NuGet Packages (.NET Ecosystem)

.NET applications ke common components (e.g., Company Logging Helper, Shared Authentication Models) ko Azure Artifacts ke zariye reuse kiya jata hai.

### A. Local Machine Setup (`nuget.config`):
Private feed se connect karne ke liye project ke root par `nuget.config` file banayi jaati hai:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="MyCompanyFeed" value="https://pkgs.dev.azure.com/{YourOrg}/{YourProject}/_packaging/{FeedName}/nuget/v3/index.json" />
  </packageSources>
</configuration>
```

### B. Pipeline mein NuGet Package Build & Push:

```yaml
steps:
- task: DotNetCoreCLI@2
  displayName: 'Pack .NET Library'
  inputs:
    command: 'pack'
    packagesToPack: '**/*.csproj'
    versioningScheme: 'byPrereleaseNumber'

- task: DotNetCoreCLI@2
  displayName: 'Push NuGet Package to Azure Artifacts'
  inputs:
    command: 'push'
    packagesToPush: '$(Build.ArtifactStagingDirectory)/*.nupkg'
    nuGetFeedType: 'internal'
    publishVstsFeed: '{YourProject}/{FeedName}'
```

---

## 3. npm Packages (Node.js & JavaScript Ecosystem)

Frontend UI design systems (React/Vue UI libraries) ya backend shared utilities ko manage karne ke liye npm feeds use hoti hain.

### A. Local Machine Setup (`.npmrc`):
Project ke root par `.npmrc` file define ki jaati hai:

```ini
registry=https://pkgs.dev.azure.com/{YourOrg}/{YourProject}/_packaging/{FeedName}/npm/registry/
always-auth=true
```

> 💡 **Local Auth Helper:** Developers apne workstation par authentication ke liye Microsoft ka official tool install karte hain:  
> `npm install -g vsts-npm-auth --registry https://registry.npmjs.org --always-auth false`  
> Phir command chalate hain: `vsts-npm-auth -config .npmrc`

### B. Pipeline mein npm Authenticate & Publish:

```yaml
steps:
- task: npmAuthenticate@0
  displayName: 'Authenticate npm with Azure Artifacts'
  inputs:
    workingFile: '.npmrc'

- script: |
    npm version patch
    npm publish
  displayName: 'Publish Package to Azure Artifacts'
```

---

## 4. Upstream Sources (Caches & Security Protection)

Agar aapki application mein 10 public open-source packages aur 2 internal private packages hain, toh har bar public registry (npmjs.com ya nuget.org) par jane ke bajaye **Upstream Sources** enable kiye jaate hain.

```
Developer Workstation / CI Runner
               │ (Single Feed URL)
               ▼
   [ Azure Artifacts Feed ]
         ├── Internal Package (Direct match)
         └── External Package (npmjs.com se download kiya aur feed mein cache kar liya)
```

### Upstream Sources ke Fawaid:
1. **Single Unified Endpoint:** Developers aur CI pipelines ko sirf ek feed URL configure karna parta hai, chahe package public ho ya private.
2. **Local Caching & High Availability:** Jab koi developer public library download karta hai, Azure Artifacts uski ek copy feed mein hamesha ke liye store kar leta hai. Agar public `npmjs.com` down bhi ho jaye, pipeline kabhi break nahi hogi.
3. **Protection against Deleted Packages (The "LeftPad" Problem):** Agar public package author apni library public registry se delete kar de, aapki organization ke feed mein cached copy mehfooz rehti hai.
4. **Dependency Confusion Attacks se Bachao:** Attacker public registry par aapke internal private package ke naam se malicious package push karke pipeline compromise nahi kar sakta, kyunki Azure Artifacts internal packages ko priority deta hai.

---

## 💡 Best Practices Summary for Azure Artifacts

* **Hamesha Semantic Versioning (SemVer) use karein:** `MAJOR.MINOR.PATCH` (e.g., `1.0.4`). Azure Artifacts mein ek martaba publish hua version dobara overwrite nahi kiya ja sakta (Immutability rule).
* **Pipelines mein Dedicated Tasks use karein:** Credentials hardcode karne ke bajaye hamesha built-in auth tasks (`npmAuthenticate`, `NuGetAuthenticate`) use karein.
* **Retention Policies Set Karein:** Har CI build par banne wale unreleased packages storage space aur cost barhate hain; auto-retention rules set karein taake purane untagged packages automatically purge ho sakein.

---
**Status:** ✅ Complete