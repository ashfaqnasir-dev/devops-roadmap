# 🚀 05.02 CD Fundamentals

Continuous Delivery (CD) aur Continuous Deployment (CD) modern DevOps practices hain jo Continuous Integration (CI) ke baad shuru hoti hain. Inka maqsad tested software changes ko automatically aur reliably target environments tak deliver karna hota hai.

---

### 05.02.01 Continuous Delivery vs Continuous Deployment

Dono concepts automate deployment par focus karte hain, lekin aakhri step (production release) mein ek ahem farq hota hai:

| Feature | Continuous Delivery | Continuous Deployment |
| :--- | :--- | :--- |
| **Production Release** | **Manual Approval Gate** (One-click release) | **Fully Automated** (Zero human intervention) |
| **Release Readiness** | Har green build deploy hone ke qabil (deployable) hoti hai, magar business decision ke mutabiq release hoti hai. | Har green build direct production par live chali jaati hai bina kisi rukawat ke. |
| **Best For** | Regulated industries (Banking, Healthcare), enterprise systems, ya strict release window teams. | SaaS apps, mature microservices teams jahan automated testing suite 100% reliable ho. |
| **Human Role** | Stakeholder/Tech lead button daba kar final rollout confirm karta hai. | Engineers sirf code merge karte hain; release process hands-off hota hai. |

```
CI:           [ Code ] ──> [ Build ] ──> [ Test ]
                                            │
Continuous Delivery:                        ▼
              [ Staging Deploy ] ──> [ Manual Approval 🛑 ] ──> [ Production Deploy ]
                                            │
Continuous Deployment:                      ▼
              [ Staging Deploy ] ──> [ Automated Checks ] ──> [ Production Deploy 🚀 ]
```

---

### 05.02.02 Release Pipeline

Release pipeline ek automated sequence of actions hai jo validated code artifact ko end-user ke access tak le kar jaata hai:

1. **Artifact Fetching:** CI stage ka create kiya gaya immutable artifact (Docker image tag, compiled `.jar`, tarball) retrieve hota hai.
2. **Environment Configuration:** Specific environment ke secrets aur variables inject kiye jaate hain.
3. **Database Migration:** Agar schema update ho, to app deploy hone se pehle backward-compatible migration run hoti hai.
4. **Service Rollout:** Deployment strategy (Rolling update, Blue/Green, Canary) ke tahat naye containers/pods replace hote hain.
5. **Smoke Testing & Verification:** Basic health endpoints (`/healthz`) hit karke status check hota hai.
6. **Rollback Trigger (if needed):** Agar verification fail ho, to automatically purani stable version par revert kar diya jaata hai.

---

### 05.02.03 Environment Stages (Dev, Staging, Prod)

Code ko direct production par bhejane ke bajaye progressively promote kiya jata hai:

* **1. Development (`dev`):**
  * **Audience:** Developers aur internal automated testing.
  * **Maqsad:** Rapid integration test karna, features ka initial validation.
  * **Characteristics:** High tolerance for failure, temporary resources, mock APIs allowed.

* **2. Staging / UAT (`staging`):**
  * **Audience:** QA engineers, product managers, automated E2E suites.
  * **Maqsad:** Production ka exact replica hona chahiye (same configurations, similar data volume, identical networking).
  * **Characteristics:** Pre-release verification, performance load tests, final regression run.

* **3. Production (`prod`):**
  * **Audience:** Real end-users aur customers.
  * **Maqsad:** High availability, security, aur stable performance.
  * **Characteristics:** Zero-tolerance for unhandled downtime, strict RBAC, automated monitoring aur alerting active.

---

### 05.02.04 Approval Gates

Approval gates quality checkpoints hotay hain jo pipeline ko automatic progress karne se rokte hain jab tak required conditions poori na hon.

* **Types of Gates:**
  * **Manual Gates:** Specific reviewers ya team leads ka sign-off (e.g., GitHub Environments reviewers, GitLab manual actions).
  * **Automated Quality Gates:** Criteria-based triggers (e.g., SonarQube quality gate pass hona, 0 high vulnerabilities in Trivy scan).
  * **Time-based Gates:** Business hours ke mutabiq release windows enforce karna.

#### GitHub Actions Approval Gate Example:

```yaml
jobs:
  deploy-production:
    runs-on: ubuntu-latest
    environment:
      name: production # Repository settings mein is environment par required reviewers set hote hain
      url: https://myapp.example.com
    steps:
      - name: Deploy to Live Server
        run: |
          echo "Approved! Deploying version ${{ github.sha }} to production..."
          ./deploy.sh prod
```