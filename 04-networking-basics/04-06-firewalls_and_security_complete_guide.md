# 🛡️ 04.06 Firewalls & Security — Complete Guide

> **Network Security** ka maqsad servers, applications, aur data ko unauthorized access, malicious attacks, aur data leaks se mehfooz rakhna hai. Production systems mein security sirf ek tool ka naam nahi balki multilayered (defense-in-depth) approach hoti hai.

---

## 1. Network Security Groups (NSGs & Cloud Firewalls)

Cloud infrastructure (AWS Security Groups, Azure NSGs, GCP Firewall Rules) mein instances ke ird-gird ek **virtual stateful firewall** layer hoti hai.

### Key Characteristics:
* **Stateful Nature:** Agar aapne incoming request allow kar di hai (e.g., port 80 par), toh uska response (outbound reply) automatically allow ho jayega, chahe outbound rules mein block bhi ho.
* **Default Deny:** Default tor par cloud security groups tamam incoming traffic block karte hain jab tak explicit rule na banaya jaye.
* **Rule Components:**
  * **Traffic Direction:** Inbound (Ingress) ya Outbound (Egress).
  * **Protocol:** TCP, UDP, ICMP, ya All.
  * **Port Range:** Specific port (e.g., `22`, `443`) ya range (`30000-32767`).
  * **Source / Destination:** IP address, CIDR block (`192.168.1.0/24`), ya doosra Security Group ID.

### Real-World Best Practice Architecture:
```
Internet 
   │
   ▼
[ ALB Security Group ] (Inbound: 80, 443 from 0.0.0.0/0)
   │
   ▼
[ App Server Security Group ] (Inbound: 8080 ONLY from ALB SG)
   │
   ▼
[ Database Security Group ] (Inbound: 5432 ONLY from App Server SG)
```
> 💡 **Tip:** Kabhi bhi database port (`3306`, `5432`) ko public internet (`0.0.0.0/0`) ke liye open na karein. Hamesha application servers ke private IP ya Security Group ID ko source banayein.

---

## 2. Linux `iptables` Basics (Host-level Firewall)

`iptables` Linux kernel ke **Netfilter** framework ka CLI tool hai jo packets ko inspect aur filter karta hai.

### A. Tables & Chains Architecture:
Sabse zyadatar use hone wali table **`filter`** table hai, jisme teen bunyadi chains hoti hain:
1. **`INPUT`:** Aane wale packets jo isi server ke liye hain.
2. **`OUTPUT`:** Server se nikalne wale packets jo bahir ja rahe hain.
3. **`FORWARD`:** Packets jo is server ke zariye kisi doosre computer par bheje ja rahe hain (Router/Bridge mode).

### B. Targets (Actions):
* `ACCEPT`: Packet ko aage jaane dein.
* `DROP`: Packet ko bina kisi jawab ke khamoshi se phenk dein (Best for stealth).
* `REJECT`: Packet block karein aur bhejne wale ko error message (ICMP unreachable) wapis karein.

### C. Essential Commands:
```bash
# 1. Tamam current rules line numbers ke sath list karein
sudo iptables -L -v -n --line-numbers

# 2. Existing connections ko allow karein (Taake SSH drop na ho)
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. Localhost (Loopback) traffic allow karein
sudo iptables -A INPUT -i lo -j ACCEPT

# 4. Specific port (SSH port 22) allow karein
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 5. Web traffic (80 aur 443) allow karein
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 6. Specific malicious IP ko block karein
sudo iptables -A INPUT -s 203.0.113.50 -j DROP

# 7. Default Policy: Baaqi sab kuch drop karein
sudo iptables -P INPUT DROP
```

> ⚠️ **Note:** Modern Ubuntu/Debian systems mein `iptables` ke upar ek aasan frontend wrapper **`ufw` (Uncomplicated Firewall)** use hota hai:
> ```bash
> sudo ufw default deny incoming
> sudo ufw allow 22/tcp
> sudo ufw allow 443/tcp
> sudo ufw enable
> ```

---

## 3. VPNs & Tunnels (Secure Remote Access)

Public internet par do alag locations ya remote developers ko internal private network ke sath jorne ke liye encrypted tunnels use kiye jaate hain.

