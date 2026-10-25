# 🌐 Firewalls — Complete Guide

> Firewall = Network ka security guard — traffic ko filter karta hai.

---

## 📚 Table of Contents

1. [Firewall Kya Hai?](#firewall-kya-hai)
2. [Types of Firewalls](#types-of-firewalls)
3. [Security Groups (AWS)](#security-groups-aws)
4. [iptables](#iptables)
5. [UFW](#ufw)
6. [Best Practices](#best-practices)
7. [Commands](#commands)

---

## Firewall Kya Hai?

**Firewall** = **Security guard** — network traffic ko **rules ke hisaab se** allow/block karta hai.

### Kahani

**Ghar ka guard:**
- **Kaun andar aa sakta** — whitelist
- **Kaun nahi** — blacklist
- **Rules** — time, ID, purpose

**Firewall** = **Network ka guard**.

### Types

| Type | Kya |
|---|---|
| **Inbound** | Andar aane wala |
| **Outbound** | Bahar jaane wala |

---

## Types of Firewalls

### 1. Packet Filtering

**Kya:** IP + Port ke basis par.

**Layer:** 3-4.

**Example:** iptables.

### 2. Stateful Inspection

**Kya:** Connection state track karta hai.

**Layer:** 4.

**Example:** AWS Security Groups.

### 3. Application Layer

**Kya:** Application data inspect.

**Layer:** 7.

**Example:** WAF (Web Application Firewall).

### 4. Next-Gen Firewall (NGFW)

**Kya:** Sab kuch + AI/ML.

**Example:** Palo Alto, Fortinet.

---

## Security Groups (AWS)

### Kya Hai?

**Security Group** = **Virtual firewall** — EC2 instance ke liye.

### Rules

| Type | Port | Source | Purpose |
|---|---|---|---|
| SSH | 22 | My IP | Remote access |
| HTTP | 80 | 0.0.0.0/0 | Web |
| HTTPS | 443 | 0.0.0.0/0 | Secure web |
| Custom | 5000 | 0.0.0.0/0 | Flask app |

### Characteristics

- **Stateful** — inbound allow → outbound auto-allow
- **Whitelist** — sirf allowed traffic
- **Default:** Inbound block, Outbound allow

### Commands (AWS CLI)

```bash
# List security groups
aws ec2 describe-security-groups \
  --query "SecurityGroups[].{ID:GroupId,Name:GroupName}"

# Add rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0

# Remove rule
aws ec2 revoke-security-group-ingress \
  --group-id sg-xxxxx \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

---

## iptables

### Kya Hai?

**iptables** = Linux ka **built-in firewall**.

### Tables

| Table | Purpose |
|---|---|
| **filter** | Allow/block |
| **nat** | NAT |
| **mangle** | Packet modify |
| **raw** | Connection tracking |

### Chains

| Chain | Kya |
|---|---|
| **INPUT** | Incoming |
| **OUTPUT** | Outgoing |
| **FORWARD** | Routing |

### Common Commands

```bash
# List rules
sudo iptables -L -n -v

# Allow SSH
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Block IP
sudo iptables -A INPUT -s 192.168.1.100 -j DROP

# Delete rule
sudo iptables -D INPUT -p tcp --dport 80 -j ACCEPT

# Save rules
sudo iptables-save > /etc/iptables/rules.v4
```

---

## UFW

### Kya Hai?

**UFW** = **Uncomplicated Firewall** — iptables ka aasan wrapper.

### Commands

```bash
# Status
sudo ufw status

# Enable
sudo ufw enable

# Disable
sudo ufw disable

# Allow SSH
sudo ufw allow 22

# Allow HTTP
sudo ufw allow 80

# Allow HTTPS
sudo ufw allow 443

# Allow specific IP
sudo ufw allow from 192.168.1.100

# Deny
sudo ufw deny 3306

# Delete rule
sudo ufw delete allow 80

# Reset
sudo ufw reset
```

### Example

```bash
# Setup
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

---

## Best Practices

### 1. Default Deny

```
Inbound: Block all
Outbound: Allow all
Phir whitelist karein.
```

### 2. Least Privilege

**Sirf zaroori ports** open karein.

```
❌ All ports
✅ SSH (22), HTTP (80), HTTPS (443)
```

### 3. SSH Restricted

```
❌ 0.0.0.0/0 (duniya)
✅ My IP only
```

### 4. Regular Audit

```bash
# Review rules monthly
sudo ufw status verbose
sudo iptables -L -n
```

### 5. Logging

```bash
# Enable logging
sudo ufw logging on

# Check logs
sudo tail -f /var/log/ufw.log
```

### 6. Separate Security Groups

```
web-sg    → 80, 443
app-sg    → 8080
db-sg     → 3306 (sirf app-sg se)
```

---

## Commands

### UFW

```bash
sudo ufw status
sudo ufw enable
sudo ufw allow 22
sudo ufw deny 3306
sudo ufw delete allow 22
sudo ufw reset
```

### iptables

```bash
sudo iptables -L
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -F    # Flush all
```

### AWS Security Groups

```bash
aws ec2 describe-security-groups
aws ec2 authorize-security-group-ingress
aws ec2 revoke-security-group-ingress
```

### Check Open Ports

```bash
# Local
sudo netstat -tlnp
sudo ss -tlnp

# Remote scan
nmap -p 1-1000 3.26.97.163
```

---

## Checklist

- [ ] Firewall concept
- [ ] Types yaad
- [ ] AWS Security Groups
- [ ] iptables basics
- [ ] UFW commands
- [ ] Best practices
- [ ] Commands run

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
