# 🔀 02.03 Git Merging & Rebasing

Git mein alag alag branches par kaam mukammal hone ke baad un changes ko ek central timeline mein integrate karne ke do main tareeqay hotay hain: **Merge** aur **Rebase**. Iske ilawa specific isolated commits ko pull karne ke liye **Cherry-pick** use hota hai.

---

### 02.03.01 `git merge`

Merge do branches ke histories ko aapas mein jorta hai. Jis branch mein changes lani hon, pehle us par switch kiya jata hai aur phir doosri branch ko merge kiya jata hai.

#### 1. Fast-Forward Merge
Agar target branch (`main`) par koi naya commit na hua ho aur source branch (`feature`) seedhi line mein aage badhi ho, to Git pointer ko bina naya commit banaye foran aage shift kar deta hai:

```bash
git switch main
git merge feature-login
```

#### 2. Three-Way Merge (True Merge)
Agar dono branches par independent commits ho chuke hon, to Git dono branches ke latest commits aur unke common ancestor commit ko milakar ek naya **Merge Commit** generate karta hai:

```bash
git switch main
git merge feature-payment -m "Merge branch 'feature-payment' into main"
```

* **No-FF Flag (`--no-ff`):** Fast-forward conditions mein bhi explicit merge commit generate karne ke liye:
  ```bash
  git merge --no-ff feature-login
  ```

---

### 02.03.02 Merge Conflicts

Jab do alag branches par same file ki identical line(s) ko edit kiya jaye ya ek branch par file delete ho aur doosri par modify, to Git automatically faisla nahi kar pata aur conflict raise karta hai.

#### Conflict Resolution Workflow:

1. **Status check karein:**
   ```bash
   git status
   # 'both modified: app.py' show hoga
   ```

2. **File inspect karein:** File ke andar conflict markers nazar aayenge:
   ```text
   <<<<<<< HEAD (Current branch ki changes)
   port = 8080
   =======
   port = 9000
   >>>>>>> feature-branch (Incoming changes)
   ```

3. **Manually edit karein:** Markers (`<<<<<<<`, `=======`, `>>>>>>>`) ko delete karke desired final code rakhein.

4. **Mark as resolved & commit:**
   ```bash
   git add app.py
   git commit -m "Fix merge conflict on port configuration"
   ```

* **Abort Merge:** Agar merge cancel karke previous clean state par wapis jana ho:
  ```bash
  git merge --abort
  ```

---

### 02.03.03 `git rebase`

Rebase aapki feature branch ke saare commits ko utha kar target branch ke latest tip par "replay" kar deta hai. Isse timeline bilkul seedhi (linear) rehti hai aur extra merge commits nahi bante.

```bash
# Feature branch par rehte hue:
git switch feature-search
git rebase main
```

#### Merge vs Rebase Muazna:

| Feature | `git merge` | `git rebase` |
| :--- | :--- | :--- |
| **Commit History** | Non-linear, complex tree, merge commits bante hain | Clean, linear timeline |
| **Original Timestamps** | Exact timeline preserve rehti hai | Commits naye hashes ke sath recreate hote hain |
| **Golden Rule** | Kahin bhi use ho sakta hai | **Shared/Public branch par rebase kabhi na karein!** |

* **Rebase Conflict Workflow:**
  Agar rebase ke dauran conflict aaye:
  ```bash
  # Conflict resolve karein aur add karein
  git add <file>
  git rebase --continue

  # Ya rebase cancel karein
  git rebase --abort
  ```

---

### 02.03.04 Interactive Rebase (`git rebase -i`)

Git history ko clean, reorder, squash, ya commit messages modify karne ka sabse powerful tool hai.

* **Command:** Pichle 3 commits modify karne ke liye:
  ```bash
  git rebase -i HEAD~3
  ```

* **Editor Menu Options:**
  Editor open hoga jisme har commit ke aage commands hongi:
  * `pick`: Commit ko as-it-is include karein.
  * `reword`: Commit message edit karein.
  * `edit`: Commit ke content ko modify/amend karne ke liye pause karein.
  * `squash`: Is commit ko pichle commit ke andar merge (combine) kar dein aur message edit karein.
  * `fixup`: Like squash, lekin is commit ka message discard kar de.
  * `drop`: Commit ko history se permanently nikal dein.

* **Squashing Example:**
  ```text
  pick a1b2c3d Add login form layout
  squash e4f5g6h Fix styling bug on login form
  squash j7k8l9m Fix typo in button text
  ```
  Is se yeh 3 chotay commits milkar 1 meaningful clean commit ban jaayenge.

---

### 02.03.05 `git cherry-pick`

Poori branch ko merge ya rebase karne ke bajaye kisi doosri branch se **sirf ek specific commit** ko utha kar current branch par apply karna.

* **Use Case:** Hotfix kisi experimental branch par apply ho gaya tha aur use foran production branch mein lana ho bina baaqi unready features ke.

#### Commands:

```bash
# 1. Target branch par jayein jahan commit chahiye
git switch main

# 2. Specific commit hash cherry-pick karein
git cherry-pick 7f3a8b2

# Multiple commits cherry-pick karna:
git cherry-pick 7f3a8b2 c4d5e6f

# Range of commits cherry-pick karna:
git cherry-pick A..B
```

* **Conflict Resolution in Cherry-pick:**
  ```bash
  # Conflict theek karke continue karein
  git add <file>
  git cherry-pick --continue

  # Abort karein
  git cherry-pick --abort
  ```