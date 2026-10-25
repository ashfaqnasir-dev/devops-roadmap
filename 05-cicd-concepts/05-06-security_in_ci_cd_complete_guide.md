# 🔒 05.06 Security in CI/CD — Complete Guide

> Purane model mein security checks software release hone ke aakhri lamhaat mein kiye jaate the. Agar koi security flaw samne aata toh poori release delay ho jati thi. **DevSecOps** aur CI/CD security ka bunyadi usool **"Shift-Left Security"** hai—yani security checks ko pipeline ke bilkul shuruati marahil (code commit aur build) par le aana taake vulnerabilities fauran pakdi ja sakein.

---

## "Shift-Left" Mental Model

```
Traditional:  [ Code ] ──► [ Build ] ──► [ Deploy ] ──► [ Security Audit ⚠️ ] (Late & Costly)

Shift-Left:   [ Code ] ──► [ Build ] ──► [ Deploy ] ──► [ Production ]
                 │             │
          ┌──────┴──────┐      │
          ▼             ▼      ▼
        Secrets       SAST   DAST & Runtime
       Scanning    Dependencies
```

---

## 1. SAST (Static Application Security Testing)

SAST ko **"White-Box Testing"** bhi kaha jata hai. Yeh source code ko bina run ya execute kiye line-by-line scan karta hai taake insecure coding patterns, logic bugs, aur vulnerabilities dhoond sake.

### A. Focus Areas:
* **SQL Injections:** Unsanitized database input queries.
* **Cross-Site Scripting (XSS):** Malicious JavaScript code execution vectors.
* **Buffer Overflows & Memory Leaks:** C/C++ memory security flaws.
* **Insecure Cryptography:** Kamzor hashing algorithms (e.g., MD5 ya SHA1) ka istemal.

### B. Pros & Cons:
* **Fawaid:** Early stage par issue pakad leta hai; specific line number aur file point out karta hai.
* **Nuqsaan:** False Positives (ghalat alerts) zyada aate hain; runtime ya environment-specific bugs nahi dhoond sakta.

### C. Popular Tools:
* **SonarQube:** Code quality aur security bugs dono ke liye industry standard.
* **Semgrep:** Fast, lightweight, aur custom YAML rules likhne ke liye behtareen.
* **CodeQL (GitHub):** Semantic code analysis engine.

### D. Pipeline Example (Semgrep in GitHub Actions):
```yaml
jobs:
  sast-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Semgrep SAST
        run: |
          docker run --rm -v "${{ github.workspace }}:/src" returntocorp/semgrep semgrep --config=auto
```

---

## 2. DAST (Dynamic Application Security Testing)

DAST ko **"Black-Box Testing"** kaha jata hai. Yeh application ke source code ko nahi dekhta, balki chalte hue (running) application environment par bahir se attacks simulate karke check karta hai ke system attack ko kaise handle karta hai.

### A. Focus Areas:
* Authentication aur Session hijacking bypasses.
* Misconfigured HTTP response security headers.
* API rate limiting aur server denial flaws.
* Server-Side Request Forgery (SSRF).

### B. Comparison: SAST vs DAST

| Feature | SAST (Static) | DAST (Dynamic) |
| :--- | :--- | :--- |
| **Testing Approach** | White-Box (Source code dekhta hai) | Black-Box (Running app par attack karta hai) |
| **Execution State** | Code run karne ki zaroorat **nahi** hoti | Running application (URL/Endpoint) **laazmi** hai |
| **Pipeline Stage** | Early CI (Commit / PR time) | Staging / Pre-prod environment |
| **Fix Precision** | Exact code line aur file batata hai | Endpoint URL aur request/response payload batata hai |

### C. Popular Tools:
* **OWASP ZAP (Zed Attack Proxy):** Sabse mashhoor open-source DAST scanner.
* **Burp Suite Enterprise:** Heavy corporate compliance scanner.

---

## 3. Dependency Scanning (Software Composition Analysis — SCA)

Modern applications mein $70\%-90\%$ code open-source libraries aur packages (e.g., npm, pip, maven) ka hota hai. **SCA** tool aapke `package-lock.json`, `requirements.txt`, ya `go.sum` ko scan karke CVE (Common Vulnerabilities and Exposures) database ke sath match karta hai.

### A. Typical Risks:
* Purane packages jisme publicly known zero-day exploits hon (jaise mashhoor Log4Shell issue).
* Direct aur Transitive dependencies (woh libraries jo aapki libraries use karti hain).

### B. Popular Tools:
* **Trivy (Aqua Security):** Fast scanner for containers, filesystems, and Git repos.
* **Snyk:** Developer-focused scanning with automated fix PRs.
* **GitHub Dependabot:** Repository mein automated version bump PRs open karta hai.

### C. Pipeline Example (Trivy Filesystem Scan):
```yaml
jobs:
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'
          exit-code: '1' # Fail pipeline if Critical/High found
```

---

## 4. Secret Scanning (Leak Prevention)

Developers se aksar ghalti se API keys, AWS tokens, database passwords, ya SSH private keys commit ho kar GitHub/GitLab par chali jaati hain. **Secret Scanning** regex aur entropy algorithms ke zariye credentials ko repository mein aane se rokta hai.

### A. Pre-commit vs In-Pipeline:
1. **Pre-commit Hooks (Shift-Left Maximum):** Developer ke laptop se code push hone se pehle hi block kar dena (e.g., `git-secrets`, `trufflehog`).
2. **CI Pipeline Scanning:** Agar developer hook bypass kare toh PR build foran fail ho jaye.

### B. Popular Tools:
* **TruffleHog:** Git history aur branches deep scan karta hai taake commit ho chuke secrets bhi pakde ja sakein.
* **Gitleaks:** Lightweight aur fast secret scanner jo CI pipelines ke liye ideal hai.
* **GitHub Secret Scanning:** Cloud-level automated alerts aur partner token revocation.

### C. Pipeline Example (Gitleaks in CI):
```yaml
jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Deep history scan karne ke liye zaroori hai
      - name: Run Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 💡 Summary Checklist for Secure Pipelines

```
✅ Step 1: Pre-commit hook chalayein (Gitleaks / Husky)
✅ Step 2: PR level par SAST aur Dependency scan block lagayein (Trivy / SonarQube)
✅ Step 3: Container image build hone par CVE scan karein
✅ Step 4: Staging deploy hone par DAST automated scan run karein (OWASP ZAP)
✅ Step 5: Agar Critical vulnerability aye toh pipeline non-zero exit code (exit 1) par break ho
```

---
**Status:** ✅ Complete