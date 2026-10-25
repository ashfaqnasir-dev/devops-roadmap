# 🌐 Load Balancing — Complete Guide

> Load Balancer = Traffic ko multiple servers mein distribute karta hai.

---

## 📚 Table of Contents

1. [Load Balancing Kya Hai?](#load-balancing-kya-hai)
2. [Layer 4 vs Layer 7](#layer-4-vs-layer-7)
3. [Algorithms](#algorithms)
4. [Health Checks](#health-checks)
5. [Reverse Proxy](#reverse-proxy)
6. [Tools](#tools)

---

## Load Balancing Kya Hai?

**Load Balancer** = **Traffic distributor** — aane wali requests ko **multiple servers** mein baant deta hai.

### Kahani

**Ek dukaan** mein **1 salesman** — line lambi.

**3 salesmen** — kaam **fast** — **load balanced**.

### Bina LB vs LB Ke Saath

```
Bina LB:
  Users ─────► Server 1 (overloaded)
  
LB Ke Saath:
  Users ──► Load Balancer ──┬──► Server 1
                            ├──► Server 2
                            └──► Server 3
```

### Fayde

- ✅ **High availability** — ek server down, baaki chalte
- ✅ **Scalability** — servers add/remove
- ✅ **Performance** — load distributed
- ✅ **No downtime** — maintenance easy

---

## Layer 4 vs Layer 7

### Layer 4 (Transport)

**Kya:** TCP/UDP level par balance.

**Decision:** IP + Port ke basis par.

**Speed:** Fast.

**Example:** AWS NLB.

### Layer 7 (Application)

**Kya:** HTTP level par balance.

**Decision:** URL, headers, cookies ke basis par.

**Speed:** Slower (parsing).

**Example:** AWS ALB, Nginx.

### Comparison

| Feature | Layer 4 | Layer 7 |
|---|---|---|
| OSI Layer | Transport | Application |
| Speed | Fast | Slower |
| Routing | IP + Port | URL, Headers |
| SSL | Pass-through | Terminate |
| Use | TCP/UDP | HTTP/HTTPS |

---

## Algorithms

### 1. Round Robin

**Kya:** Har server ko **turn by turn**.

```
Request 1 → Server 1
Request 2 → Server 2
Request 3 → Server 3
Request 4 → Server 1
```

### 2. Least Connections

**Kya:** Jis server par **sab se kam connections**.

```
Server 1: 5 connections
Server 2: 2 connections  ← Yahan bhejo
Server 3: 8 connections
```

### 3. IP Hash

**Kya:** Client IP ke basis par server decide.

**Fayda:** Same client → same server (session persistence).

### 4. Weighted

**Kya:** Server ki capacity ke hisaab se.

```
Server 1 (weight 3) → 3x requests
Server 2 (weight 1) → 1x requests
```

### 5. Least Response Time

**Kya:** Sab se fast response wala server.

---

## Health Checks

### Kya Hai?

**Health Check** = Load balancer server ki **health verify** karta hai.

**Agar server down:** LB usay **list se hata** deta hai.

### Types

| Type | Kya |
|---|---|
| **HTTP** | GET /health |
| **TCP** | Port connect |
| **HTTPS** | Secure check |

### Example

```
GET /health HTTP/1.1
Host: server1.example.com

Response:
HTTP/1.1 200 OK
{"status": "healthy"}
```

### Configuration

```yaml
health_check:
  path: /health
  interval: 30s
  timeout: 5s
  healthy_threshold: 2
  unhealthy_threshold: 3
```

---

## Reverse Proxy

### Kya Hai?

**Reverse Proxy** = **Server ke aage** — client requests receive karta hai.

**Load Balancer** bhi reverse proxy hai.

### Nginx as Load Balancer

```nginx
upstream backend {
    server 192.168.1.10:8080;
    server 192.168.1.11:8080;
    server 192.168.1.12:8080;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### Fayde

- Load balancing
- SSL termination
- Caching
- Compression
- Security (hide backend)

---

## Tools

### Cloud

| Tool | Provider |
|---|---|
| **ALB** | AWS |
| **NLB** | AWS |
| **Azure LB** | Azure |
| **GCP LB** | GCP |

### Self-Hosted

| Tool | Kya |
|---|---|
| **Nginx** | Web server + LB |
| **HAProxy** | Dedicated LB |
| **Traefik** | Modern LB |
| **Envoy** | Service mesh LB |

### Kubernetes

| Tool | Kya |
|---|---|
| **Service** | Internal LB |
| **Ingress** | External LB |
| **Ingress Controller** | Nginx, Traefik |

---

## Commands

### Nginx Test

```bash
# Config test
sudo nginx -t

# Reload
sudo systemctl reload nginx

# Status
sudo systemctl status nginx
```

### Check Load

```bash
# Requests to LB
for i in {1..10}; do curl -s http://localhost; done

# Watch distribution
while true; do curl -s http://localhost; sleep 1; done
```

### HAProxy

```bash
# Stats
echo "show stat" | sudo socat stdio /var/run/haproxy.sock

# Config
cat /etc/haproxy/haproxy.cfg
```

---

## Checklist

- [ ] Load balancing concept
- [ ] Layer 4 vs Layer 7
- [ ] Algorithms yaad
- [ ] Health checks
- [ ] Reverse proxy
- [ ] Tools

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
