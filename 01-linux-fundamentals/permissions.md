## 📝 File 2: `permissions.md`

**Same folder mein** naya file: `permissions.md`

**Yeh content paste karein:**

```markdown
# 01.03 Permissions

> Linux file permissions — r, w, x and how to manage them.

## 📚 Concepts Covered

### 01.03.01 Permission Types (`r`, `w`, `x`)

**3 Types:**

| Symbol | Name | Value | Kya Karta Hai |
|---|---|---|---|
| `r` | Read | 4 | File parhna / folder list karna |
| `w` | Write | 2 | File likhna / folder mein changes |
| `x` | Execute | 1 | File chalana / folder mein ghusna |

**3 Categories:**

| Symbol | Kaun |
|---|---|
| `u` | User (Owner) |
| `g` | Group |
| `o` | Others |

**Output Format:**
-rw-r--r--
│││││││││
│││││││└┴── Others (r--)
││││└┴───── Group (r--)
│└┴──────── Owner (rw-)
└────────── File type (-)

text

**File types:**
- `-` = Regular file
- `d` = Directory
- `l` = Symlink

### 01.03.02 `chmod` (Symbolic & Numeric)

**Symbolic Mode:**
| Command | Matlab |
|---|---|
| `chmod +x file` | Execute add (sab) |
| `chmod -x file` | Execute hatao |
| `chmod +r file` | Read add |
| `chmod +w file` | Write add |
| `chmod u+x file` | Sirf owner ko execute |
| `chmod g+x file` | Sirf group ko execute |
| `chmod o+x file` | Sirf others ko execute |
| `chmod a+x file` | Sab ko execute |

**Numeric Mode:**

| Number | Combination | Result |
|---|---|---|
| `7` | 4+2+1 | `rwx` |
| `6` | 4+2 | `rw-` |
| `5` | 4+1 | `r-x` |
| `4` | 4 | `r--` |
| `3` | 2+1 | `-wx` |
| `2` | 2 | `-w-` |
| `1` | 1 | `--x` |
| `0` | - | `---` |

**Common:**
| Mode | Symbolic | Use |
|---|---|---|
| `755` | `rwxr-xr-x` | Scripts, folders |
| `644` | `rw-r--r--` | Regular files |
| `600` | `rw-------` | Private files |
| `700` | `rwx------` | Private scripts |
| `777` | `rwxrwxrwx` | ⚠️ Unsafe! |

**Commands:**
```bash
chmod +x script.sh           # Symbolic
chmod 755 script.sh          # Numeric
chmod 644 file.txt
chmod 600 secret.txt
chmod -R 755 folder/         # Recursive
01.03.03 chown (Ownership)
Owner change karna:

bash
sudo chown newuser file              # User change
sudo chown newuser:newgroup file     # User + group
sudo chown -R newuser folder/        # Recursive
Example:

bash
ls -l file.txt
# -rw-r--r-- 1 ashfaq ashfaq ...

sudo chown root:root file.txt
ls -l file.txt
# -rw-r--r-- 1 root root ...

sudo chown ashfaq:ashfaq file.txt
Note: sudo chahiye owner change karne ke liye.

01.03.04 chgrp (Groups)
Group change karna:

bash
sudo chgrp newgroup file
sudo chgrp -R newgroup folder/
Groups dekhein:

bash
groups              # Apne groups
id                  # Detailed info
cat /etc/group      # Saare groups
Example:

bash
sudo chgrp root file.txt
ls -l file.txt
# ... ashfaq root ...
01.03.05 Special Permissions (SUID, SGID, Sticky Bit)
Special	Symbol	Number	Kya Karta Hai
SUID	s (user)	4xxx	File owner ki permission se chalti hai
SGID	s (group)	2xxx	File group ki permission se chalti hai
Sticky Bit	t	1xxx	Sirf owner delete kar sakta hai
Examples:

bash
# SUID — passwd command
ls -l /usr/bin/passwd
# -rwsr-xr-x (s = SUID)

# Sticky Bit — /tmp
ls -ld /tmp
# drwxrwxrwt (t = sticky bit)
Set karna:

bash
chmod 4755 script.sh    # SUID
chmod 2755 script.sh    # SGID
chmod 1777 shared/      # Sticky bit
🎯 Practice Commands
bash
# Setup
mkdir -p ~/perm-test && cd ~/perm-test
echo "Test" > test.txt
touch script.sh

# 1. Permission types
ls -l test.txt
# -rw-r--r--

