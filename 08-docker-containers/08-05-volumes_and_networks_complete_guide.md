# 💾 08.05 Volumes & Networks — Complete Guide

> Docker containers by design **ephemeral (aarzi)** hote hain. Agar container stop ya delete ho jaye, toh uski writable layer mein mojood poora data zaya ho jata hai. Isi tarah containers ko bahir ki dunya aur aapas mein connect karne ke liye structured networking ki zaroorat hoti hai. Yeh guide Docker ke **Storage (Data Persistence)** aur **Networking** ke tamam core concepts ko cover karti hai.

---

# PART 1: STORAGE & PERSISTENCE

Docker storage ke do ahem tareeqay hain: **Named Volumes** aur **Bind Mounts**.

```
    [ Named Volume ]                           [ Bind Mount ]
┌───────────────────────────────┐          ┌───────────────────────────────┐
│ /var/lib/docker/volumes/my_db │          │  /home/user/project/my_code   │
│   (Docker-managed directory)  │          │   (Any host directory / file) │
└──────────────┬────────────────┘          └──────────────┬────────────────┘
               │                                          │
               ▼                                          ▼
     [ Container Filesystem: /var/lib/postgresql/data or /app ]
```

---

## 1. Named Volumes (`docker volume`)

**Named Volumes** Docker ka native aur recommended persistent storage tareeqa hai. Yeh host file system ke ek makhsoos hissay (`/var/lib/docker/volumes/` Linux par) mein Docker engine khud manage karta hai.

### A. Khasiyat:
* **Docker-Managed:** Host machine ke OS permissions ya directory structure ki fikar nahi karni parti.
* **Performance & Safety:** Database storage (PostgreSQL, MySQL, MongoDB) ke liye highest performance aur safety deta hai.
* **Lifecycle Isolation:** Container delete hone ke baad bhi volume **kabhi delete nahi hota** jab tak explicitly remove na kiya jaye.

### B. CLI Operations & Usage:

```bash
# 1. Naya volume create karna
docker volume create db_data

# 2. Volumes ki list dekhna
docker volume ls

# 3. Volume ko inspect karna (Host par exact path dekhna)
docker volume inspect db_data

# 4. Container ke sath attach karna (-v volume_name:container_path)
docker run -d \
  --name production-postgres \
  -e POSTGRES_PASSWORD=mysecret \
  -v db_data:/var/lib/postgresql/data \
  postgres:16-alpine

# Modern '--mount' syntax (Recommended by Docker):
docker run -d \
  --name production-postgres \
  --mount source=db_data,target=/var/lib/postgresql/data \
  postgres:16-alpine
```

### C. Cleanup:
```bash
# Unused volumes delete karna (jo kisi container se attach na hon)
docker volume prune -f
```

---

## 2. Bind Mounts

**Bind Mount** host machine ke kisi bhi specific absolute directory ya file ko container ke andar direct mount kar deta hai.

### A. Khasiyat:
* **Host Dependent:** Host path ka absolute hona laazmi hai (e.g. `/home/user/devops/app`).
* **Live Sync (Hot Reload):** Host par file save karein, container ke andar bina rebuild kiye fauran update reflect ho jayega.
* **Security Consideration:** Container host ke filesystem ko modify ya delete kar sakta hai agar write permissions hon.

### B. Daily Development Usage:

```bash
# Current directory ($(pwd)) ko container ke '/app' par mount karna
docker run -d \
  --name dev-node-app \
  -p 3000:3000 \
  -v $(pwd):/app \
  node:20-alpine npm run dev

# Read-only bind mount (:ro flag) — Security hardening
docker run -d \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -p 80:80 \
  nginx:alpine
```

### C. Comparison Matrix: Volumes vs Bind Mounts

| Feature | Named Volumes | Bind Mounts |
| :--- | :--- | :--- |
| **Host Storage Path** | Docker storage area (`/var/lib/docker/volumes`) | Host ka koi bhi path (`/var/log`, `~/app`) |
| **Managed By** | Docker CLI & Daemon | Host OS file system & User |
| **Performance** | High (Optimized for I/O heavy DBs) | Host filesystem speed par depend karta hai |
| **Best Use Case** | Databases, production stateful workloads | Local development, config file injection |

---

# PART 2: DOCKER NETWORKING

Docker containers by default isolated network namespaces mein run hotay hain. Containers aapas mein kaise rabta karenge, yeh Docker Network types decide karte hain.

