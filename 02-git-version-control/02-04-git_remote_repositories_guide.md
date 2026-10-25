# 🌐 02.04 Git Remote Repositories

Git ek distributed version control system hai, jiska matlab hai har developer ke paas complete repository aur history local machine par maujood hoti hai. Team collaboration ke liye code ko centralized hosting platforms (jaise GitHub, GitLab, ya Bitbucket) ke sath sync kiya jata hai jinhe **Remote Repositories** kehte hain.

### 02.04.01 `git remote` (Managing Remote Connections)

Remote repository ke URLs ko manage karne aur aliases define karne ke liye `git remote` command use hoti hai.

* **List remotes:**

  ```
  # Sirf alias names dikhata hai
  git remote
  
  # Names ke sath fetch aur push ke exact URLs show karein
  git remote -v
  
  ```

* **Add a new remote:**

  ```
  # Naya remote connection jorna (by convention default remote ka naam 'origin' hota hai)
  git remote add origin git@github.com:username/my-project.git
  
  ```

* **Inspect remote details:**

  ```
  git remote show origin
  
  ```

* Rename **/ Remove remote:**

  ```
  # Remote ka alias rename karna
  git remote rename origin upstream
  
  # Remote connection delete karna (local repo delete nahi hoti)
  git remote remove origin
  
  ```

* **Change remote URL:**

  ```
  # HTTPS se SSH par switch karne ke liye
  git remote set-url origin git@github.com:username/my-project.git
  
  ```

### 02.04.02 Synchronizing Changes (`git push`, `git pull`)

#### 1. `git push` (Upload to Remote)

Local repository ke commits ko remote branch par publish karne ke liye use hota hai:

* **Initial push with upstream tracking (`-u` / `--set-upstream`):**

  ```
  git push -u origin main
  
  ```

  *(Yeh local `main` ko remote `origin/main` ke sath track kar deta hai. Iske baad aapko sirf `git push` chalana parta hai).*

* **Normal push:**

  ```
  git push
  
  ```

* **Force push (`--force-with-lease`):** Rebase ke baad history rewrite hone par remote update karne ke liye.

  > ⚠️ **Best Practice:** `--force` ke bajaye hamesha `--force-with-lease` use karein taake agar kisi doosre developer ne naya commit push kiya ho to wo overwrite hone se bach sake.

  ```
  git push --force-with-lease origin feature-auth
  
  ```

#### 2. `git pull` (Download & Integrate)

Remote server se naye commits download karke foran current local branch mein merge/rebase karta hai.

* **Formula:** \$$\\text{git pull} = \\text