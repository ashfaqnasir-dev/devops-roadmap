# 🌐 OSI Model — Complete Guide

> OSI Model = 7 layers jo network communication ko define karti hain.

---

## 📚 Table of Contents

1. [OSI Model Kya Hai?](#osi-model-kya-hai)
2. [7 Layers](#7-layers)
3. [Layer Functions](#layer-functions)
4. [Protocols Per Layer](#protocols-per-layer)
5. [Real-World Mapping](#real-world-mapping)
6. [OSI vs TCP/IP](#osi-vs-tcpip)

---

## OSI Model Kya Hai?

**OSI** = **O**pen **S**ystems **I**nterconnection

**OSI Model** = **7 layers** jo batati hain ke **network communication kaise hoti hai** — ek layer se doosri layer tak.

**Analogy:** Parcel bhejna — packing, address, courier, transport, delivery.

---

## 7 Layers

### Structure (Upar Se Neeche)

```
┌─────────────────────────────────┐
│ 7. Application                  │  ← User
├─────────────────────────────────┤
│ 6. Presentation                 │  ← Data format
├─────────────────────────────────┤
│ 5. Session                      │  ← Connection
├─────────────────────────────────┤
│ 4. Transport                    │  ← Delivery
├─────────────────────────────────┤
│ 3. Network                      │  ← Routing
├─────────────────────────────────┤
│ 2. Data Link                    │  ← Frames
├─────────────────────────────────┤
│ 1. Physical                     │  ← Cables
└─────────────────────────────────┘
```

### Mnemonic (Yaad Rakhne Ka Tareeqa)

**English (Upar Se Neeche):**

```
All People Seem To Need Data Processing
 A     P      S    T    N     D      P
```

**English (Neeche Se Upar):**

```
Please Do Not Throw Sausage Pizza Away
  P     D    N   T     S     P    A
```

### Layers Ki List

| # | Layer | Kya |
|---|---|---|
| 7 | Application | User interface |
| 6 | Presentation | Data format |
| 5 | Session | Connection |
| 4 | Transport | End-to-end |
| 3 | Network | Routing |
| 2 | Data Link | Frames |
| 1 | Physical | Signals |

---

## Layer Functions

### Layer 7: Application

**Kaam:** User **interface** — direct interaction.

**Examples:**
- Web browser
- Email client
- File transfer

**Data Unit:** Data

### Layer 6: Presentation

**Kaam:** Data **format** — encryption, compression.

**Examples:**
- SSL/TLS encryption
- JPEG, MP3
- ASCII, Unicode

**Data Unit:** Data

### Layer 5: Session

**Kaam:** **Connection** manage — start, maintain, end.

**Examples:**
- Login sessions
- API sessions

**Data Unit:** Data

### Layer 4: Transport

**Kaam:** **End-to-end** delivery.

**Protocols:**
- TCP — Reliable
- UDP — Fast

**Data Unit:** Segment (TCP) / Datagram (UDP)

### Layer 3: Network

**Kaam:** **Routing** — packet ka rasta.

**Protocols:**
- IP — Internet Protocol
- ICMP — Ping
- OSPF — Routing

**Data Unit:** Packet

### Layer 2: Data Link

**Kaam:** **Frames** — local delivery.

**Protocols:**
- Ethernet
- WiFi (802.11)
- MAC addresses

**Data Unit:** Frame

### Layer 1: Physical

**Kaam:** **Signals** — electrical, optical.

**Examples:**
- Cables (Ethernet, fiber)
- Hubs
- Radio waves

**Data Unit:** Bits

---

## Protocols Per Layer

| # | Layer | Protocols | Data Unit |
|---|---|---|---|
| 7 | Application | HTTP, HTTPS, FTP, SMTP, DNS, SSH | Data |
| 6 | Presentation | SSL/TLS, JPEG, MPEG, ASCII | Data |
| 5 | Session | NetBIOS, RPC, PPTP | Data |
| 4 | Transport | TCP, UDP | Segment |
| 3 | Network | IP, ICMP, ARP, OSPF, BGP | Packet |
| 2 | Data Link | Ethernet, WiFi, MAC, PPP | Frame |
| 1 | Physical | Ethernet cable, Fiber, Radio | Bits |

### Important Protocols

**Layer 7 (Application):**

| Protocol | Port | Kya |
|---|---|---|
| HTTP | 80 | Web |
| HTTPS | 443 | Secure web |
| FTP | 21 | File transfer |
| SSH | 22 | Remote access |
| DNS | 53 | Domain resolution |
| SMTP | 25 | Email send |
| IMAP | 143 | Email receive |

**Layer 4 (Transport):**

| Protocol | Kya |
|---|---|
| TCP | Reliable, ordered |
| UDP | Fast, no guarantee |

**Layer 3 (Network):**

| Protocol | Kya |
|---|---|
| IP | Addressing |
| ICMP | Ping/traceroute |
| ARP | IP → MAC |

---

## Real-World Mapping

### Scenario 1: Google Kholein

```
Layer 7: Application  → Chrome → google.com (HTTPS)
Layer 6: Presentation → TLS encryption
Layer 5: Session      → Session with Google server
Layer 4: Transport    → TCP connection
Layer 3: Network      → IP routing
Layer 2: Data Link    → WiFi/Ethernet frame
Layer 1: Physical     → Signals (cable/WiFi)
```

### Scenario 2: Ping Chalayein

```bash
ping google.com
```

| Layer | Kya |
|---|---|
| 7. Application | ping command |
| 4. Transport | ICMP (no port) |
| 3. Network | IP packet |
| 2. Data Link | Ethernet frame |
| 1. Physical | Cable/WiFi signals |

### Scenario 3: SSH EC2 Par

```bash
ssh -i key.pem ec2-user@3.26.97.163
```

| Layer | Kya |
|---|---|
| 7. Application | SSH client |
| 6. Presentation | Encryption |
| 5. Session | SSH session |
| 4. Transport | TCP port 22 |
| 3. Network | IP: 3.26.97.163 |
| 2. Data Link | Ethernet/WiFi |
| 1. Physical | Internet cables |

### Scenario 4: Docker Container

```bash
docker run -d -p 8080:80 nginx
```

| Layer | Kya |
|---|---|
| 7. Application | HTTP request |
| 4. Transport | TCP 8080 → 80 |
| 3. Network | Container IP |
| 2. Data Link | Docker bridge |
| 1. Physical | Host machine |

---

## OSI vs TCP/IP

### Comparison

| OSI (7 layers) | TCP/IP (4 layers) |
|---|---|
| 7. Application | |
| 6. Presentation | Application |
| 5. Session | |
| 4. Transport | Transport |
| 3. Network | Internet |
| 2. Data Link | Network Access |
| 1. Physical | |

**TCP/IP** — simpler, real-world model.

---

## Practical Commands

### Layer 7 — HTTP

```bash
curl -I https://google.com
```

### Layer 4 — TCP

```bash
netstat -tlnp | head -5
```

### Layer 3 — IP Routing

```bash
ip route
```

### Layer 3 — Ping (ICMP)

```bash
ping -c 3 google.com
```

### Layer 2 — MAC Addresses

```bash
ip link show
```

### Layer 1 — Network Interface

```bash
ip addr show | head -20
```

### DNS (Application Layer)

```bash
nslookup google.com
```

---

## Checklist

- [ ] 7 layers yaad
- [ ] Layer functions clear
- [ ] Protocols per layer
- [ ] Real-world mapping
- [ ] OSI vs TCP/IP
- [ ] Practical commands run

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
