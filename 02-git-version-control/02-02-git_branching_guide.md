# 🌿 02.02 Git Branching

Git mein **Branching** ek bohot lightweight mechanism hai jo developers ko main production line se alag reh kar naye features banane, bugs fix karne, ya experiments karne ki sahulat deta hai. Technically, Git mein branch kisi heavy folder copy ki tarah nahi hoti, balki ek commit par laga hua moveable pointer hoti hai (41 bytes ki file).

---

### 02.02.01 `git branch` (Overview & Pointer Model)

Jab aap Git repository banate hain, to default branch ka naam aam tor par `main` (ya `master`) hota hai.

* **Kaise kaam karta hai:**
  * Har dafa jab aap commit karte hain, to active branch ka pointer aage move ho jata hai.
  * `HEAD` ek special pointer hai jo yeh track karta hai ke aap is waqt kis branch ya commit par kaam kar rahe hain (`HEAD -> main`).

---

### 02.02.02 Switch Branches (`git checkout` vs `git switch`)

Pehle Git mein branch badalne ke liye `git checkout` use hota tha, lekin `checkout` files restore karne ke liye bhi use hota tha jisse confusion paida hoti thi. Git v2.23+ mein branches switch karne ke liye specialized command `git switch` introduce ki gayi.

#### 1. Modern Syntax (`git switch` - Recommended)
```bash
# Maujooda branch par switch karein
git switch feature-login

# Switch karke wapis pichli branch par jana
git switch -
```

#### 2. Classic Syntax (`git checkout`)
```bash
# Branch par move karein
git checkout feature-login

# Previous branch par revert karein
git checkout -
```

---

### 02.02.03 Create & Delete Branches

#### 1. Create a Branch
```bash
# Sirf branch banana (current branch par hi rehte hue)
git branch feature-payment

# Nayi branch bana kar foran us par switch karna (Modern)
git switch -c feature-payment

# Nayi branch bana kar switch karna (Classic)
git checkout -b feature-payment
```

#### 2. Delete a Branch
* **Safe Delete (`-d`):** Sirf tab delete karega jab changes main branch mein merge ho chuki hon:
  ```bash
  git branch -d feature-payment
  ```
* **Force Delete (`-D`):** Agar branch unmerged ho aur aapko uski changes zaya karni hon:
  ```bash
  git branch -D feature-payment
  ```
* **Remote Branch Delete Karna:**
  ```bash
  git push origin --delete feature-payment
  ```

---

### 02.02.04 Rename Branches

Agar branch ka naam typo ho jaye ya naming conventions ke mutabiq modify karna ho:

#### 1. Local Branch Rename:
* **Current active branch ko rename karna:**
  ```bash
  git branch -m feature-user-auth
  ```
* **Kisi doosri branch ko rename karna (bina us par switch kiye):**
  ```bash
  git branch -m old-name new-name
  ```

#### 2. Remote Branch Rename:
Remote par direct rename command nahi hoti; iska 3-step standard workflow hota hai:
```bash
# Step 1: Local branch rename karein
git branch -m old-name new-name

# Step 2: Nayi branch remote par push karein aur tracking set karein
git push origin -u new-name

# Step 3: Purani branch remote se delete karein
git push origin --delete old-name
```

---

### 02.02.05 List Branches (Local & Remote)

System aur remote servers par maujood branches ko inspect karne ke commands:

| Command | Description |
| :--- | :--- |
| `git branch` | Sirf local branches list karega. Active branch ke sath `*` aur green color show hoga. |
| `git branch -v` | Local branches ke sath unka latest commit message aur hash bhi dikhaye. |
| `git branch -r` | Sirf remote-tracking branches dikhaye (`origin/main`, `origin/dev`). |
| `git branch -a` | **Local aur Remote dono** branches ek sath show kare. |
| `git branch --merged` | Woh branches jo current branch mein merge ho chuki hain (delete karne ke liye safe candidates). |
| `git branch --no-merged` | Woh branches jinke andar aisi changes hain jo abhi merge nahi huin. |

#### Example Output (`git branch -a`):
```text
* main
  feature-auth
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
  remotes/origin/feature-dashboard
```