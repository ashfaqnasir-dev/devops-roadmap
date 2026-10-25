# 🌐 TCP/IP — Complete Guide

> TCP/IP = Internet ka foundation protocol suite.

---

## 📚 Table of Contents

1. [TCP/IP Kya Hai?](#tcpip-kya-hai)
2. [TCP vs UDP](#tcp-vs-udp)
3. [IP Addressing](#ip-addressing)
4. [Subnetting](#subnetting)
5. [Ports & Sockets](#ports--sockets)
6. [Three-Way Handshake](#three-way-handshake)

---

## TCP/IP Kya Hai?

**TCP/IP** = **Transmission Control Protocol / Internet Protocol**

**Yeh** internet ka **foundation** hai — har website, email, video call isi par chalti hai.

### TCP/IP Model (4 Layers)

```
┌─────────────────────────────────┐
│ 4. Application                  │  ← HTTP, DNS, SSH
├─────────────────────────────────┤
│ 3. Transport                    │  ← TCP, UDP
├─────────────────────────────────┤
│ 2. Internet                     │  ← IP, ICMP
├─────────────────────────────────┤
│ 1. Network Access               │  ← Ethernet, WiFi
└─────────────────────────────────┘
```

### OSI vs TCP/IP

| OSI (7 layers) | TCP/IP (4 layers) |
|---|---|
| 7. Application | Application |
| 6. Presentation | |
| 5. Session | |
| 4. Transport | Transport |
| 3. Network | Internet |
| 2. Data Link | Network Access |
| 1. Physical | |

---

## TCP vs UDP

### TCP — Transmission Control Protocol

**Kya:** Reliable, ordered delivery.

**Features:**
- Connection-oriented
- Reliable (acknowledgment)
- Ordered delivery
- Error checking
- Flow control

**Use Cases:**
- Web (HTTP/HTTPS)
- Email (SMTP, IMAP)
- File transfer (FTP)
- SSH

**Analogy:** Registered mail — delivery guaranteed.

### UDP — User Datagram Protocol

**Kya:** Fast, no guarantee.

**Features:**
- Connectionless
- Unreliable (no ACK)
- No ordering
- Fast
- Lightweight

**Use Cases:**
- Video streaming
- Online gaming
- DNS
- VoIP

**Analogy:** Postcard — fast, but no guarantee.

### Comparison Table

| Feature | TCP | UDP |
|---|---|---|
| Connection | Yes | No |
| Reliability | High | Low |
| Speed | Slow | Fast |
| Ordering | Yes | No |
| Header Size | 20 bytes | 8 bytes |
| Use Case | Web, Email | Streaming, Gaming |

---

## IP Addressing

### IPv4

**Format:** 4 octets, dot-separated

```
192.168.1.1
```

**Range:** 0.0.0.0 to 255.255.255.255

**Total addresses:** ~4.3 billion (2^32)

**Example:**
- `192.168.1.1` — Private
- `8.8.8.8` — Public (Google DNS)

### IPv4 Classes

| Class | Range | Use |
|---|---|---|
| A | 1.0.0.0 - 126.255.255.255 | Large networks |
| B | 128.0.0.0 - 191.255.255.255 | Medium |
| C | 192.0.0.0 - 223.255.255.255 | Small |
| D | 224.0.0.0 - 239.255.255.255 | Multicast |
| E | 240.0.0.0 - 255.255.255.255 | Experimental |

### Private IP Ranges

| Range | CIDR | Use |
|---|---|---|
| 10.0.0.0 - 10.255.255.255 | 10.0.0.0/8 | Large private |
| 172.16.0.0 - 172.31.255.255 | 172.16.0.0/12 | Medium private |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | Home networks |

**Aap Ka EC2:**
- Private IP: `172.31.30.41`
- Public IP: `3.26.97.163`

### IPv6

**Format:** 8 groups of 4 hex digits

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

**Total addresses:** ~340 undecillion (2^128)

**Fayde:**
- Unlimited addresses
- Better security
- No NAT needed

### IPv4 vs IPv6

| Feature | IPv4 | IPv6 |
|---|---|---|
| Size | 32-bit | 128-bit |
| Format | 192.168.1.1 | 2001:db8::1 |
| Addresses | ~4.3B | ~340 undecillion |
| NAT | Required | Not needed |

---

## Subnetting

### Kya Hai?

**Subnetting** = **Bara network** ko **chhote networks** mein todna.

**Kyun:**
- Better management
- Security
- Less broadcast traffic

### CIDR Notation

```
192.168.1.0/24
            ↑
        Prefix length
```

| CIDR | Subnet Mask | Hosts |
|---|---|---|
| /24 | 255.255.255.0 | 254 |
| /25 | 255.255.255.128 | 126 |
| /26 | 255.255.255.192 | 62 |
| /27 | 255.255.255.224 | 30 |
| /28 | 255.255.255.240 | 14 |
| /30 | 255.255.255.252 | 2 |
| /32 | 255.255.255.255 | 1 |

### Example

**Network:** `192.168.1.0/24`

| Address | Kya |
|---|---|
| 192.168.1.0 | Network address |
| 192.168.1.1 | First host |
| 192.168.1.254 | Last host |
| 192.168.1.255 | Broadcast |

### Formula

```
Hosts = 2^(32 - prefix) - 2
```

**Example /24:**
```
2^(32-24) - 2 = 2^8 - 2 = 256 - 2 = 254 hosts
```

---

## Ports & Sockets

### Port Kya Hai?

**Port** = **Number** jo service identify karta hai.

**Range:** 0 - 65535

### Port Categories

| Range | Category |
|---|---|
| 0 - 1023 | Well-known ports |
| 1024 - 49151 | Registered ports |
| 49152 - 65535 | Dynamic/Private |

### Common Ports

| Port | Service |
|---|---|
| 20, 21 | FTP |
| 22 | SSH |
| 23 | Telnet |
| 25 | SMTP |
| 53 | DNS |
| 80 | HTTP |
| 110 | POP3 |
| 143 | IMAP |
| 443 | HTTPS |
| 3306 | MySQL |
| 5432 | PostgreSQL |
| 6379 | Redis |
| 8080 | HTTP Alt |
| 27017 | MongoDB |

### Socket Kya Hai?

**Socket** = **IP + Port** combination

```
192.168.1.1:80
└─────┬────┘ └┬┘
      IP      Port
```

**Example:**
- Server: `3.26.97.163:80`
- Client: `192.168.1.5:54321`

### Socket States

```bash
netstat -an | head -10
```

| State | Meaning |
|---|---|
| LISTEN | Waiting for connection |
| ESTABLISHED | Active connection |
| TIME_WAIT | Closing |
| CLOSE_WAIT | Remote closed |

---

## Three-Way Handshake

### Kya Hai?

**TCP connection** banane ka **3-step process**.

### Steps

```
Client                    Server
  │                         │
  │────── SYN ─────────────►│  1. Client: "Connect karna hai"
  │                         │
  │◄───── SYN-ACK ──────────│  2. Server: "Theek, main ready"
  │                         │
  │────── ACK ─────────────►│  3. Client: "Confirmed"
  │                         │
  │◄═════ CONNECTED ════════│  Connection established
```

### Detail

| # | Step | Kya |
|---|---|---|
| 1 | **SYN** | Client sends synchronize |
| 2 | **SYN-ACK** | Server sends sync + ack |
| 3 | **ACK** | Client sends acknowledgment |

### Analogy

**Phone call:**
1. Aap: "Hello?" (SYN)
2. Doosra: "Hello, sun raha hoon" (SYN-ACK)
3. Aap: "Achha, baat karte hain" (ACK)

### Four-Way Termination

**Connection band karne ke liye 4 steps:**

```
Client                    Server
  │────── FIN ─────────────►│  1. Client: "Band karna hai"
  │◄───── ACK ──────────────│  2. Server: "Theek"
  │◄───── FIN ──────────────│  3. Server: "Main bhi band"
  │────── ACK ─────────────►│  4. Client: "Confirmed"
```

---

## Practical Commands

### TCP Connections

```bash
# Active connections
netstat -tlnp

# Or
ss -tlnp
```

### UDP Connections

```bash
netstat -ulnp
```

### Specific Port

```bash
netstat -tlnp | grep :80
```

### Ping (ICMP)

```bash
ping -c 3 google.com
```

### Traceroute

```bash
traceroute google.com
```

### DNS Lookup

```bash
nslookup google.com
dig google.com
```

### Three-Way Handshake Capture

```bash
sudo tcpdump -i any -c 10 'tcp[tcpflags] & (tcp-syn|tcp-ack) != 0'
```

---

## Checklist

- [ ] TCP vs UDP clear
- [ ] IPv4 vs IPv6 clear
- [ ] Subnetting basics
- [ ] Ports aur common services
- [ ] Socket concept
- [ ] Three-way handshake
- [ ] Practical commands run

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
