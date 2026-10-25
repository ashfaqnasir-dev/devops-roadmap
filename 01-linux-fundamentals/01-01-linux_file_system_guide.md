# 📁 01.01 Linux File System

Linux ka file system ek single hierarchical tree structure follow karta hai jo root directory (`/`) se shuru hota hai. Windows ke bar'aks (jahan `C:`, `D:` drives hoti hain), Linux mein sab kuch files aur directories ke roop mein root (`/`) ke neeche mount hota hai ("Everything is a file").

---

### 01.01.01 Directory Structure (`/etc`, `/var`, `/home`, `/tmp`)

Filesystem Hierarchy Standard (FHS) ke mutabiq har folder ka ek makhsoos maqsad hota hai:

| Directory | Full Form / Meaning | Maqsad (Purpose) | Examples |
| :--- | :--- | :--- | :--- |
| **`/etc`** | Editable Text Configurations | System-wide configuration files aur startup scripts store karta hai. | `/etc/nginx/nginx.conf`, `/etc/passwd`, `/etc/hosts` |
| **`/var`** | Variable Data | Dynamic aur frequently changing data rakhta hai jo waqt ke sath badalta hai (jaise logs, spool, caches). | `/var/log/syslog`, `/var/www/html`, `/var/lib/docker` |
| **`/home`** | Home Directories | Regular users ka personal workspace aur data (har user ka apna folder hota hai, e.g., `/home/john`). | Desktop, Downloads, `~/.bashrc`, user code |
| **`/tmp`** | Temporary Files | Applications ki banayi temporary files. System restart hone par ya automatically cleanup tool ke zariye yeh folder clean ho jata hai. | Session data, temporary build files |
| **`/bin` / `/usr/bin`** | Binaries | Essential user commands aur executable programs. | `ls`, `grep`, `python3`, `tar` |
| **`/root`** | Root's Home | Superuser (root) ki private home directory (`/home` ke andar nahi hoti). | Root user ki configuration aur files |

---

### 01.01.02 Absolute vs Relative Paths

File system mein kisi file ya directory tak pohnchne ke do tareeqay hotay hain:

#### 1. Absolute Path
* Hamesha root directory (`/`) se shuru hota hai.
* Aap chahe system mein kisi bhi location par khare hon, absolute path hamesha same file ko point karta hai.
* **Example:**
  ```bash
  cat /var/log/nginx/access.log
  cd /home/ubuntu/projects/app
  ```

#### 2. Relative Path
* Current working directory se shuru hota hai (is me shuru mein `/` nahi lagta).
* Yeh do special pointers use karta hai:
  * `.` : Current directory
  * `..` : Parent directory (ek step peeche)
* **Example:**
  ```bash
  # Agar aap /home/ubuntu par khare hain:
  cd projects/app       # Same as /home/ubuntu/projects/app
  cd ../                # Ek directory peeche (/home)
  cat ./config.json     # Current folder ki config file
  ```

---

### 01.01.03 Navigation Commands (`pwd`, `cd`, `ls`)

Linux terminal par navigate karne ki bunyadi commands:

#### 1. `pwd` (Print Working Directory)
Batata hai ke aap is waqt kis absolute path par khare hain:
```bash
pwd
# Output: /home/ubuntu/my-project
```

#### 2. `cd` (Change Directory)
Ek directory se doosri directory mein move karne ke liye:
```bash
cd /etc/nginx         # Specific folder mein jayein
cd ..                 # Ek step peeche (parent directory)
cd ~                  # Apni home directory mein jayein (/home/user)
cd -                  # Previous directory mein wapis jayein jahan se aaye thay
```

#### 3. `ls` (List Directory Contents)
Folder ke andar maujood files aur sub-folders dekhne ke liye:
```bash
ls                    # Simple list
ls -l                 # Detailed list (permissions, owner, size, date)
ls -a                 # Hidden files bhi show karein (jo dot . se shuru hoti hain)
ls -la                # Detailed view + hidden files
ls -lh                # File size human-readable format mein (KB, MB, GB)
```

---

### 01.01.04 Symlinks (`ln -s`)

Symbolic Links (Symlinks) Windows ke "Shortcuts" ki tarah hotay hain. Yeh ek aisi file hoti hai jo doosri file ya folder ke path ko point karti hai.

* **Description:** Soft link (symlink) original file ka path store karta hai. Agar target file delete ho jaye to link broken ho jata hai.
* **Syntax:**
  ```bash
  ln -s <target_original_path> <shortcut_link_name>
  ```
* **Practical Examples:**
  ```bash
  # 1. Nginx site activate karne ke liye standard pattern:
  ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp

  # 2. File ka shortcut banana:
  ln -s /var/log/application.log ~/app_log_shortcut

  # 3. Verify karna (ls -l se arrow dikhta hai):
  ls -l ~/app_log_shortcut
  # Output: lrwxrwxrwx ... app_log_shortcut -> /var/log/application.log
  ```
* **Remove Symlink:**
  ```bash
  rm ~/app_log_shortcut    # Isse original file delete nahi hoti, sirf shortcut delete hota hai
  ```

---

### 01.01.05 Mount Points (`/mnt`, `/media`)

Linux mein hard drives, USBs ya network shares direct kisi drive letter ke tor par appear nahi hotay, balki unhe file system tree ke kisi folder ke sath attach (mount) karna padta hai.

* **`/media` (Removable Media):**
  * Automatic mount points ke liye use hota hai.
  * Jab aap USB drive, CD-ROM ya external drive plug karte hain, system automatically `/media/<username>/<device-name>` par mount kar deta hai.

* **`/mnt` (Temporary / Manual Mount):**
  * System administrators ke manual mounts ke liye hota hai.
  * System rescue, extra secondary EBS volumes, ya network shared drives (NFS/CIFS) ko temporary tor par attach karne ke liye use hota hai.

* **Mounting Commands:**
  ```bash
  # Storage drives aur partitions list karein
  lsblk

  # Disk partition ko /mnt par mount karein
  sudo mount /dev/sdb1 /mnt

  # Check active mounts
  df -h

  # Unmount karna (use karne ke baad)
  sudo umount /mnt
  ```