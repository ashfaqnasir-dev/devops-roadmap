# 01.05 Package Management

Package management is a foundational concept in Linux administration. It refers to the methods and tools used to install, update, configure, and remove software packages on a Linux distribution. A package manager handles dependencies, ensures software integrity via cryptographic signatures, and maintains a centralized registry of installed applications.

---

## 01.05.01 apt (Debian/Ubuntu)

**APT (Advanced Package Tool)** is the primary command-line package management utility for Debian-based distributions and their derivatives, such as Ubuntu, Linux Mint, and Pop!_OS. It relies on lower-level tools like `dpkg` to manage individual `.deb` packages while resolving complex dependency trees across remote repositories.

### Common `apt` Commands

*   **Update local package lists:** Refreshes the local database of available packages from configured repositories.
    ```bash
    sudo apt update
    ```
*   **Install a package:** Downloads and installs a software package along with its required dependencies.
    ```bash
    sudo apt install <package_name>
    ```
*   **Remove a package:** Uninstalls a package while leaving its configuration files intact.
    ```bash
    sudo apt remove <package_name>
    ```
*   **Purge a package:** Uninstalls a package and completely removes its configuration files.
    ```bash
    sudo apt purge <package_name>
    ```
*   **Search for a package:** Searches available repositories for keywords matching a package name or description.
    ```bash
    apt search <keyword>
    ```
*   **Clean up unused dependencies:** Removes orphaned dependencies that were automatically installed but are no longer required by any application.
    ```bash
    sudo apt autoremove
    ```

---

## 01.05.02 yum/dnf (RHEL/CentOS)

Red Hat Enterprise Linux (RHEL), CentOS, Fedora, and AlmaLinux rely on RPM Package Manager (`rpm`) for individual packages, managed at a higher level by package management tools.

*   **YUM (Yellowdog Updater, Modified):** The traditional package manager used in older RHEL/CentOS versions (RHEL 6 and 7).
*   **DNF (Dandified YUM):** The modern, next-generation standard package manager introduced in Fedora 18 and made default in RHEL 8+. It features better performance, improved dependency resolution, and lower memory usage. On modern systems, `yum` is typically provided as a symbolic link to `dnf`.

### Common `dnf` Commands

*   **Install a package:**
    ```bash
    sudo dnf install <package_name>
    ```
*   **Remove a package:**
    ```bash
    sudo dnf remove <package_name>
    ```
*   **Search for a package:**
    ```bash
    dnf search <keyword>
    ```
*   **List installed packages:**
    ```bash
    dnf list installed
    ```
*   **Clean cache:** Removes cached package data to free up disk space.
    ```bash
    sudo dnf clean all
    ```

---

## 01.05.03 Update & Upgrade

Maintaining a secure and stable system requires regular updates. However, there is a distinct difference between updating package indices and upgrading the software itself.

### Key Concepts

1.  **Update (Refresh Metadata):** 
    This process downloads the latest catalog of available software versions and security advisories from your system's repositories. It *does not* change the software installed on your machine; it only tells your system what new versions are available.
    *   *Debian/Ubuntu:* `sudo apt update`
    *   *RHEL/Fedora:* `sudo dnf check-update` (or automatically handled during `dnf upgrade`)

2.  **Upgrade (Apply Upgrades):**
    This process compares your installed packages against the updated metadata and installs newer versions for packages that have updates available.
    *   **Debian/Ubuntu:** 
        *   `sudo apt upgrade`: Upgrades all currently installed packages without removing any packages.
        *   `sudo apt full-upgrade` (or `dist-upgrade`): Upgrades packages and intelligently handles the introduction of new dependencies or removal of obsolete packages if necessary.
    *   **RHEL/Fedora:**
        *   `sudo dnf upgrade`: Upgrades all installed packages to their latest available versions.

---

## 01.05.04 Install from Source

When a software package is not available in your distribution's official repositories, or when you need a specific custom feature, optimization, or the bleeding-edge version, you can install software directly from its **source code**.

### The Traditional Workflow (`GNU Autotools`)

The classic compilation workflow consists of three primary steps executed in the root directory of the extracted source code:

1.  **Configure:** Checks your system for the necessary build tools, compilers (like `gcc`), and development libraries (`-dev` or `-devel` packages). It generates a `Makefile` customized to your system environment.
    ```bash
    ./configure
    ```
2.  **Make:** Compiles the human-readable source code into machine-executable binary files using the generated `Makefile`.
    ```bash
    make
    ```
3.  **Make Install:** Copies the compiled binaries, configuration templates, and documentation files into their appropriate system directories (typically `/usr/local/bin` or `/usr/local/share`). This step usually requires administrative privileges.
    ```bash
    sudo make install
    ```

### Alternative Build Systems

While Autotools (`configure`) is common, modern open-source projects often use alternative build utilities:
*   **CMake:** Uses a `CMakeLists.txt` file.
    ```bash
    mkdir build && cd build
    cmake ..
    make
    sudo make install
    ```
*   **Make-only / Custom Scripts:** Some lightweight programs require only running `make` followed by `sudo make install`.

> **Note on Maintenance:** Packages installed from source are **not** managed by your system's package manager (`apt` or `dnf`). Consequently, they will not receive automatic security updates, and uninstalling them cleanly often requires keeping the source directory to run `sudo make uninstall` (if supported by the developer).
