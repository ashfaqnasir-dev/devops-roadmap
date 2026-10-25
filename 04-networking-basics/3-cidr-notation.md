# 🔢 CIDR Notation — Complete Guide

> CIDR = Batata hai ke kitne IPs ek network mein hain.

---

## 📚 Table of Contents

1. [CIDR Kya Hai?](#cidr-kya-hai)
2. [IP Address Structure](#ip-address-structure)
3. [Prefix Length](#prefix-length)
4. [Hosts Calculation](#hosts-calculation)
5. [Complete CIDR Table](#complete-cidr-table)
6. [Subnet Mask](#subnet-mask)
7. [Practical Examples](#practical-examples)
8. [Subnetting](#subnetting)
9. [Real-World Mapping](#real-world-mapping)
10. [Commands](#commands)

---

## CIDR Kya Hai?

**CIDR** = **C**lassless **I**nter-**D**omain **R**outing

**CIDR Notation** = **Batata hai** ke **kitne IPs** ek network mein hain.

### Kahani

Socho aap ek society bana rahe hain:

| Society | Network |
|---|---|
| Society ka naam | Network |
| Plot numbers | IP addresses |
| Kitne plots | CIDR range |
| Boundary wall | Subnet mask |

### Structure

```
192.168.1.0/24
└─────┬────┘ └┬┘
      │       │
      │       └── Prefix length
      └────────── Network address
```

---

## IP Address Structure

### IPv4 = 32 bits

```
192  .  168  .  1  .  0
└┬┘    └┬┘    └┬┘   └┬┘
8 bits  8     8     8  = 32 bits
```

### Binary Representation

```
192.168.1.0
=
11000000.10101000.00000001.00000000
└────────┬────────┘└──────┬──────┘
      Network           Host
```

---

## Prefix Length

### Kaise Kaam Karta Hai?

**`/24`** = **24 bits network** + **8 bits host**

```
11000000.10101000.00000001.00000000
└──────── Network 24 ────────┘└Host 8┘
```

**`/16`** = **16 bits network** + **16 bits host**

```
11000000.10101000.00000000.00000000
└── Network 16 ──┘└────── Host 16 ───┘
```

**`/8`** = **8 bits network** + **24 bits host**

```
11000000.00000000.00000000.00000000
└Network 8┘└─────── Host 24 ───────┘
```

### Summary

| CIDR | Network Bits | Host Bits |
|---|---|---|
| /8 | 8 | 24 |
| /16 | 16 | 16 |
| /24 | 24 | 8 |
| /25 | 25 | 7 |
| /26 | 26 | 6 |
| /30 | 30 | 2 |
| /32 | 32 | 0 |

---

## Hosts Calculation

### Formula

```
Hosts = 2^(32 - prefix) - 2
```

**Kyun -2?**

- Network address — use nahi hota
- Broadcast address — use nahi hota

### Examples

**/24:**

```
Host bits = 32 - 24 = 8
Hosts = 2^8 - 2 = 256 - 2 = 254
```

**/25:**

```
Host bits = 32 - 25 = 7
Hosts = 2^7 - 2 = 128 - 2 = 126
```

**/26:**

```
Host bits = 32 - 26 = 6
Hosts = 2^6 - 2 = 64 - 2 = 62
```

**/27:**

```
Host bits = 32 - 27 = 5
Hosts = 2^5 - 2 = 32 - 2 = 30
```

**/30:**

```
Host bits = 32 - 30 = 2
Hosts = 2^2 - 2 = 4 - 2 = 2
```

**/32:**

```
Host bits = 0
Hosts = 1 (single IP)
```

---

## Complete CIDR Table

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|---|---|---|---|
| /8 | 255.0.0.0 | 16,777,216 | 16,777,214 |
| /16 | 255.255.0.0 | 65,536 | 65,534 |
| /20 | 255.255.240.0 | 4,096 | 4,094 |
| /22 | 255.255.252.0 | 1,024 | 1,022 |
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |
| /31 | 255.255.255.254 | 2 | 2 (P2P) |
| /32 | 255.255.255.255 | 1 | 1 |

---

## Subnet Mask

### CIDR to Subnet Mask

**/24:**

```
24 bits 1s, 8 bits 0s
= 11111111.11111111.11111111.00000000
= 255.255.255.0
```

**/26:**

```
26 bits 1s, 6 bits 0s
= 11111111.11111111.11111111.11000000
= 255.255.255.192
```

### Conversion Table

| CIDR | Binary (last octet) | Decimal |
|---|---|---|
| /24 | 00000000 | 0 |
| /25 | 10000000 | 128 |
| /26 | 11000000 | 192 |
| /27 | 11100000 | 224 |
| /28 | 11110000 | 240 |
| /29 | 11111000 | 248 |
| /30 | 11111100 | 252 |
| /31 | 11111110 | 254 |
| /32 | 11111111 | 255 |

---

## Practical Examples

### Example: 192.168.1.0/24

**Structure:**

```
Network:   192.168.1.0
Broadcast: 192.168.1.255
First IP:  192.168.1.1
Last IP:   192.168.1.254
Total:     256
Usable:    254
```

**Binary:**

```
Network:   11000000.10101000.00000001.00000000
Mask:      11111111.11111111.11111111.00000000
           └──────── Network ────────┘└─ Host ─┘
```

**IP Range:**

| IP | Kya |
|---|---|
| 192.168.1.0 | Network address |
| 192.168.1.1 | First host |
| 192.168.1.2 | Second host |
| ... | ... |
| 192.168.1.254 | Last host |
| 192.168.1.255 | Broadcast |

---

## Subnetting

### Kya Hai?

**Subnetting** = Bara network ko chhote networks mein todna.

### Example: 4 Subnets

**Problem:**

`192.168.1.0/24` ko 4 subnets mein todna hai.

**Solution:**

```
4 subnets = 2^2
→ 2 bits borrow karo
→ /24 + 2 = /26
```

**Result:**

| Subnet | Network | Range | Broadcast |
|---|---|---|---|
| 1 | 192.168.1.0/26 | .1 - .62 | .63 |
| 2 | 192.168.1.64/26 | .65 - .126 | .127 |
| 3 | 192.168.1.128/26 | .129 - .190 | .191 |
| 4 | 192.168.1.192/26 | .193 - .254 | .255 |

**Har subnet:** 62 usable hosts.

### Subnetting Formula

```
Subnets = 2^n
Hosts per subnet = 2^(32 - new_prefix) - 2
```

---

## Real-World Mapping

### AWS VPC

```
VPC:    10.0.0.0/16      (65,536 IPs)
Subnet: 10.0.1.0/24      (256 IPs, public)
Subnet: 10.0.2.0/24      (256 IPs, private)
```

### Aap Ka EC2

```
Private IP: 172.31.30.41
VPC:        172.31.0.0/16
Subnet:     172.31.30.0/20
```

### Docker

```
Bridge network: 172.17.0.0/16
Container:      172.17.0.2
```

### Home Network

```
Router:   192.168.1.1/24
Laptop:   192.168.1.10
Phone:    192.168.1.11
```

---

## Commands

### Aap Ka IP

```bash
ip addr show | grep inet
```

### Aap Ka Network

```bash
ip route
```

### AWS VPC CIDR

```bash
aws ec2 describe-vpcs \
  --query "Vpcs[].{ID:VpcId,CIDR:CidrBlock}"
```

### AWS Subnet CIDR

```bash
aws ec2 describe-subnets \
  --query "Subnets[].{ID:SubnetId,CIDR:CidrBlock}"
```

### Docker Networks

```bash
docker network ls
docker network inspect bridge | grep Subnet
```

### CIDR Calculator (Linux)

```bash
sudo apt install ipcalc
ipcalc 192.168.1.0/24
```

Output:

```
Address:   192.168.1.0
Netmask:   255.255.255.0 = 24
Network:   192.168.1.0/24
HostMin:   192.168.1.1
HostMax:   192.168.1.254
Broadcast: 192.168.1.255
Hosts/Net: 254
```

---

## Quick Reference

### Common CIDR Blocks

| CIDR | Use Case |
|---|---|
| /8 | Very large network |
| /16 | Large network (AWS VPC) |
| /20 | Medium subnet |
| /24 | Small network (home) |
| /26 | Small subnet |
| /30 | Point-to-point link |
| /32 | Single host |

### Private IP Ranges

| Range | CIDR | Size |
|---|---|---|
| 10.0.0.0 - 10.255.255.255 | 10.0.0.0/8 | 16M |
| 172.16.0.0 - 172.31.255.255 | 172.16.0.0/12 | 1M |
| 192.168.0.0 - 192.168.255.255 | 192.168.0.0/16 | 65K |

---

## Checklist

- [ ] CIDR notation clear
- [ ] Prefix length samjha
- [ ] Hosts calculation yaad
- [ ] Subnet mask convert kar sakte
- [ ] Subnetting basics
- [ ] Real-world examples
- [ ] Commands run

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