# 2. chmod symbolic
chmod +x script.sh
ls -l script.sh
# -rwxr-xr-x

# 3. chmod numeric
chmod 644 script.sh
chmod 755 script.sh
chmod 600 script.sh
chmod 777 script.sh    # ⚠️

# 4. chown
sudo chown root:root test.txt
sudo chown ashfaq:ashfaq test.txt

# 5. chgrp
sudo chgrp root test.txt
sudo chgrp ashfaq test.txt

# 6. Special permissions
chmod 4755 script.sh
chmod 2755 script.sh
mkdir shared && chmod 1777 shared
💡 Key Learnings
r = 4, w = 2, x = 1

755 = Common for scripts

644 = Common for files

600 = Private files

777 = ⚠️ Never use in production

chmod = Change permissions

chown = Change owner

chgrp = Change group

SUID (4xxx) = Run as owner

SGID (2xxx) = Run as group

Sticky bit (1xxx) = Only owner can delete

Status: ✅ Complete
Last Updated: 2026-10-08

text

**Save:** `Ctrl + S`

---

## 🚀 Ab Push Karein

### **GitHub Desktop Se:**

1. GitHub Desktop kholein
2. **devops-practice** repo select karein
3. **Left sidebar** mein naye files dikhengi:
   - `01-linux-fundamentals/file-system.md` ✅
   - `01-linux-fundamentals/permissions.md` ✅
4. **Summary:** `Add File System and Permissions markdown`
5. **Commit to main** → **Push origin**

---

## 📊 Ab `devops-roadmap` Update Karein

**File:** `devops-roadmap/01-linux-fundamentals/README.md`

### **Update 1: Checkboxes**

```markdown
### 01.01 File System
- [x] 01.01.01 Directory structure (`/etc`, `/var`, `/home`, `/tmp`)
- [x] 01.01.02 Absolute vs relative paths
- [x] 01.01.03 `pwd`, `cd`, `ls`
- [x] 01.01.04 Symlinks (`ln -s`)
- [x] 01.01.05 Mount points (`/mnt`, `/media`)

### 01.02 File Operations
- [x] 01.02.01 Create (`touch`, `mkdir`)
- [x] 01.02.02 Copy (`cp`)
- [x] 01.02.03 Move/Rename (`mv`)
- [x] 01.02.04 Delete (`rm`, `rmdir`)
- [x] 01.02.05 View (`cat`, `less`, `head`, `tail`)
- [x] 01.02.06 Find (`find`, `locate`)

### 01.03 Permissions
- [x] 01.03.01 Permission types (`r`, `w`, `x`)
- [x] 01.03.02 `chmod` (symbolic & numeric)
- [x] 01.03.03 `chown` (ownership)
- [x] 01.03.04 `chgrp` (groups)
- [x] 01.03.05 Special permissions (SUID, SGID, sticky bit)
Update 2: Progress Table
markdown
| Section | Items | Done |
|---------|-------|------|
| File System | 5 | 5/5 ✅ |
| File Operations | 6 | 6/6 ✅ |
| Permissions | 5 | 5/5 ✅ |
| Process Management | 5 | 0/5 ⏳ |
| Package Management | 4 | 0/4 ⏳ |
| Networking Commands | 5 | 0/5 ⏳ |
| SSH & Remote | 4 | 0/4 ⏳ |
| System Monitoring | 5 | 0/5 ⏳ |

**Overall: 16/39 (41%)**
Update 3: Status Line
markdown
**Status:** 🔄 In Progress (41%)
**Last Updated:** 2026-10-08
Save + Push (GitHub Desktop se).

📝 Mujhe Batayein
text
✅ file-system.md banaya?
✅ permissions.md banaya?
✅ GitHub Desktop se push kiya?
✅ devops-roadmap mein progress update ki?
✅ Ab 41% dikha raha hai?

Sawal: [koi confusion ho]
🎁 Aaj Ka Summary
Kaam	Status
01.01 File System	✅
01.02 File Operations	✅
01.03 Permissions	✅
3 markdown files banayi	✅
Progress: 16/39 (41%)	✅
Aap ne aaj bohat acha kaam kiya! 🎉

🎯 Agla Step
Kal se:

01.04 Process Management (5 concepts)

01.05 Package Management (4 concepts)

01.06 Networking Commands (5 concepts)

01.07 SSH & Remote (4 concepts)

01.08 System Monitoring (5 concepts)

Phir 01-linux-fundamentals 100% complete! 🚀

