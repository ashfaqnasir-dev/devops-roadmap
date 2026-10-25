# 🌐 01.06 Linux Networking Commands

Linux networking tools system administrators aur DevOps engineers ke liye connectivity test karne, open ports check karne, DNS query resolve karne aur packet flow analyze karne ke bunyadi hathyar hain.

---

### 01.06.01 Connectivity & Data Transfer (`ping`, `curl`, `wget`)

Network reachable hai ya nahi aur remote endpoints se data exchange karne ke basic utilities:

#### 1. `ping` (ICMP Echo Check)
Network connectivity aur round-trip latency measure karne ke liye use hota hai.
- **Description:** Remote host ko ICMP echo packets bhej kar check karta hai ke host reachable hai ya packet drop ho raha hai.
- **Commands:**
  ```bash
  ping google.com             # Continuous ping (Ctrl+C to stop)
  ping -c 4 8.8.8.8           # Sirf 4 packets bhej kar exit ho jaye (-c = count)
  ```

#### 2. `curl` (Client URL Tool)
Network protocols (HTTP, HTTPS, FTP) ke zariye data send ya receive karne ka multi-purpose tool.
- **Commands:**
  ```bash
  # Web page ka content fetch karna
  curl https://api.github.com

  # Sirf HTTP Response Headers inspect karna (-I)
  curl -I https://google.com

  # Follow redirects (-L) aur file download karna (-O)
  curl -LO https://example.com/file.tar.gz

  # POST request with JSON payload:
  curl -X POST https://api.example.com/login \
    -H "Content-Type: application/json" \
    -d '{"user":"admin","pass":"secret"}'
  ```

#### 3. `wget` (Non-Interactive File Downloader)
Background mein files aur web pages download karne ke liye ideal tool.
- **Commands:**
  ```bash
  wget https://example.com/archive.zip        # Direct download
  wget -c https://example.com/large.iso       # Incomplete download resume karna (-c)
  wget -b https://example.com/file.zip        # Background download shuru karna (-b)
  ```

---

### 01.06.02 Socket & Port Inspection (`netstat`, `ss`)

Chalne wale network services aur open listening ports check karne ke tools:

#### 1. `netstat` (Legacy Utility)
Purana standard tool jo active connections aur routing tables dikhata hai (modern distros par yeh `net-tools` package ka hissa hota hai).
- **Common Command:**
  ```bash
  netstat -tulnp
  ```

#### 2. `ss` (Socket Statistics - Modern Replacement)
`netstat` ka tez aur modern replacement jo kernel space se direct socket data read karta hai.
- **Common Flags Explanation:**
  - `-t`: TCP sockets
  - `-u`: UDP sockets
  - `-l`: Sirf listening ports dikhaye
  - `-n`: Numeric IP/port show kare (DNS resolve na kare taake instant output mile)
  - `-p`: Process name aur PID show kare (sudo zaroori hai)

- **Practical Commands:**
  ```bash
  # Saare active listening TCP/UDP ports aur unke processes:
  sudo ss -tulnp

  # Check karein agar port 80 ya 443 open hai:
  sudo ss -tulnp | grep -E ':(80|443)'

  # Established connections check karna:
  ss -t -a state established
  ```

---

### 01.06.03 Interface & IP Management (`ifconfig`, `ip`)

Network cards (NICs), IP addresses aur routing table configure karne ke auzar:

#### 1. `ifconfig` (Deprecated)
Purani command jo interfaces ka IP, MAC address aur packet stats show karti thi.
- **Command:**
  ```bash
  ifconfig eth0
  ```

#### 2. `ip` (iproute2 Suite - Standard Replacement)
Modern Linux systems par network routing, interfaces aur tunnels manage karne ka standard tool.
- **Commands:**
  ```bash
  # Tamam network interfaces aur IP addresses show karna:
  ip addr show
  # ya short form:
  ip a

  # Default gateway aur routing table dekhna:
  ip route show

  # Interface ko up ya down karna:
  sudo ip link set eth0 up
  sudo ip link set eth0 down

  # Temporary IP assign karna:
  sudo ip addr add 192.168.1.50/24 dev eth0
  ```

---

### 01.06.04 DNS Resolution & Lookup (`dig`, `nslookup`)

Domain Name System (DNS) records troubleshoot aur query karne ke tools:

#### 1. `dig` (Domain Information Groper - Recommended)
DNS queries ke liye DevOps aur SREs ka primary tool jo detailed aur authentic DNS response return karta hai.
- **Commands:**
  ```bash
  # Default 'A' record lookup
  dig example.com

  # Short clean output (sirf IP address):
  dig example.com +short

  # Specific DNS record types query karna:
  dig example.com MX          # Mail servers
  dig example.com TXT         # SPF / DKIM verification records
  dig example.com CNAME       # Alias records

  # Specific DNS server se query karna (e.g. Cloudflare 1.1.1.1):
  dig @1.1.1.1 example.com
  ```

#### 2. `nslookup` (Name Server Lookup)
DNS queries ke liye traditional aur simple interactive/non-interactive utility.
- **Commands:**
  ```bash
  nslookup example.com
  nslookup -type=any example.com 8.8.8.8
  ```

---

### 01.06.05 Path Analysis & Packet Capture (`traceroute`, `tcpdump`)

Network latency issues aur deep packet analysis karne ke advanced diagnostic tools:

#### 1. `traceroute` / `tracepath`
Aapke computer se target server tak packet kin kin routers (hops) se guzarta hai, yeh trace karta hai.
- **Use Case:** Network mein kahan packet drop ho raha hai ya kaunsa hop zyada latency cause kar raha hai.
- **Commands:**
  ```bash
  traceroute google.com

  # TCP SYN packets use karna (firewall ICMP drop kare to useful):
  sudo traceroute -T -p 443 google.com
  ```

#### 2. `tcpdump` (Command-Line Packet Analyzer)
Network interface par aane aur jaane wale real network packets ko capture aur inspect karta hai.
- **Description:** Deep troubleshooting (jaise handshake failure, unexpected drops, unauthorized traffic) ke liye use hota hai.
- **Commands:**
  ```bash
  # Specific interface par packets live capture karein:
  sudo tcpdump -i eth0

  # Sirf specific port (e.g. HTTP 80) ka traffic capture karein:
  sudo tcpdump -i eth0 port 80

  # Source ya destination IP filter karna:
  sudo tcpdump -i any host 192.168.1.100

  # Packets ko .pcap file mein save karna (Wireshark mein analyze karne ke liye):
  sudo tcpdump -i eth0 -w traffic_capture.pcap
  ```