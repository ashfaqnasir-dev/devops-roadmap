# 🌐 04.03 DNS — Complete Guide

> **DNS (Domain Name System)** internet ki "Phonebook" hai. Insaan `google.com` ya `api.devops.internal` jaise aasan alfaz yaad rakhte hain, jabke computers sirf numeric IP addresses (`142.250.190.46` ya `2607:f8b0:...`) samajhte hain. DNS domain names ko unke mutalliqah IP addresses mein translate karta hai.

---

## 1. DNS Resolution (Step-by-Step Hierarchy)

Jab aap browser ya terminal mein `www.example.com` request karte hain aur local cache mein answer na ho, toh recursive resolution ka process shuru hota hai:

```
[ Browser / Client ]
         │ (1. Query: "www.example.com ka IP kya hai?")
         ▼
[ Recursive Resolver / ISP / 8.8.8.8 ]
         │
         ├── (2. Query) ──> [ Root DNS Server ( . ) ]
         │ <── (3. Answer: ".com TLD server ke paas jao")
         │
         ├── (4. Query) ──> [ TLD DNS Server ( .com ) ]
         │ <── (5. Answer: "example.com Authoritative Server ke paas jao")
         │
         └── (6. Query) ──> [ Authoritative DNS Server (e.g. Route 53 / Cloudflare) ]
           <── (7. Final Answer: "IP hai 93.184.216.34")
         │
         ▼
[ Recursive Resolver caches answer & returns to Client ]
```

### Hierarchy Breakdown:
1. **Local DNS Cache / Hosts File:** Pehle machine apni memory (`/etc/hosts` ya local cache) check karti hai.
2. **Recursive Resolver (ISP / Public DNS):** Aapka ISP ya public resolver (Google `8.8.8.8`, Cloudflare `1.1.1.1`).
3. **Root Nameservers (`.`):** Internet par total 13 named root authority systems hain jo specific TLD servers ka pata dete hain.
4. **TLD Nameservers (Top-Level Domain):** Extensions handle karte hain (jaise `.com`, `.org`, `.io`, `.pk`).
5. **Authoritative Nameservers:** Final official server jahan domain registrar ya DNS provider (AWS Route 53, Cloudflare) original records store karta hai.

---

## 2. DNS Record Types

DNS zone file mein mukhtalif maqasid ke liye alag alag records hote hain:

| Record Type | Purpose | Example Value | Use Case |
| :--- | :--- | :--- | :--- |
| **`A`** | Hostname ko **IPv4** address se map karta hai | `example.com. -> 93.184.216.34` | Web server ya load balancer ka public IPv4 link karna |
| **`AAAA`** (Quad-A) | Hostname ko **IPv6** address se map karta hai | `example.com. -> 2606:2800:220:1:...` | Modern IPv6 traffic route karna |
| **`CNAME`** (Canonical Name) | Hostname ko **dusre domain name** ka alias banata hai | `www.example.com. -> example.com.` | Subdomain ko main domain ya external CDN/ELB par point karna |
| **`MX`** (Mail Exchange) | Email deliver karne wale mail servers point karta hai | `10 mail.google.com.` (Priority + Server) | Company emails (e.g., Google Workspace) route karna |
| **`TXT`** | Plain text metadata store karta hai | `"v=spf1 include:_spf.google.com ~all"` | Domain ownership verification, SPF, DKIM, DMARC |
| **`NS`** (Name Server) | Batata hai is domain ke authoritative servers kaunse hain | `ns1.cloudflare.com.` | Domain delegation |
| **`PTR`** (Pointer) | Reverse DNS lookup (IP to Hostname) | `34.216.184.93.in-addr.arpa -> example.com` | Spam filter verification (Mail servers) |

> ⚠️ **Important CNAME Rule:** DNS RFC ke mutabiq apex/root domain (`example.com`) par direct CNAME record nahi banaya ja sakta; root domain par hamesha `A`/`AAAA` ya cloud-specific Alias record lagta hai.

---

## 3. DNS Troubleshooting Tools (`dig`, `nslookup`)

DevOps aur cloud engineers ke liye network issues debug karne ke do aham commands:

### A. `dig` (Domain Information Groper — Standard Tool)
`dig` zyada fast, informative aur authentic response return karta hai.

```bash
# Basic lookup (A record)
dig example.com

# Short clean answer (sirf IP print kare)
dig example.com +short

# Specific record type check karna
dig example.com MX +short
dig example.com TXT +short

# Specific DNS resolver force karna (e.g., Cloudflare 1.1.1.1 se poocho)
dig @1.1.1.1 example.com +short

# Reverse DNS lookup (IP to Name)
dig -x 93.184.216.34 +short

# Complete resolution path trace karna (Root se Authoritative tak)
dig example.com +trace
```

### B. `nslookup` (Name Server Lookup — Interactive & Simple)
Cross-platform utility jo fast testing ke liye use hoti hai.

```bash
# Simple lookup
nslookup example.com

# Specific resolver aur specific record type
nslookup -type=MX example.com 8.8.8.8
```

---

## 4. DNS in Cloud & Kubernetes

Modern cloud infrastructure mein DNS sirf internet browse karne ke liye nahi, balki internal service discovery aur traffic routing ke liye use hota hai.

### A. Cloud DNS Services (AWS Route 53, Google Cloud DNS)
1. **Public Hosted Zones:** Public domains ko internet par resolve karne ke liye.
2. **Private Hosted Zones:** Corporate VPC ke andar internal VMs aur databases ke liye private names (e.g., `db.internal.production`). Yeh public internet par expose nahi hote.
3. **Alias Records (AWS Specific):** AWS Route 53 ka feature jo root domain (`example.com`) ko dynamic CloudFront ya ALB (Application Load Balancer) DNS name ke sath point karta hai bina CNAME restriction break kiye.
4. **Routing Policies:**
   * **Latency-based:** User ko sabse qaribi region ka IP dena.
   * **Geolocation:** Country ya continent ke mutabiq traffic bhejna.
   * **Failover / Health Checks:** Agar primary server down ho toh automatically backup IP par shift karna.

### B. Kubernetes Internal DNS (CoreDNS)
Cluster ke andar containers (Pods) ek dusre se IP ke bajaye cluster-local DNS ke zariye connect hote hain:

```
<service-name>.<namespace>.svc.cluster.local
```

* *Example:* `auth-service.production.svc.cluster.local`
* Agar same namespace mein hon toh sirf `http://auth-service:8080` likh kar direct connect kiya ja sakta hai.

---

**Status:** ✅ Complete