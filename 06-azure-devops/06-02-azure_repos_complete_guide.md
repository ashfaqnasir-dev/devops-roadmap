# 📦 06.02 Azure Repos — Complete Guide

> **Azure Repos** Azure DevOps ka built-in version control system hai jo unlimited private **Git repositories** (aur legacy TFVC - Team Foundation Version Control) provide karta hai. Yeh modern engineering teams ko enterprise-grade security, code reviews, aur automated CI/CD pipeline triggers ke sath collaborative code management ki sahulat deta hai.

---

## 1. Git Repos in Azure DevOps

Azure Repos standard Git protocol par kaam karta hai, iska matlab hai ke aap standard Git CLI (`git clone`, `git push`, `git status`) ya kisi bhi IDE (VS Code, IntelliJ) ke sath bina kisi nayi technology ko seekhe connect ho sakte hain.

### A. Authentication Options:
1. **Personal Access Tokens (PAT):** 
   * Aam CLI actions aur scripts ke liye temporary password token generate kiya jata hai.
   * Expiry date aur fine-grained permissions (e.g., *Code: Read & Write*) ke sath set hota hai.
2. **SSH Public Key:** 
   * Machine-level secure authentication (`~/.ssh/id_rsa.pub` ko Azure DevOps user settings mein paste kiya jata hai).
3. **Git Credential Manager (GCM):** 
   * Recommended authentication jo browser ke zariye Microsoft Entra ID (Azure AD) SSO login karwati hai.

### B. Standard Workflow:
```bash
# Repo clone karna
git clone https://dev.azure.com/{YourOrg}/{YourProject}/_git/{RepoName}

# Feature branch banana
git checkout -b feature/user-auth

# Kaam karke commit karna
git add .
git commit -m "feat: setup auth middleware #1042"

# Remote Azure Repo par push karna
git push -u origin feature/user-auth
```

> 💡 **Work Item Linking via Commit Message:** Agar aap commit message mein `#WorkItemID` (e.g., `#1042`) likhenge, toh commit Azure Boards ke us specific Task/Story ke sath automatically link ho jayega.

---

## 2. Branch Policies (Quality & Security Guardrails)

Enterprise setups mein developers ko `main` ya `production` branch par direct `git push` karne ki ijazat nahi hoti. **Branch Policies** ensure karti hain ke code sirf automated validation aur manual review pass karne ke baad merge ho sake.

```
Developer Push ──► [ Feature Branch ] ──► [ Pull Request ]
                                                 │
                             ┌───────────────────┴───────────────────┐
                             ▼                                       ▼
                  [ Automated Policy ]                      [ Human Review ]
                  • Pipeline Build Passed ✅                • Min 2 Reviewers Approved ✅
                  • Work Item Linked ✅                     • Comments Resolved ✅
                             │                                       │
                             └───────────────────┬───────────────────┘
                                                 ▼
                                        Merged to [ main ] 🚀
```

### Key Branch Policies jo Setup ki jaati hain:

| Policy Setting | Maqsad | Kyun zaroori hai? |
| :--- | :--- | :--- |
| **Require a minimum number of reviewers** | Kam az kam 1 ya 2 team members PR approve karein | Human code verification aur collective code ownership |
| **Check for linked work items** | PR kisi Task/Bug ke sath link hona lazmi ho | 100% traceability (pata ho ke yeh code kiske kehne par likha gaya) |
| **Check for comment resolution** | Reviewer ke open comments resolve hona zaroori hon | Koi feedback ya security question unaddressed na chhoota ho |
| **Limit merge types** | Sirf *Squash Merge* ya *Semi-linear merge* allow karna | Clean, linear aur readable Git commit history |
| **Build Validation (CI Trigger)** | PR raise hote hi automated pipeline run ho | Broken code ya failing tests branch mein merge na hon |

---

## 3. Pull Requests (PRs)

Pull Request (PR) ek proposal hota hai jahan developer kehta hai: *"Main ne `feature/user-auth` par kaam mukammal kar liya hai, baraye meharbani ise review karein aur `main` branch mein shamil (merge) karein."*

### A. Pull Request Lifecycle:
```
1. Create PR ──► 2. Automated Build Runs ──► 3. Peer Review ──► 4. Approve ──► 5. Complete (Merge)
```

### B. Merge Types in Azure Repos:
1. **Merge (No fast-forward):** Tamam commits ke sath ek naya merge commit banata hai.
2. **Squash commit:** Feature branch ke tamam chhotay chhotay commits ko ek single saaf commit mein jama kar deta hai (Best practice for clean history).
3. **Rebase and fast-forward:** Branch ko base branch ke top par place karta hai bina merge commit ke.
4. **Semi-linear merge:** Rebase karta hai taake fast-forward ho, lekin ek explicit merge commit bhi preserve karta hai.

---

## 4. Code Review Best Practices

Azure Repos mein code review interface powerful collaboration features provide karta hai:

### A. Reviewer Vote Status:
* **Approved (Green Check):** Code theek hai, merge karne ki ijazat hai.
* **Approved with suggestions:** Chhote non-critical suggestions diye gaye hain, par merge blocker nahi hain.
* **Waiting for author:** Developer se clarification ya modifications mangi gayi hain.
* **Rejected:** Code production-ready nahi hai ya architectural flaw hai.

### B. Line-by-Line Discussion:
Reviewers code diff screen par kisi bhi specific line par click karke inline comments chhor sakte hain:
* `Active`: Abhi baat cheet chal rahi hai.
* `Resolved`: Developer ne issue theek kar diya hai.
* `Won't Fix / Closed`: Dono team members ne agree kiya ke yeh change zaroori nahi hai.

---

## 5. Forking vs Branching

Azure Repos dono branching aur forking strategies support karta hai. Sahi approach choose karna organizational model par depend karta hai:

```
[ Internal Team / Feature Branching ]
Repository ──► branch: feature/login ──► PR ──► branch: main

[ Open Source / Cross-Org / Forking ]
Source Repo ──(Fork)──► Copy in Developer Space ──► PR Across Repos ──► Original Repo
```

| Factor | Feature Branching | Forking (Cross-Repository) |
| :--- | :--- | :--- |
| **Location** | Same repository ke andar alag branches | Poori repository ki ek alag isolated clone copy |
| **Access Control** | Developers ko main repository par write access chahiye hota hai | Developers ko sirf read access chahiye; write access unke apne fork par hota hai |
| **Best For** | Internal development teams, high-trust agile teams | Vendor/contractor teams, open-source projects, strict isolation setups |
| **PR Workflow** | Branch-to-branch (`feature` to `main`) | Cross-repo (`my-fork/feature` to `upstream/main`) |

---
**Status:** ✅ Complete