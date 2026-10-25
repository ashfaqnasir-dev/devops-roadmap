# ⚡ 02.06 Advanced Git

Advanced Git commands developers ko working directory ki temporary states manage karne, committed history rewrite ya revert karne, software releases tag karne, aur custom workflow automations (hooks) build karne ki taqat deti hain.

### 02.06.01 `git stash` (Temporary Shelf)

Jab aap kisi feature par kaam kar rahe hon aur achanak kisi urgent hotfix ya branch switch karne ki zaroorat pad jaye, lekin aapka current kaam incomplete ho (commit karne ke qabil na ho), to `git stash` working directory ko clean karke un changes ko temporarily save kar leta hai.

* **Save changes to stash:**

  ```
  # Tracked files stash karna
  git stash
  
  # Custom message ke sath stash karna (Recommended)
  git stash push -m "WIP: payment gateway integration"
  
  # Untracked files samet stash karna (-u)
  git stash -u
  
  ```

* **Inspect stashed items:**

  ```
  # Stash list dekhna
  git stash list
  # Output: stash@{0}: WIP: payment gateway integration
  
  # Specific stash ka diff inspect karna
  git stash show -p stash@{0}
  
  ```

* **Restore and clean:**

  ```
  # Latest stash apply karna aur use list se delete karna
  git stash pop
  
  # Stash apply karna lekin stash list mein safe rakhna
  git stash apply stash@{0}
  
  # Specific stash drop/delete karna
  git stash drop stash@{0}
  
  # Tamam stashes clean/wipe karna
  git stash clear
  
  ```

### 02.06.02 `git reset` (Soft, Mixed, Hard)

`git reset` current branch ke `HEAD` pointer ko kisi pichle commit par le jata hai. Iske teen main modes hotay hain jo working tree aur staging area ke behavior ko control karte hain:

```
Commit History:   (A) ─── (B) ─── (C) [HEAD]
                                   │
                    git reset <mode> (B)

```

| Mode | `HEAD` Pointer | Staging Area (Index) | Working Directory | Typical Use Case | 
| ----- | ----- | ----- | ----- | ----- | 
| **`--soft`** | Moves to target commit | **Preserved** (Unchanged) | **Preserved** (Unchanged) | Aakhri commit message ya setup change karna; changes staged rehti hain. | 
| **`--mixed`** *(Default)* | Moves to target commit | **Reset** (Unstaged) | **Preserved** (Unchanged) | Changes ko disk par safe rakh kar staging area clear karna. | 
| **`--hard`** | Moves to target commit | **Reset** (Discarded) | **Reset** (Discarded) | ⚠️ Tamam uncommitted aur committed changes ko permanently destroy karna. | 

* **Commands:**

  ```
  # Soft reset: Aakhri commit undo karein, changes staging index mein bachi rahengi
  git reset --soft HEAD~1
  
  # Mixed reset: Aakhri commit undo karein, changes unstaged file format mein bachi rahengi
  git reset HEAD~1
  
  # Hard reset: Aakhri commit aur files ke tamam modifications wipe-out kar dein
  git reset --hard HEAD~1
  
  # Kisi specific commit hash par hard reset karna
  git reset --hard 3a1f4c2
  
  ```

> ⚠️ **Golden Rule:** Public/shared branches par `git reset` run karne se bachein kyunki yeh branch history rewrite kar deta hai.

### 02.06.03 `git revert` (Safe Undoing)

`git revert` kisi purane commit ke asar ko khatam (inverse/undo) karne ke liye ek **naya commit** create karta hai.

* **Why use it over reset?**

  * History rewrite **nahi** hoti.

  * Public/shared branches (jaise `main` ya `staging`) par production bugs ko rollback karne ka standard safe tareeqa hai.

* **Commands:**

  ```
  # Specific commit ko safely undo karna (naya inverse commit banega)
  git revert 8a4b2c1
  
  # Bina fauran commit prompt ke revert karna (changes staging area mein aati hain)
  git revert -n 8a4b2c1
  
  # Range of commits revert karna
  git revert HEAD~2..HEAD
  
  ```

### 02.06.04 `git tag` (Milestones & Releases)

Git tags repository ki timeline mein specific points ko freeze ya mark karne ke liye use hotay hain (aam tor par Semantic Versioning jaise `v1.0.0`, `v2.4.1` releases ke liye).

* **1. Lightweight Tag:**
  Sirf ek specific commit ka pointer hota hai (bookmark ki tarah).

  ```
  git tag v1.0.0-rc1
  
  ```

* **2. Annotated Tag (Recommended for Releases):**
  Full object hota hai jisme tagger ka naam, email, date, GPG signature, aur release note message shamil hota hai.

  ```
  git tag -a v1.0.0 -m "Release version 1.0.0 for production"
  
  ```

* **Inspect & Push Tags:**

  ```
  # Tamam tags list karein
  git tag -l
  
  # Tag metadata aur commit details inspect karein
  git show v1.0.0
  
  # Specific tag remote par push karein (Default 'git push' tags upload nahi karta)
  git push origin v1.0.0
  
  # Tamam local tags ek sath push karein
  git push origin --tags
  
  # Tag delete karna
  git tag -d v1.0.0                     # Local delete
  git push origin --delete v1.0.0       # Remote delete
  
  ```

### 02.06.05 Git Hooks

Git Hooks custom shell scripts hoti hain jo Git repository ke specific lifecycles (jaise commit hone se pehle, push hone se pehle, ya checkout par) automatically trigger hoti hain.

* **Directory Location:**
  Repository ke andar `.git/hooks/` folder mein hoti hain (e.g., `pre-commit.sample`).

* **Common Hook Types:**

  * **Client-side Hooks:**

    * `pre-commit`: Code linting, formatting (`prettier`, `black`), unit test checks. Commit reject ho jayega agar script non-zero code ke sath exit ho.

    * `commit-msg`: Conventional commit format enforce karna (e.g., `feat:`, `fix:`).

    * `pre-push`: Push hone se pehle full test suite run karna ya credentials leak check karna.

  * **Server-side Hooks:**

    * `pre-receive` / `post-receive`: CI builds trigger karna ya protected branch rules server side enforce karna.

* **Example: Simple `pre-commit` Hook:**
  File create karein `.git/hooks/pre-commit`:

  ```
  #!/bin/sh
  echo "🔍 Running linter checks before committing..."
  
  # Example lint command
  npm run lint
  
  if [ $? -ne 0 ]; then
    echo "❌ Lint check failed! Commit aborted. Please fix errors first."
    exit 1
  fi
  
  echo "✅ Linter passed!"
  exit 0
  
  ```

* **Executable Permissions:**
  Hook script ko executable banana laazmi hota hai:

  ```
  chmod +x .git/hooks/pre-commit
  
  ```

* **Bypass Hook (Emergency only):**

  ```
  git commit -m "Emergency fix" --no-verify
  
  ```

> **Modern Automation Tool:** Team environments mein Git hooks ko repository ke code ke sath share aur standardize karne ke liye **Husky** (Node.js) ya **pre-commit** (Python) frameworks use kiye jaate hain.