# 🐙 02.01 Git Basics

Git ek distributed version control system (VCS) hai jo code changes ko track karta hai, multiple developers ke darmian collaboration ko enable karta hai, aur codebase ki complete timeline/history maintain karta hai.

---

### 02.01.01 Repository Initialization & Cloning (`git init`, `git clone`)

Naya project track karne ya remote code ko local machine par lane ke do bunyadi tareeqay:

* **`git init` (Local Setup):**
  * Current folder ko ek naya Git repository banata hai.
  * Yeh project ke root par ek hidden `.git` folder banata hai jahan Git ka tamam internal database aur metadata store hota hai.
  ```bash
  mkdir my-app
  cd my-app
  git init
  ```

* **`git clone` (Remote Setup):**
  * Kisi remote server (GitHub, GitLab, Bitbucket) se existing repository ki poori history aur files apne computer par download karta hai.
  ```bash
  # HTTPS ke zariye
  git clone https://github.com/username/project.git

  # SSH ke zariye (Recommended)
  git clone git@github.com:username/project.git
  ```

---

### 02.01.02 Staging & Committing (`git add`, `git commit`)

Git teen main stages mein kaam karta hai: **Working Directory** $\rightarrow$ **Staging Area** $\rightarrow$ **Repository (Commit History)**.

```
Working Directory   ──── git add ────>   Staging Area (Index)   ──── git commit ────>   Local Repo (.git)
 (Modified files)                        (Prepared changes)                             (Snapshot saved)
```

* **`git add` (Staging Area):**
  * Git ko batata hai ke kaunsi files aglay snapshot (commit) ka hissa banengi.
  ```bash
  git add app.py                 # Single file stage karein
  git add index.html style.css   # Multiple files stage karein
  git add .                      # Current folder ki saari nayi aur modified files stage karein
  ```

* **`git commit` (Saving Snapshot):**
  * Staging area ki files ka ek permanent snapshot create karta hai aur use ek unique SHA-1 hash assign karta hai.
  ```bash
  git commit -m "feat: add user login endpoint"

  # Modified tracked files ko bina 'git add' kiye direct commit karna (-a)
  git commit -am "fix: correct typo in footer"
  ```

---

### 02.01.03 Status & History Inspection (`git status`, `git log`)

Repository ki maujooda halat aur commits ki timeline dekhne ke commands:

* **`git status`:**
  * Batata hai kaunsi files untracked hain, kaunsi modified hain, aur kaunsi staging area mein commit ke liye ready hain.
  ```bash
  git status

  # Short clean output ke liye:
  git status -s
  ```

* **`git log`:**
  * Repository ki commit history (Author, Date, Commit message, Hash) dikhata hai.
  ```bash
  git log

  # Single-line compact view:
  git log --oneline

  # Recent 5 commits graph aur branches ke sath:
  git log --oneline --graph --decorate -n 5
  ```

---

### 02.01.04 Inspecting Changes (`git diff`)

Files ke darmian exact line-by-line farq dekhna (kya add hua `+`, kya delete hua `-`):

* **Working Directory vs Staging Area:**
  * Files modify ki hain lekin abhi `git add` nahi chalaya:
  ```bash
  git diff
  ```

* **Staging Area vs Last Commit:**
  * Files stage kar chuke hain (`git add`), dekhna hai commit mein kya jayega:
  ```bash
  git diff --staged
  # ya
  git diff --cached
  ```

* **Specific File ka Diff:**
  ```bash
  git diff server.js
  ```

* **Do Commits ke darmian Diff:**
  ```bash
  git diff <commit_hash_1> <commit_hash_2>
  ```

---

### 02.01.05 Ignoring Files (`.gitignore`)

Woh plain text file jo Git ko batati hai ke kaunse files aur folders ko kabhi track **nahi** karna.

* **Kyun zaroori hai?**
  * Secrets, credentials, temporary build folders, aur heavy dependencies ko Git repository se bahar rakhne ke liye.
* **Common Patterns in `.gitignore`:**
  ```gitignore
  # Dependencies
  node_modules/
  __pycache__/
  venv/

  # Environment variables aur secrets
  .env
  *.pem
  credentials.json

  # Build outputs
  dist/
  build/
  *.log

  # OS specific files
  .DS_Store
  Thumbs.db
  ```

> **Pro Tip:** Agar koi file pehle se track ho chuki ho aur baad mein `.gitignore` mein daali jaye, to Git use track karta rehta hai. Pehle cache se nikalna padta hai: `git rm --cached <filename>`.

---

### 02.01.06 Configuration (`git config`)

Git ki system, global, aur local settings customize karne ke liye use hota hai.

* **Configuration Levels:**
  1. `--system`: Machine ke saare users ke liye (`/etc/gitconfig`).
  2. `--global`: Current logged-in user ke tamam projects ke liye (`~/.gitconfig`).
  3. `--local`: Sirf specific repository ke liye (`.git/config`).

* **Essential First-Time Setup:**
  ```bash
  # Commits par aane wala author identity set karein
  git config --global user.name "Your Name"
  git config --global user.email "your.email@example.com"

  # Default branch name 'main' set karein
  git config --global init.defaultBranch main

  # Default text editor set karein (e.g. VS Code ya nano)
  git config --global core.editor "nano"
  ```

* **Config Inspect Karna:**
  ```bash
  # Tamam active settings dekhne ke liye:
  git config --list

  # File origin ke sath settings check karna:
  git config --list --show-origin
  ```