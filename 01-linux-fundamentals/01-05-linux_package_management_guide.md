# 📦 01.05 Linux Package Management

Linux distributions software install, update, configure, aur remove karne ke liye **Package Managers** use karti hain. Yeh tools automated repositories se pre-compiled software binaries download karte hain aur software ki tamam dependencies ko automatically resolve karte hain.

---

### 01.05.01 `apt` (Debian & Ubuntu Family)

`apt` (Advanced Package Tool) Debian, Ubuntu, Linux Mint, aur unke derivatives par software manage karne ka modern command-line tool hai.

* **Package Format:** `.deb` (Debian package files)
* **Repositories Config:** `/etc/apt/sources.list` aur `/etc/apt/sources.list.d/`

#### Key `apt` Commands:

```bash
# Package search karna
apt search <package_name>

# Package details dekhna
apt show <package_name>

# Naya package install karna
sudo apt install <package_name> -y

# Package remove karna (config files bachi rehti hain)
sudo apt remove <package_name>

# Package completely remove karna (config files samet)
sudo apt purge <package_name>

# Unused dependencies (jo ab zaroori nahi) clean karna
sudo apt autoremove
```

---

### 01.05.02 `yum` & `dnf` (RHEL, CentOS, Rocky, Fedora)

Red Hat-based Linux distributions par packages manage karne ke tools:

* **`yum` (Yellowdog Updater, Modified):** RHEL 7 aur CentOS 7 ka standard tool tha.
* **`dnf` (Dandified YUM):** RHEL 8/9, CentOS Stream, Rocky Linux, aur Fedora ka modern default package manager hai (fast dependency resolution aur improved memory management provide karta hai).
* **Package Format:** `.rpm` (RPM Package Manager files)
* **Repositories Config:** `/etc/yum.repos.d/`

#### Key `yum` / `dnf` Commands:

```bash
# Package search karna
dnf search <package_name>

# Package info check karna
dnf info <package_name>

# Package install karna
sudo dnf install <package_name> -y

# Package uninstall karna
sudo dnf remove <package_name>

# Package clean cache
sudo dnf clean all
```

*(Note: Modern systems par agar aap `yum install` bhi likhein ge, to background mein `dnf` hi run hota hai).*

---

### 01.05.03 Update vs Upgrade

DevOps aur System Administration mein `update` aur `upgrade` ke farq ko samajhna nihayat zaroori hai:

#### Debian / Ubuntu (`apt`):

```bash
# 1. Update: Sirf repositories ki metadata/index list refresh karta hai (koi package upgrade nahi hota)
sudo apt update

# 2. Upgrade: Installed packages ke naye versions ko download aur install karta hai
sudo apt upgrade -y

# 3. Full / Dist-upgrade: Nayi dependencies add ya obsolete remove karke major kernel/system upgrades karta hai
sudo apt dist-upgrade
```

#### RHEL / Fedora (`dnf`):

```bash
# DNF mein 'check-update' packages check karta hai
sudo dnf check-update

# 'dnf upgrade' automatically repos refresh karke packages upgrade karta hai
sudo dnf upgrade -y
```

> **Best Practice Tip:** Production servers par direct `apt upgrade -y` chalane se bachein; hamesha staging par pehle test karein taake koi running library break na ho.

---

### 01.05.04 Install from Source (Compiling Code)

Jab kisi package ka latest version official repository mein available na ho ya custom compile-time flags enable karne hon, to source code (`.tar.gz`) download karke manually build kiya jata hai.

#### 1. Build Tools Install Karein:

```bash
# Ubuntu/Debian:
sudo apt install build-essential gcc make -y

# RHEL/Rocky:
sudo dnf groupinstall "Development Tools" -y
```

#### 2. The Classic 3-Step Compilation Process:

```bash
# Step A: Source code download aur extract karein
wget https://example.com/software-1.0.tar.gz
tar -xzvf software-1.0.tar.gz
cd software-1.0

# Step B: Configure (System requirements aur dependencies check karta hai)
./configure --prefix=/usr/local

# Step C: Compile (Source code ko binary machine code mein compile karta hai)
make -j$(nproc)

# Step D: Install (Compiled binaries ko system directories mein copy karta hai)
sudo make install
```

#### Comparison: Package Manager vs Source Build

| Feature | Package Manager (`apt`/`dnf`) | Building from Source |
|---|---|---|
| **Ease of Use** | Ek command se install/update | Manual configuration required |
| **Dependencies** | Automatically handle hoti hain | Manually dhundh kar install karni parti hain |
| **Updates/Removal** | Simple `apt remove` / `dnf remove` | Uninstaller create na ho to delete karna mushkil |
| **Customization** | Standard pre-compiled settings | Custom modules aur flags enable kar sakte hain |