### A. Site-to-Site vs Client-to-Site:
* **Client-to-Site (Remote Access):** Developer apne laptop se company ke internal VPC/LAN se connect hota hai (e.g., OpenVPN, WireGuard client).
* **Site-to-Site VPN:** Do complete data centers ya on-premise office ko cloud VPC ke sath permanent tunnel ke zariye link karna (e.g., IPSec tunnels).

### B. Key Technologies:
| Protocol / Tool | Pros | Cons | Typical Use Case |
| :--- | :--- | :--- | :--- |
| **IPSec** | Industry standard, hardware routers par broad support | Setup kafi complex hota hai | On-prem data center to AWS VPC |
| **OpenVPN** | Trusted, battle-tested, highly configurable | Thora heavy aur userspace-based (slower) | Enterprise remote employee access |
| **WireGuard** | Modern, lightweight, kernel space mein chalta hai (fast) | Dynamic IP tracking mein extra config mangta hai | High-speed server-to-server interconnects |
| **SSH Tunneling (SOCKS/Port Forward)** | Instant, bina installation ke chalta hai | Scale nahi hota, single user ke liye hai | Quick debug: `ssh -L 5432:db:5432 user@bastion` |

---

## 4. DDoS Protection (Distributed Denial of Service)

DDoS attack mein hazaron compromised systems (botnets) ek hi waqt mein target service par be-tahasha traffic bhejte hain taake server ya network bandwidth choke ho jaye aur genuine users access na kar sakein.

### A. Attack Types:
1. **Volumetric Attacks (L3/L4):** Network bandwidth saturate karna (UDP Floods, ICMP Echo Floods, DNS Amplification).
2. **Protocol Attacks (L4):** Network devices aur firewalls ke resources consume karna (TCP SYN Flood).
3. **Application Attacks (L7):** Web server/database ke CPU/RAM ko exhausted karna (HTTP GET flood on search endpoints, slowloris).

### B. Defense Strategies:
* **Anycast DNS & CDN Edge (Cloudflare, AWS CloudFront, Fastly):** Incoming traffic ko dunya bhar ke sekron data centers par distribute (absorb) kar dena taake origin server par load na aaye.
* **Rate Limiting:** Nginx ya API Gateway level par ek IP se aane wali requests ki hadd muqarrar karna:
  ```nginx
  limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
  ```
* **SYN Cookies (OS Level):** SYN flood attacks se bachne ke liye Linux kernel parameters tune karna:
  ```bash
  sysctl -w net.ipv4.tcp_syncookies=1
  ```
* **WAF (Web Application Firewall):** Malicious bots, SQL injections, aur scrapers ko edge par block karna.

---

## 5. Zero-Trust Networking (Never Trust, Always Verify)

Purana security model **Perimeter-based (Castle-and-Moat)** tha: *"Agar koi office ke Wi-Fi ya internal VPN ke andar aagaya, toh woh sab kuch access kar sakta hai."*

**Zero-Trust Model** ka bunyadi usool hai:
> *"Network location (internal ya external) par bharosa na karein. Har request ko authenticate, authorize, aur encrypt hona chahiye."*

```
Traditional Model:
[ Internet ] ─── (Firewall / VPN) ───► [ Internal Network: Sab trusted hai 🔓 ]

Zero-Trust Model:
[ Any Client ] ─── (Identity Check + Device Posture + mTLS) ───► [ Specific Service Only 🔒 ]
```

### Core Principles of Zero-Trust:
1. **Identity-Aware Access (BeyondCorp / ZTNA):** IP address ke bajaye user identity (SSO, MFA) aur machine health ki bunyad par access milta hai.
2. **Mutual TLS (mTLS):** Services sirf client ko verify nahi karti, balki internal microservices bhi ek doosre ke sath mTLS ke zariye certificates verify karke encrypted baat karti hain (e.g., Istio/Linkerd service mesh).
3. **Least Privilege Access:** Har service aur developer ko sirf usi database ya API ka access milta hai jo uske kaam ke liye laazmi ho.
4. **Micro-segmentation:** Network ko chhotay chhotay isolated zones mein divide karna taake agar ek container hack ho bhi jaye toh attacker baaqi servers tak na pohnch sake.

---

**Status:** ✅ Complete