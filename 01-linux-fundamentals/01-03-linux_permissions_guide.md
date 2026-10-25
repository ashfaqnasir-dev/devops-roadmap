# 🔐 01.03 Linux Permissions & Ownership

Linux ek multi-user operating system hai jahan security aur file isolation permissions ke zariye enforce hoti hai. Har file aur directory ke sath yeh define hota hai ke kaunsa user ya group use read, write, ya execute kar sakta hai.

---

### 01.03.01 Permission Types (`r`, `w`, `x`)

Jab aap terminal par `ls -l` chalate hain, to permissions 10 characters ki string mein nazar aati hain:

```
-rwxr-xr-- 1 ubuntu developers 4096 Oct 24 10:00 deploy.sh
```

* **Pehla character (File Type):**
  * `-` : Regular file
  * `d` : Directory
  * `l` : Symbolic link

* **Agale 9 characters 3 sets mein divide hote hain:**
  1. **User / Owner (`u`):** File banane wale ki permissions (pehla set: `rwx`)
  2. **Group (`g`):** Assigned group ke members ki permissions (doosra set: `r-x`)
  3. **Others (`o`):** Baaqi tamam users ki permissions (teesra set: `r--`)

#### Permissions ka Matlab: File vs Directory

| Permission | Files ke liye | Directories ke liye |
| :--- | :--- | :--- |
| **`r` (Read)** | File ka content view/padhna (`cat`, `less`) | Folder ke andar files ki list dekhna (`ls`) |
| **`w` (Write)** | File modify ya edit karna | Folder ke andar nayi files banana ya delete karna |
| **`x` (Execute)** | File ko as a program/script run karna (`./script.sh`) | Folder ke andar enter hona (`cd`) aur files access karna |

---

### 01.03.02 `chmod` (Change Mode)

Files ya directories ki permissions tabdeel karne ke do tareeqay hotay hain:

#### 1. Numeric (Octal) Notation

Har permission ka ek specific number weight hota hai:
* `r` (Read) = **4**
* `w` (Write) = **2**
* `x` (Execute) = **1**
* `-` (No Permission) = **0**

Values ko add kar ke final permission digit banta hai ($4+2+1 = 7$):
* `7` ($4+2+1$) : Full access (`rwx`)
* `6` ($4+2$) : Read + Write (`rw-`)
* `5` ($4+1$) : Read + Execute (`r-x`)
* `4` : Read-only (`r--`)
* `0` : No permissions (`---`)

**Numeric Examples:**
```bash
chmod 755 script.sh   # Owner: rwx (7), Group: r-x (5), Others: r-x (5)
chmod 644 config.txt  # Owner: rw- (6), Group: r-- (4), Others: r-- (4)
chmod 700 secret.key  # Sirf Owner ke paas full access, baaqi sab zero
chmod -R 755 /var/www # Recursive flag (-R) poore folder tree par apply karega
```

#### 2. Symbolic Notation

Symbolic mode mein targets (`u`, `g`, `o`, `a` for all) aur operators (`+`, `-`, `=`) use kiye jate hain:

```bash
chmod +x deploy.sh        # Sabhi users ke liye executable banayein
chmod u+w file.txt        # Sirf Owner ko write permission dein
chmod g-w file.txt        # Group se write permission wapis lein
chmod o-rwx secret.txt    # Others se saari permissions cheen lein
chmod u=rwx,go=rx app.sh  # Owner ko full, Group aur Others ko read+execute dein
```

---

### 01.03.03 `chown` (Change Ownership)

File ya folder ka Owner user aur Group badalne ke liye use hota hai (requires `sudo`/root).

* **Syntax:** `chown [options] <user>[:<group>] <target>`

**Examples:**
```bash
sudo chown deployuser app.py               # Owner change karke 'deployuser' banana
sudo chown deployuser:developers app.py    # Owner aur Group dono ek sath badalna
sudo chown :www-data /var/www/html         # Sirf group badalna
sudo chown -R ubuntu:ubuntu /home/ubuntu   # Recursive flag (-R) saare sub-folders par lagana
```

---

### 01.03.04 `chgrp` (Change Group)

Sirf file ka group ownership tabdeel karne ke liye specific utility hai (agar owner na badalna ho).

* **Syntax:** `chgrp [options] <group_name> <target>`

**Examples:**
```bash
chgrp devops deployment.log
chgrp -R www-data /var/www/uploads
```

> **Note:** Regular user sirf usi group mein file transfer kar sakta hai jiska wo khud member ho, jabke superuser (`root`) kisi bhi group ko assign kar sakta hai.

---

### 01.03.05 Special Permissions (SUID, SGID, Sticky Bit)

Standard `rwx` permissions ke ilawa Linux mein advanced operational aur security use-cases ke liye 3 special bits hote hain:

#### 1. SUID (Set User ID) — Octal Value: `4000`
* **Kahan lagta hai:** Executable binary files par.
* **Effect:** Jab koi regular user is program ko run karta hai, to program regular user ke bajaye **file owner (usually root)** ke privileges ke sath execute hota hai.
* **Example:** `/usr/bin/passwd` command par SUID laga hota hai taake normal user `/etc/shadow` file update kar sake.
* **Notation:** Owner ke execute block mein `s` nazar aata hai (`-rwsr-xr-x`).

```bash
sudo chmod u+s /usr/local/bin/custom_tool
sudo chmod 4755 /usr/local/bin/custom_tool
```

#### 2. SGID (Set Group ID) — Octal Value: `2000`
* **Kahan lagta hai:** Shared collaboration directories par.
* **Effect:** Is directory ke andar banne wali har nayi file ka group automatically parent directory ka group ban jata hai (creator ke default primary group ke bajaye).
* **Notation:** Group ke execute block mein `s` nazar aata (`drwxr-sr-x`).

```bash
sudo chmod g+s /var/shared_projects
sudo chmod 2775 /var/shared_projects
```

#### 3. Sticky Bit — Octal Value: `1000`
* **Kahan lagta hai:** Shared directories (jaise `/tmp`).
* **Effect:** Kisi file ko sirf wahi user delete ya rename kar sakta hai jo us file ka **actual owner** ho ya **root** ho, chahe folder par sabhi users ko write (`w`) permission hi kyun na ho.
* **Notation:** Others ke execute block mein `t` nazar aata hai (`drwxrwxrwt`).

```bash
sudo chmod +t /var/public_uploads
sudo chmod 1777 /var/public_uploads
```