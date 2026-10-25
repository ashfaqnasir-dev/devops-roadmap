# 🏢 06.06 Organization & Projects — Complete Guide

> **Organization** aur **Project** Azure DevOps ke administrative structure ki bunyad hain. Sahi governance, project architecture, aur role-based access control (RBAC) set karna ensure karta hai ke enterprise teams ka code mehfooz rahe aur access management aasan bane.

---

## Architecture Hierarchy

Azure DevOps mein administrative structure teen main layers par mushtamil hota hai:

```
[ Microsoft Entra ID (Azure AD) ] ── (Identity & SSO Layer)
                 │
                 ▼
    [ Azure DevOps Organization ]   (Billing, Global Policies, User Licenses)
                 │
                 ├──► [ Project A (E-Commerce) ]  ──► (Boards, Repos, Pipelines, Feeds)
                 └──► [ Project B (Internal HR) ] ──► (Boards, Repos, Pipelines, Feeds)
```

---

## 1. Create Organization (Setup & Region Selection)

Organization aapki company ya enterprise ka markazi workspace hoti hai (URL: `https://dev.azure.com/{YourOrgName}`).

### A. Organization Banane Ka Tareeqa:
1. `https://aex.dev.azure.com` ya `https://dev.azure.com` par Microsoft account ya corporate Entra ID ke zariye sign in karein.
2. **"New organization"** par click karein.
3. Organization ka naam chunein (unique globally hona chahiye).
4. **Data Hosting Region** chunein (e.g., *East US*, *West Europe*, *Southeast Asia*).

> ⚠️ **DevOps Tip (Latency & Compliance):** Region chunte waqt compliance laws (data sovereignty) aur developers/pipelines ki physical location ka khayal rakhein taake artifact downloads aur pipeline latency kam se kam ho.

---

## 2. Create Project (Visibility & Process Templates)

Organization ke andar kaam ko logical boundaries mein divide karne ke liye **Projects** banaye jaate hain.

### A. Project Properties:
* **Project Name & Description:** Team ya product ke mutabiq wazeh naam.
* **Visibility:**
  * **Private (Default):** Sirf invite kiye gaye authenticated users access kar sakte hain (Corporate standard).
  * **Public:** Koi bhi internet user bina login kiye code aur boards dekh sakta hai (Open-source projects ke liye).
* **Version Control:** Hamesha **Git** select karein (Legacy *TFVC* purane setups ke liye hota hai).

### B. Process Templates (Work Tracking Method):
| Process Template | Best For | Hierarchy Structure |
| :--- | :--- | :--- |
| **Basic** | Chhoti teams jo aasan setup chahti hain | Issues, Tasks |
| **Agile** | Standard agile sprints aur user stories | Epics ➔ Features ➔ User Stories ➔ Tasks / Bugs |
| **Scrum** | Formal Scrum ceremonies aur story points | Epics ➔ Features ➔ Product Backlog Items (PBI) ➔ Tasks / Bugs |
| **CMMI** | Formal, audit-heavy, compliance & legal setups | Requirements, Change Requests, Tasks |

---

## 3. User & Group Management

Har user ko alag alag permission dene ke bajaye **Groups** ke zariye permissions manage karna DevOps best practice hai.

### A. Access Levels (Licenses):
* **Stakeholder (Free):** Sirf work items create/edit karne aur boards dekhne ke liye (Product owners, business analysts). Repos ya pipelines ka direct access nahi hota.
* **Basic (Standard):** Full access to Boards, Repos, Pipelines, aur Artifacts (Har organization ko pehle 5 Basic users free milte hain).
* **Basic + Test Plans:** Dedicated QA engineers ke liye jo manual test suites aur exploratory tools chalate hain.

### B. Standard Built-in Security Groups:
```
Project Level:
├── Project Readers (Sirf read-only view)
├── Project Contributors (Developers - commit, push, create PR, run pipelines)
└── Project Administrators (Settings badalna, policies enforce karna)

Organization Level:
└── Project Collection Administrators (Super Admins - naye projects, billing, Entra ID integration)
```

---

## 4. Permissions & Security Best Practices

Enterprise level par code leak aur accidental deletion se bachne ke liye **Least Privilege Access** apply kiya jata hai:

```
[ Entra ID Security Group ] (e.g., "DevOps-Engineers")
            │ (Auto Sync)
            ▼
[ Azure DevOps Group ] (e.g., "Project Contributors")
            │ (Inherits Permissions)
            ▼
[ Specific Resource Access ] (Repos / Pipelines / Service Connections)
```

### Essential Security Rules:
1. **Entra ID (Azure AD) Sync:** Users ko direct personal email se add na karein; Entra ID groups map karein taake employee ke company chhorne par automatically Azure DevOps access revok ho jaye.
2. **Explicit Deny Rules:** Azure DevOps mein `Deny` permission hamesha `Allow` ko override karti hai.
3. **Repository Permissions:**
   * Developers ke liye `Force push (rewrite history)` aur `Bypass policies on pull requests` ko hamesha **Deny** par rakhein.
4. **Service Connection Security:** Production service connections ko kisi bhi aam pipeline ke liye open na chhorein; explicit pipeline authorization aur environment approvals bind karein.

---
**Status:** ✅ Complete