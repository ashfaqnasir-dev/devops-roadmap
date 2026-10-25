# 📋 06.01 Azure Boards — Complete Guide

> **Azure Boards** Microsoft Azure DevOps suite ka project management aur agile tracking tool hai. Yeh software engineering aur DevOps teams ko kaam plan karne, track karne, aur software delivery lifecycle ko visualize karne mein madad deta hai—chahe aap **Scrum**, **Agile**, **Basic**, ya **CMMI** process follow kar rahe hon.

---

## 1. Work Item Hierarchy (Epic, Feature, Story, Task, Bug)

Azure Boards mein har kaam ek **Work Item** ke tor par record hota hai. Agile process mein inki ek wazeh tarteeb (hierarchy) hoti hai:

```
[ Epic ]                    (Company-level broad business goal)
   │
   └──► [ Feature ]         (Specific product capability / deliverable)
           │
           └──► [ User Story ]      (Value delivered to end-user)
                   │
                   ├──► [ Task ]    (Technical unit of work for developer/engineer)
                   └──► [ Bug ]     (Flaw, defect, or unexpected behavior)
```

### Hierarchy Breakdown:

| Work Item | Kaun Banata Hai? | Scope / Timeframe | Practical DevOps Example |
| :--- | :--- | :--- | :--- |
| **Epic** | Product Owner / VP | Mahinon (Quarterly/Yearly) | *"Customer portal ko Cloud-Native architecture par shift karna"* |
| **Feature** | Product Manager / Lead | Chand haftay (Sprints) | *"User authentication ke liye OAuth2 / Social Login support"* |
| **User Story** | Business Analyst / Team | 1 Sprint (1-2 haftay) | *"Bator customer, main Google account se login karna chahta hoon"* |
| **Task** | Developer / Engineer | Chand ghante se 1-2 din | *"Google OAuth client credentials Azure Key Vault mein configure karna"* |
| **Bug** | QA / User / Monitoring | Foran ya sprint backlog | *"Safari browser par login button click hone par redirect loop"* |

> 💡 **Parent-Child Link:** Hamesha chhotay items (Task) ko baray items (Story/Feature) ke sath link rakhein taake dashboards par progress aur traceability 100% visible rahe.

---

## 2. Backlogs (Kaam ki Markazi Fehrist)

**Backlog** un tamam features, ideas, aur tasks ki organized fehrist hoti hai jo team ne mustaqbil mein deliver karne hain.

```
Product Backlog (Unordered ideas & stories)
       │
       ▼ (Refinement & Prioritization)
Top Priority Stories ──► Moved to Next Sprint Backlog
```

### A. Backlog Levels:
1. **Epics Backlog:** High-level strategic roadmap track karne ke liye.
2. **Features Backlog:** Mid-level releases aur deliverables organize karne ke liye.
3. **Stories / Product Backlog:** Ready-to-implement user stories aur bugs ki prioritized list.

### B. Backlog Operations:
* **Drag-and-Drop Prioritization:** Jo story sabse ahem hai usay drag karke top par le aana (top items pehle pick hotay hain).
* **Story Point Estimation:** Story kitni mushkil ya bari hai, use Fibonacci numbers ($1, 2, 3, 5, 8, 13$) mein estimate karna.
* **Forecast Tool:** Team ki historical velocity ke hisab se batata hai ke kaunsa kaam kis sprint tak mukammal hoga.

---

## 3. Sprints (Iterations & Sprint Planning)

**Sprint (Iteration)** ek fixed time-box hota hai (aam tor par 2 haftay) jisme team select shuda user stories ko develop, test, aur ship karti hai.

```
[ Sprint Planning ] ──► [ Daily Standup ] ──► [ Sprint Review & Retro ]
 (Pick stories from      (Track remaining      (Demo to stakeholders
  Product Backlog)            effort)           & process improvement)
```

### Core Features:
* **Iteration Path Setup:** Dates set karna (e.g., `Sprint 24: Nov 01 - Nov 15`).
* **Team Capacity Planning:** Har member ke daily working hours aur chhutiyan (days off) define karna taake pata chale ke team kitna load utha sakti hai.
* **Sprint Burndown Chart:** Real-time chart jo dikhata hai ke din ba din baaqi bacha hua kaam (remaining effort) waqt par khatam ho raha hai ya nahi.

---

## 4. Kanban Boards (Workflow Visualization)

Kanban board continuous delivery aur flow management ke liye visual tool hai jo kaam ki mojooda soorat-e-haal (state) wazeh karta hai.

```
┌──────────────┬──────────────────┬──────────────────┬──────────────┐
│  New / To-Do │   In Progress    │    Code Review   │     Done     │
├──────────────┼──────────────────┼──────────────────┼──────────────┤
│ [ Story 101] │ [ Story 98 ]     │ [ Story 95 ]     │ [ Story 90 ] │
│              │ (WIP Limit: 3) ⚠️│                  │              │
└──────────────┴──────────────────┴──────────────────┴──────────────┘
```

### Key Kanban Concepts:
* **Columns & Swimlanes:** Workflow steps (Columns) aur priority rows (Swimlanes, jaise *Expedite/Hotfix* aur *Standard*).
* **WIP Limits (Work In Progress):** Kisi ek column par aik waqt mein maximum kitne cards ho sakte hain. Isse bottlenecks foran pakde jaate hain.
* **Card Annotations & Styling:** Priority ke hisab se cards ko alag color code dena (e.g., Critical bugs = Red).
* **Definition of Done (DoD):** Har column ke header par criteria set karna ke kab card aglay column mein shift ho sakta hai.

---

## 5. Queries & Dashboards (Metrics & Reporting)

### A. Work Item Queries (WIQL - Work Item Query Language):
Queries ke zariye aap hazaron work items mein se specific filter apply karke data nikal sakte hain:

* **Flat List of Items:**
  * *Example:* *"Tamam bugs jo production mein report hue aur mojooda sprint mein Assigned to Me hain."*
* **Tree of Work Items:** Parents aur children ka direct hierarchical relationship dekhna (Feature -> Story -> Task).
* **One-Hop Direct Links:** Dependencies dhoondna (e.g., *"Kaunse tasks blocked hain?"*).

```text
Filters:
  - Work Item Type = Bug
  - State = Active
  - Severity = 1 - Critical
  - Assigned To = @Me
```

### B. Visual Dashboards:
Azure Boards dashboards par real-time widgets lagaye jaate hain:

* **Burndown & Burnup Widgets:** Sprint aur release progress track karna.
* **Cumulative Flow Diagram (CFD):** Bottlenecks identify karna aur lead/cycle time measure karna.
* **Query Tiles:** Single-number metrics (e.g., `12 Active Bugs`, `4 Blocked Tasks`).
* **Velocity Chart:** Pichle 5 sprints mein team ne average kitne story points deliver kiye.

---
**Status:** ✅ Complete