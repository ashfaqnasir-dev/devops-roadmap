# 🧪 06.04 Azure Test Plans — Complete Guide

> **Azure Test Plans** Azure DevOps ka enterprise quality assurance (QA) aur testing management service hai. Yeh teams ko manual testing, automated test execution, user acceptance testing (UAT), aur exploratory testing ko plan, track, aur analyze karne ke liye ek central platform faraham karta hai.

---

## Hierarchy Overview: Test Plans Architecture

Azure Test Plans mein testing artifacts ek wazeh structure (hierarchy) mein organize hotay hain:

```
[ Test Plan ]                      (e.g., Sprint 24 Release Testing)
      │
      └──► [ Test Suite ]          (Logical group, e.g., Authentication Module)
                │
                └──► [ Test Case ] (Step-by-step instructions & expected result)
```

---

## 1. Test Plans (High-Level Testing Strategy)

**Test Plan** testing activities ka sabse top-level container hota hai. Yeh batata hai ke kisi makhsoos sprint, milestone, ya release candidate ke liye kya kya test kiya jayega.

### Key Characteristics:
* **Scope Binding:** Test plan ko specific **Iteration Path** (Sprint) aur **Area Path** (Team/Service) ke sath assign kiya jata hai.
* **Traceability:** Test plan seedha Azure Boards ke Epics ya Features ke sath link ho sakta hai taake pata chal sake ke business requirements kis hadd tak test ho chuki hain.
* **Test Configurations:** Test plan ke andar mukhtalif configurations define ki ja sakti hain (e.g., *"Run on Chrome + Windows 11"* aur *"Run on Safari + macOS"*).

---

## 2. Test Suites (Test Cases ko Organize Karna)

**Test Suite** ek folder ya category ki tarah hota hai jo similar test cases ko ek jagah jama karta hai. Azure Test Plans mein teen tarah ke test suites hotay hain:

```
                          ┌─────────────────────────┐
                          │       Test Suites       │
                          └────────────┬────────────┘
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
[ Static Suite ]             [ Requirement-Based ]         [ Query-Based Suite ]
• Manual folder              • User Story se link          • Work Item query se
• Test cases drag-and-drop   • Acceptance criteria cover   • Auto-populate hotay hain
```

| Suite Type | Kaise Kaam Karta Hai? | Real-World Use Case |
| :--- | :--- | :--- |
| **Static Suite** | Standard manual folder. Aap khud test cases chunn kar isme add karte hain. | *"Smoke Tests"*, *"Critical Sanity Suite"* |
| **Requirement-Based Suite** | Azure Boards ki kisi **User Story** ya **Requirement** ko point karta hai. Story ke tamam test cases automatic is suite ka hissa ban jaate hain. | Feature testing: *"Verify User Story #542 (Google SSO)"* |
| **Query-Based Suite** | Work item query (WIQL) ke mutabiq dynamic test cases pull karta hai. | Automatically un tamam tests ko jama karna jinka `Priority == 1` aur `State == Ready` ho |

---

## 3. Manual & Exploratory Testing

Bina script likhe software ki usability aur edge cases ko verify karne ke liye Azure Test Plans powerful browser aur desktop tools provide karta hai:

### A. Web-based Test Runner:
Browser ke andar tester ko step-by-step instructions dikhayi jaati hain:
1. **Action:** *"Enter email and click login"*
2. **Expected Result:** *"Dashboard loads within 2 seconds"*
3. Tester har step par `Pass` ya `Fail` mark karta hai.

### B. "Test & Feedback" Browser Extension (Exploratory Testing):
Google Chrome aur Edge ke liye extension jo exploratory testing ko automate aur streamline karti hai:
* **One-Click Bug Logging:** Screen capture (screenshots), screen recording (video), aur console logs automatically capture ho kar naye Azure Boards Bug work item mein attach ho jaate hain.
* **User Actions Recording:** Tester ne kahan kahan click kiya (browser telemetry / action log) khud-ba-khud bug report mein shamil ho jata hai, jisse developers ke liye issue reproduce karna nihayat aasan ho jata hai.

---

## 4. Test Results & Analytics (Reporting)

Testing mukammal hone par metrics aur execution health ko evaluate karna zaroori hota hai:

### A. Outcome Statuses:
* `Passed`: System ne expected result ke mutabiq behave kiya.
* `Failed`: Bug paya gaya (Tester yahan se direct 1-click bug create kar sakta hai jo test case ke sath link rehta hai).
* `Blocked`: Kisi doosre dependency ya server down hone ki wajah se test execute nahi ho saka.
* `Not Applicable (N/A)`: Yeh feature is configuration ke liye relevant nahi tha.

### B. CI/CD Automated Test Results Integration:
Jab Azure Pipelines mein automated tests run hotay hain (e.g., JUnit, NUnit, PyTest), toh pipeline task ke zariye results Azure Test Plans ke dashboards par publish ho jaate hain:

```yaml
# Pipeline YAML snippet to publish automated test results
- task: PublishTestResults@2
  displayName: 'Publish Unit & Integration Test Results'
  inputs:
    testResultsFormat: 'JUnit'
    testResultsFiles: '**/test-results/*.xml'
    failTaskOnFailedTests: true
```

### C. Analytics & Traceability Reports:
* **Pass Rate Trends:** Check karna ke sprints ke sath pass rate barh raha hai ya gir raha hai.
* **Requirements Traceability:** Ek matrix jo dikhata hai ke kon si User Stories mukammal test ho chuki hain aur kon si stories abhi tak untested hain.

---
**Status:** ✅ Complete