# 📊 01.08 Linux System Monitoring

System Monitoring ke zariye administrators aur DevOps engineers server ki health, resource consumption (Disk, RAM, CPU), bottlenecks, aur system logs ko real-time track aur troubleshoot karte hain.

---

### 01.08.01 Disk Usage (`df`, `du`)

Storage space monitor karne aur yeh dekhne ke liye ke kaunsa folder ya partition disk bhar raha hai:

#### 1. `df` (Disk Free)
Mounted filesystems aur partitions par available space dekhne ke liye use hota hai.
- `-h`: Human-readable format (MB, GB mein show kare).
- `-T`: Filesystem type (ext4, xfs, overlay) show kare.
- `-i`: Inodes usage check kare (agar disk khali ho par nayi file na bane, to inodes full hotay hain).

```bash
# General disk overview
df -h

# Inode usage overview
df -ih
```

#### 2. `du` (Disk Usage)
Specific directories aur files ka exact size calculate karne ke liye use hota hai.
- `-s`: Summary (sirf total folder size show kare).
- `-h`: Human-readable format.
- `-d 1` ya `--max-depth=1`: Sirf 1 level deep folders ka size show kare.

```bash
# Current directory ke top folders ka size dekhna
du -h --max-depth=1 .

# System par top 5 sabse badi directories dhoondna
sudo du -ah /var/log | sort -rh | head -n 5
```

---

### 01.08.02 Memory Usage (`free`, `vmstat`)

RAM aur Swap space consumption analyze karne ke tools:

#### 1. `free`
Physical RAM aur Swap space ka instantaneous snapshot dikhata hai.
- `-m`: Megabytes mein output.
- `-g`: Gigabytes mein output.
- `-h`: Human-readable format.

```bash
free -h
```
*Output breakdown:*
- **total:** Total physical RAM.
- **used:** Applications dwara directly use hone wali memory.
- **free:** Bilkul unused memory.
- **buff/cache:** Kernel dwara file reads/writes tez karne ke liye temporary use ki gayi memory (yeh memory zaroorat padne par applications ko wapis mil sakti hai).
- **available:** Naye applications run karne ke liye actual kitni RAM dastiyab hai (Free + reclaimable cache).

#### 2. `vmstat` (Virtual Memory Statistics)
Memory, swap IO, processes, aur CPU activity ka continuous report deta hai.

```bash
# Har 2 second baad 5 bar update report kare:
vmstat 2 5
```
*Key metric:*
- `si` (swap in) aur `so` (swap out): Agar yeh values consistent non-zero hon, iska matlab hai server RAM exhaust ho chuki hai aur machine disk par swapping kar rahi hai (severe performance drop).

---

### 01.08.03 CPU Usage (`top`, `mpstat`)

Processor load aur per-core distribution track karne ke tools:

#### 1. `top` / Batch Mode
Live CPU usage dekhne ke alawa automation scripts mein CPU state capture karne ke liye batch mode (`-b`) use hota hai:

```bash
# Ek single snapshot print karke exit kare
top -b -n 1 | head -n 20
```
*Metrics to watch:*
- `%us` (User): Applications dwara consume CPU.
- `%sy` (System): Kernel space processes ka CPU usage.
- `%wa` (I/O Wait): CPU disk ya network I/O ka intezar kar raha hai (high value indicates disk bottleneck).
- `%id` (Idle): Khali CPU time.

#### 2. `mpstat` (Multi-Processor Statistics)
Har individual CPU core ka usage alag alag analyze karta hai (part of `sysstat` package).

```bash
# Install karein agar available na ho
sudo apt install sysstat -y

# Saare cores ka breakdown har 2 second baad dikhaye
mpstat -P ALL 2
```

---

### 01.08.04 Logs (`/var/log`, `journalctl`)

System events, errors aur service logs inspect karne ke tareeqay:

#### 1. Traditional Filesystem Logs (`/var/log`)
Linux ke traditional plain-text log files:
- `/var/log/syslog` ya `/var/log/messages`: General operating system events.
- `/var/log/auth.log` ya `/var/log/secure`: SSH logins aur authentication attempts.
- `/var/log/dmesg`: Kernel ring buffer (hardware aur bootup messages).

```bash
# Failed SSH login attempts check karna
grep "Failed password" /var/log/auth.log
```

#### 2. `journalctl` (Systemd Journal)
Modern Linux distributions ka centralized, binary structured logging system.

```bash
# Real-time tailing (live streaming logs)
journalctl -f

# Specific systemd service (e.g. Nginx, Docker) ke logs
journalctl -u nginx.service -f

# Sirf current boot ke logs dekhna
journalctl -b

# Pichle 1 ghante ke error logs dekhna (-p 3 = Errors only)
journalctl --since "1 hour ago" -p 3
```

---

### 01.08.05 System Info (`uname`, `uptime`)

Operating system, kernel version aur machine load ki basic maloomat:

#### 1. `uname` (Unix Name)
Kernel architecture aur version information:
- `-a` (All): Complete kernel version, hostname, aur CPU architecture print kare.
- `-r` (Release): Kernel release version.
- `-m` (Machine): Hardware architecture (e.g., `x86_64` ya `aarch64`).

```bash
uname -a
# Example Output: Linux server01 5.15.0-88-generic #98-Ubuntu SMP x86_64 GNU/Linux
```

#### 2. `uptime`
Batata hai server kab se chal raha hai aur kitna busy hai:

```bash
uptime
# Example Output: 18:18:24 up 45 days,  2:14,  3 users,  load average: 0.15, 0.22, 0.18
```
*Load Average Metrics (1 min, 5 min, 15 min):*
- Agar server ke paas **4 CPU cores** hain aur load average **4.00** hai, to CPU 100% utilized hai.
- Agar load average cores se zyada ho (e.g. 8.00 on a 4-core machine), to tasks CPU time ke liye queue mein phase hue hain.