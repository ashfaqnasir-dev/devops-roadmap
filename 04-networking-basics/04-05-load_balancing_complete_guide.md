# ⚖️ 04.05 Load Balancing — Complete Guide

> **Load Balancer (LB)** ek traffic controller (traffic cop) ki tarah hota hai jo aane wali incoming requests ko multiple backend servers (target pool) par distribute karta hai. Iska maqsad kisi ek server ko overload hone se bachana, high availability (HA) ensure karna, aur application uptime barhana hota hai.

---

## 1. Layer 4 vs Layer 7 Load Balancing

OSI model ke mutabiq load balancers do main levels par kaam karte hain:

```
                  ┌─────────────────────────────────┐
Incoming Traffic ─┤ Load Balancer (Decides routing) ├─┬─> Backend Server 1
                  └─────────────────────────────────┘ ├─> Backend Server 2
                                                      └─> Backend Server 3
```

| Feature | Layer 4 Load Balancing (Transport) | Layer 7 Load Balancing (Application) |
| :--- | :--- | :--- |
| **OSI Layer** | Layer 4 (TCP / UDP) | Layer 7 (HTTP / HTTPS / gRPC) |
| **Data Visibility** | Packet payload ko inspect **nahi** karta | HTTP headers, cookies, URLs, path inspect karta hai |
| **Routing Basis** | IP Address aur Port number (`192.168.1.5:80`) | URL path (`/api` vs `/static`), host header, cookies |
| **Speed & Performance** | **Ultra-fast & Lightweight** (Data decrypt nahi karta) | Thora slow/resource-heavy (Packet open & decrypt karna parta hai) |
| **TLS / SSL Handling** | Passthrough (SSL server par terminate hota hai) | SSL Termination, cert offloading, header injection |
| **Cloud Examples** | AWS NLB (Network Load Balancer) | AWS ALB (Application Load Balancer) |
| **Software Examples** | HAProxy (TCP mode), IPVS, Nginx stream | HAProxy (HTTP mode), Nginx, Traefik, Envoy |

---

## 2. Load Balancing Algorithms

Load balancer decide kaise karta hai ke agli request kis server ko bhejni hai? Iske liye mukhtalif algorithms use hote hain:

### A. Round-Robin (Default)
Requests ko baari baari (sequentially) line se har server par bhejta hai.
* *Example:* Request 1 $\rightarrow$ Server A, Request 2 $\rightarrow$ Server B, Request 3 $\rightarrow$ Server C, Request 4 $\rightarrow$ Server A.
* **Weighted Round-Robin:** Agar Server A ke paas double RAM/CPU hai, toh use zyada weight (e.g. `weight=2`) de kar zyada traffic bheji ja sakti hai.

### B. Least Connections (`least_conn`)
Traffic us server ko bhejta hai jiske paas **sabse kam active connections** hon.
* **Kab use karein:** Aise tasks jahan requests mukhtalif waqt leti hain (jaise file uploads, reporting queries, database long-polling).

### C. IP Hash / Source Hash
Client ke IP address ko hash karke hamesha **usi specific backend server** par bhejta hai.
* **Kab use karein:** Session persistence / sticky sessions achieve karne ke liye jab backend par shared session cache (jaise Redis) mojood na ho.

### D. Least Response Time
Nayi request us server ko di jaati hai jo sabse kam average response latency de raha ho.

---

## 3. Health Checks (Self-Healing Traffic Routing)

Load balancer lagatar backends ki sehat check karta rehta hai taake crash hue server ko traffic na jaye:

```
[ Load Balancer ]
       │
       ├── GET /healthz ──> [ Server 1: 200 OK ]  (Healthy ✅ - Traffic routed)
       │
       └── GET /healthz ──> [ Server 2: 500 ERR ] (Unhealthy ❌ - Removed from pool)
```

### Health Check Parameters:
* **Endpoint / Interval:** Har 5 ya 10 seconds baad `/healthz` ya `/ping` par GET request bhejta hai.
* **Healthy Threshold:** Kitni kamyab requests ke baad server ko wapis pool mein add karna hai (e.g., 2 consecutive `200 OK`).
* **Unhealthy Threshold:** Kitni baar fail hone par use dead mark karke traffic rokni hai (e.g., 3 failed checks).
* **Timeout:** Response aane ki maximum limit (e.g., 2 seconds).

---

## 4. Reverse Proxy (Nginx & HAProxy Setup)

Forward Proxy client ke aage lagti hai (client ki identity chupane ke liye). **Reverse Proxy** backend web servers ke aage lagti hai taake servers ko direct expose kiye baghair security, caching, SSL, aur load balancing provide ki ja sake.

### A. Nginx Load Balancer Configuration (`nginx.conf`)

```nginx
http {
    # 1. Backend Servers ka Pool define karein (Upstream)
    upstream backend_nodes {
        # least_conn; # Uncomment for least connections algorithm
        # ip_hash;    # Uncomment for sticky sessions

        server 10.0.0.11:8080 weight=2;
        server 10.0.0.12:8080 max_fails=3 fail_timeout=10s;
        server 10.0.0.13:8080 backup; # Sirf tab chalega jab baaqi fail ho jayein
    }

    server {
        listen 80;
        server_name app.example.com;

        location / {
            # Traffic ko upstream pool ki taraf forward karein
            proxy_pass http://backend_nodes;

            # Original client IP headers backend tak pass karna
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

### B. HAProxy Configuration (`haproxy.cfg`)

HAProxy high-concurrency aur low latency ke liye industry standard load balancer hai:

```haproxy
frontend http_in
    bind *:80
    mode http
    default_backend web_cluster

backend web_cluster
    mode http
    balance roundrobin
    option httpchk GET /healthz
    http-check expect status 200

    server srv1 10.0.0.11:8080 check inter 3s fall 3 rise 2
    server srv2 10.0.0.12:8080 check inter 3s fall 3 rise 2
```

---

**Status:** ✅ Complete