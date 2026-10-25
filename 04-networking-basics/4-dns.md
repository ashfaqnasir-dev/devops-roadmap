# 🌐 DNS — Domain Name System

> DNS = Internet ka phonebook — domain names ko IP addresses mein convert karta hai.

---

## 📚 Table of Contents

1. [DNS Kya Hai?](#dns-kya-hai)
2. [How DNS Works](#how-dns-works)
3. [Record Types](#record-types)
4. [DNS Tools](#dns-tools)
5. [DNS in Cloud](#dns-in-cloud)
6. [Commands](#commands)

---

## DNS Kya Hai?

**DNS** = **D**omain **N**ame **S**ystem

**DNS** = **Phonebook** — domain names (google.com) ko IP addresses (142.250.x.x) mein convert karta hai.

### Kahani

Aap ko **Ahmed** ka ghar dhoondhna hai:
- **Naam:** Ahmed
- **Address:** House 5, Street 10, Karachi

**DNS mein:**
- **Naam:** google.com
- **Address:** 142.250.4.100

**Aap naam yaad rakhte hain** — DNS **address** dhoondh deta hai.

---

## How DNS Works

### Step-by-Step

```
1. Aap browser mein type karein: google.com
          ↓
2. Browser → DNS Resolver (ISP ya 8.8.8.8)
          ↓
3. Resolver → Root Server
   "google.com ka IP kya hai?"
          ↓
4. Root → TLD Server (.com)
   "google.com ke liye .com server poochho"
          ↓
5. TLD → Authoritative Server
   "google.com ka IP: 142.250.4.100"
          ↓
6. Resolver → Browser
   "IP: 142.250.4.100"
          ↓
7. Browser → Google server
   "Page bhejo"
```

### Caching

**DNS results cache hote hain** — dobara poochhna nahi parta.

| Level | Cache Time |
|---|---|
| Browser | Minutes |
| OS | Minutes |
| Resolver | Hours |
| TTL | Configurable |

---

## Record Types

| Type | Kya | Example |
|---|---|---|
| **A** | IPv4 address | google.com → 142.250.4.100 |
| **AAAA** | IPv6 address | google.com → 2607:f8b0:: |
| **CNAME** | Alias | www → example.com |
| **MX** | Mail server | mail.example.com |
| **TXT** | Text data | Verification |
| **NS** | Nameserver | ns1.example.com |
| **SOA** | Start of Authority | Zone info |
| **PTR** | Reverse DNS | IP → domain |

### Examples

**A Record:**

```
google.com     A     142.250.4.100
```

**CNAME:**

```
www.example.com    CNAME    example.com
```

**MX:**

```
example.com    MX    10 mail.example.com
```

---

## DNS Tools

### `nslookup`

```bash
nslookup google.com
```

Output:

```
Server:    8.8.8.8
Address:   8.8.8.8#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.4.100
```

### `dig`

```bash
dig google.com
```

Output:

```
; <<>> DiG <<>> google.com
;; ANSWER SECTION:
google.com.    300    IN    A    142.250.4.100
```

### `host`

```bash
host google.com
```

---

## DNS in Cloud

### AWS Route 53

- **Managed DNS** service
- **Domain registration**
- **Health checks**
- **Routing policies:**
  - Simple
  - Weighted
  - Latency-based
  - Failover
  - Geolocation

### Azure DNS

- **Managed DNS** service
- **Public + Private zones**
- **Alias records**

### Cloudflare DNS

- **Free DNS**
- **Fast** (1.1.1.1)
- **DDoS protection**

---

## Commands

### Lookup

```bash
nslookup google.com
dig google.com
host google.com
```

### Specific Record

```bash
dig google.com MX
dig google.com AAAA
dig google.com NS
```

### Reverse Lookup

```bash
dig -x 8.8.8.8
```

### Trace

```bash
dig +trace google.com
```

### DNS Server Check

```bash
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com
```

---

## Checklist

- [ ] DNS concept clear
- [ ] Record types yaad
- [ ] `nslookup` use kiya
- [ ] `dig` use kiya
- [ ] Cloud DNS samjha

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