```
                    ┌───────────────────────────────────┐
                    │       Docker Network Models       │
                    └─────────────────┬─────────────────┘
          ┌───────────────────────────┼───────────────────────────┐
          ▼                           ▼                           ▼
[ Default Bridge ]          [ Host Network ]            [ Custom Bridge Network ]
• Legacy docker0 IP         • Bypasses isolation        • Built-in DNS Discovery
• IP-based only (No DNS)    • Max performance           • Automatic container name
• Isolated from host        • Shares host port space    • Production best practice
```

---

## 3. Bridge Networks (`bridge`)

Jab aap bina koi network specify kiye container start karte hain, toh Docker use **Default Bridge** network (`docker0`) se connect karta hai.

### A. Architecture:
* Docker daemon host machine par ek virtual bridge interface banata hai (aam tor par subnet `172.17.0.0/16`).
* Har container ko is subnet se ek private IP address milta hai.
* Port mapping (`-p 8080:80`) ke zariye Linux `iptables` NAT rules banaye jaate hain taake host port se traffic container tak jaye.

### B. Default Bridge ki Kami (No Automatic DNS!):
Default bridge par chalte hue do containers ek doosre ko **sirf IP address** se ping kar sakte hain, container name se nahi.

```bash
# Agar IP badal jaye toh connection toot jayega:
docker run -d --name db postgres:alpine
docker run -d --name app backend-app
# 'app' cannot ping 'db' by name! (Ping fails)
```

---

## 4. Host Networks (`--network host`)

Host networking container aur Docker host ke darmiyan network namespace ki isolation khatam kar deti hai.

```
       [ Host Machine: Physical NIC (eth0) ]
                        │
                        ▼ (Shared directly, No NAT, No Port Mapping)
           [ Container using --network host ]
```

### A. Syntax:
```bash
docker run -d --name web --network host nginx:alpine
```

### B. Rules & Characteristics:
* **No Port Forwarding (`-p` is ignored):** Nginx port 80 par chal raha hai toh seedha host ki port 80 par live ho jayega.
* **Maximum Performance:** NAT (Network Address Translation) overhead nahi hota; zero latency networking.
* **Port Conflicts:** Agar do containers host network par ek hi port (e.g. 80) use karne ki koshish karein toh port conflict error aayega.
* **OS Limitation:** Yeh feature bunyadi tor par **Linux hosts** par kaam karta hai (Docker Desktop for Mac/Windows par virtualization layer ki wajah se fully native behave nahi karta).

---

## 5. Custom Networks (User-Defined Bridge — Industry Standard)

Production setups mein hamesha **Custom User-Defined Bridge Network** banaya jata hai.

### A. Superpower: Automatic DNS Name Resolution (Service Discovery)
Custom network ke andar containers ek doosre ko **unke container name se direct call kar sakte hain**. Kisi hardcoded IP address ki zaroorat nahi rehti!

```
                    [ Custom Network: 'app-tier' ]
        ┌───────────────────────────────────────────────────┐
        │                                                   │
        ▼                                                   ▼
[ Container: 'web' ] ────────── ping "database" ────────► [ Container: 'database' ]
  (Frontend Node)          (Docker Embedded DNS               (PostgreSQL DB)
                            resolves to 172.18.0.3)
```

### B. Step-by-Step Practical Setup:

```bash
# 1. Custom bridge network create karein
docker network create my-custom-net

# 2. Database container ko is network par launch karein
docker run -d \
  --name database \
  --network my-custom-net \
  -e POSTGRES_PASSWORD=pass \
  postgres:16-alpine

# 3. Application container ko usi network par launch karein
docker run -d \
  --name web-app \
  --network my-custom-net \
  -p 3000:3000 \
  -e DB_HOST=database \
  node:20-alpine

# 4. Verify karein DNS connectivity:
docker exec -it web-app ping database
# PING database (172.18.0.2): 56 data bytes — Success! ✅
```

### C. Network Management Commands:

```bash
# Tamam networks dekhna
docker network ls

# Network ke connected containers inspect karna
docker network inspect my-custom-net

# Running container ko chalte waqt network se attach/detach karna
docker network connect my-custom-net another-container
docker network disconnect my-custom-net another-container

# Unused networks clean karna
docker network prune -f
```

---

## 💡 Practical Cheatsheet: Decision Guide

```
Need persistent database storage that survives reboots?
  └──► Named Volume (`-v db_data:/var/lib/...`)

Need to test live frontend/backend code updates instantly without rebuilding?
  └──► Bind Mount (`-v $(pwd):/app`)

Need multiple microservices/containers to communicate securely by name?
  └──► Custom Bridge Network (`docker network create ...`)

Need ultra-low network latency for real-time video/high-throughput streaming?
  └──► Host Network (`--network host`)
```

---
**Status:** ✅ Complete