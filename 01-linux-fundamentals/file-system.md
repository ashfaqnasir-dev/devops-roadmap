VS Code mein kholein:

text
C:\Users\anpk\Desktop\ashfaqnasir-dev\devops-practice\01-linux-fundamentals
Naya file banayein: file-system.md

Yeh content paste karein:

markdown
# 01.01 File System

> Linux directory structure, paths, and mount points.

## 📚 Concepts Covered

### 01.01.01 Directory Structure

Linux file system **hierarchical** hai — root (`/`) se shuru hota hai.

| Folder | Purpose | Examples |
|---|---|---|
| `/` | Root — sab kuch iske andar | - |
| `/etc` | Configuration files | `passwd`, `hosts`, `apt/`, `ssh/` |
| `/var` | Variable data (logs, cache) | `log/`, `www/`, `lib/` |
| `/home` | User home directories | `/home/ashfaq/` |
| `/tmp` | Temporary files (reboot par delete) | - |
| `/bin` | Essential binaries | `ls`, `cp`, `bash` |
| `/usr` | User programs | `bin/`, `lib/`, `share/` |
| `/opt` | Optional software | - |
| `/mnt` | Mount points (temporary) | `/mnt/c` (Windows) |
| `/media` | Removable media | USB, CD-ROM |

**Commands:**
```bash
ls /              # Root directory
ls /etc | head    # Config files
ls /var/log       # Logs
ls /home          # User homes
ls /tmp           # Temp files
01.01.02 Absolute vs Relative Paths
Type	Shuru	Example
Absolute	/ (root)	/home/ashfaq/projects
Relative	Current folder	../documents/file.txt
Special Paths:

Symbol	Matlab
.	Current directory
..	Parent directory
~	Home directory (/home/ashfaq)
-	Previous directory
Commands:

bash
# Absolute path
cd /home/ashfaq
pwd

# Relative path
cd ~/projects
cd ../documents
pwd
01.01.03 pwd, cd, ls
pwd — Print Working Directory:

bash
pwd
# Output: /home/ashfaq
cd — Change Directory:

bash
cd /tmp              # Absolute
cd ~/projects        # Home-based
cd ..                # Parent
cd -                 # Previous
cd                   # Home
ls — List:

bash
ls                   # Simple list
ls -l                # Long format (details)
ls -a                # All (hidden files)
ls -la               # Combined
ls -lh               # Human-readable sizes
ls -R                # Recursive
01.01.04 Symlinks (ln -s)
Symlink = Shortcut / Pointer to another file.

Banane ka tareeqa:

bash
ln -s original.txt link.txt
Dekhne ka tareeqa:

bash
ls -la
# Output: link.txt -> original.txt (purple color)

readlink link.txt
# Output: original.txt
Types:

Soft link (ln -s) — Shortcut (source delete → link toot jata hai)

Hard link (ln) — Same inode (source delete → link kaam karta hai)

Example:

bash
cd ~/symlink-test
echo "Original content" > original.txt
ln -s original.txt link.txt

ls -la
cat link.txt           # Original content dikhega
readlink link.txt      # original.txt
01.01.05 Mount Points (/mnt, /media)
Mount point = Jahan external storage attach hoti hai.

Path	Kya Mount Hota Hai
/mnt	Temporary mounts (WSL mein /mnt/c = Windows C:)
/media	Auto-mounted (USB, CD-ROM)
Commands:

bash
ls /mnt
# Output (WSL): c  d  wsl

ls /mnt/c | head -5
# Windows C: drive ka content

df -h
# Disk usage with mount points

mount | head -5
# Mounted filesystems

lsblk
# Block devices (disks)
🎯 Practice Commands
bash
# 1. Directory structure explore
ls /
ls /etc | head -5
ls /var/log | head -5
ls /home
ls /tmp | head -5

# 2. Absolute vs Relative
cd /home/ashfaq && pwd
cd ~/projects && pwd
cd ../documents && pwd

# 3. pwd, cd, ls
pwd
ls -la
ls -lh

# 4. Symlinks
mkdir -p ~/symlink-test && cd ~/symlink-test
echo "Test" > original.txt
ln -s original.txt link.txt
ls -la
readlink link.txt

# 5. Mount points
ls /mnt
df -h | head -5
mount | head -5
💡 Key Learnings
/ = Root — sab kuch iske andar

/etc = Config, /var = Logs, /tmp = Temp

Absolute path = / se shuru

Relative path = Current folder se

~ = Home, . = Current, .. = Parent

ln -s = Symlink (shortcut)

/mnt/c = Windows C: drive (WSL mein)

Status: ✅ Complete
Last Updated: 2026-10-08

text

**Save:** `Ctrl + S`

---

