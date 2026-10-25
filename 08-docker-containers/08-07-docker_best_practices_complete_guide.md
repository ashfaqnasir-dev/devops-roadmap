# 🛡️ 08.07 Docker Best Practices — Complete Guide

> Docker images ko sirf "run hone ke qabil" banana kafi nahi hota. Production environments mein images ka **chhota (lightweight)**, **mehfooz (secure)**, aur **build time mein teez (optimized)** hona intehai zaroori hai. Yeh guide containerization ki 4 bunyadi industry-standard best practices ko tafseel se cover karti hai.

---

## The Production Optimization Pillars

```
                     ┌─────────────────────────────────────────┐
                     │       Docker Production Standards       │
                     └────────────────────┬────────────────────┘
         ┌───────────────────┬────────────┴────────────┬───────────────────┐
         ▼                   ▼                         ▼                   ▼
  [ Minimal Images ]  [ Non-Root Security ]     [ .dockerignore ]   [ Layer Caching ]
  • Alpine / Distroless • Least Privilege Principle• Clean Context   • Order of Change
  • Lower attack surface• Defense against escapes  • Faster uploads  • Sub-second builds
```

---

## 1. Small Images (Alpine & Distroless)

Bhari base images (jaise standard Ubuntu ya Debian) mein saikron aisi system libraries, package managers (`apt`, `dpkg`), aur network binaries (`curl`, `netcat`) hoti hain jin ki runtime par aapki app ko zaroorat nahi hoti.

### A. Small Images Kyun Zaroori Hain?
1. **Kam Attack Surface (Security):** Jitne kam packages honge, Common Vulnerabilities and Exposures (CVEs) aur security flaws utne hi kam honge.
2. **Tez Deployments & Pulls:** 30MB ki image registry se K8s cluster par 2 seconds mein download hoti hai, jabke 1GB ki image download hone mein waqt lagta hai (autoscaling slow ho jati hai).
3. **Storage & Bandwidth Cost:** Cloud registries (ACR, ECR) aur disk storage ke kharche kam hotay hain.

### B. Base Image Size Comparison:

```
node:20          ████████████████████████████████████ (~1.1 GB)
node:20-slim     ████████ (~200 MB)
node:20-alpine   ██ (~50 MB)
distroless/node  █ (~40 MB)
```

### C. Alpine vs Slim vs Distroless:

| Base Type | Typical Size | Package Manager | Shell Mojood Hai? | Best Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **Standard (Ubuntu/Debian)** | 700MB - 1GB+ | `apt` | Yes (`/bin/bash`) | Local heavy prototyping |
| **Slim** | 120MB - 250MB | `apt` | Yes (`/bin/sh`, `/bin/bash`) | Apps with complex C-bindings |
| **Alpine** | 5MB - 60MB | `apk` | Yes (`/bin/sh`) | Microservices (Standard pick) |
| **Distroless (Google)** | 20MB - 50MB | None ❌ | No ❌ | Maximum hardened security |

> ⚠️ **Alpine Gotcha (glibc vs musl libc):** 
> Alpine Linux standard GNU C Library (`glibc`) ke bajaye `musl libc` use karta hai. Python ke kuch data science packages (jaise NumPy, Pandas) ya C++ modules Alpine par compile hone mein bohot waqt lete hain ya pre-built wheels na milne ki wajah se slow build hotay hain. Python workloads ke liye aksar `python:3.11-slim` zyada stable rehta hai banisbat Alpine ke.

---

## 2. Non-Root User (Container Hardening)

By default, Dockerfile ke andar chalne wale tamam process aur commands **`root` user (UID 0)** ke tor par execute hotay hain.

### A. Khatra Kya Hai? (Container Breakout Risk)
Agar aapki application mein koi remote code execution (RCE) bug nikle aur container `root` par chal raha ho:
* Attacker container ke andar har file modify kar sakta hai.
* Agar Docker daemon mein koi privilege flaw ho ya host directory bind-mount (`-v /:/host`) ho, toh attacker **seedha host operating system ka root control** hasil kar sakta hai (Container Escape).

```
Attacker exploits App Vulnerability
              │
              ▼
   [ Running as root (UID 0) ] ──────► High risk: Can tamper OS files & attempt breakout! ❌
              VS
   [ Running as 'appuser' (UID 10001) ] ──► Low risk: Trapped in restricted user sandbox ✅
```

### B. Non-Root Setup Example (Alpine & Debian):

```dockerfile
FROM node:20-alpine

WORKDIR /app

# 1. System group aur user create karein
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 2. Files copy karein aur permissions assign karein
COPY package*.json ./
RUN npm ci --only=production

COPY --chown=appuser:appgroup . .

# 3. ROOT se unprivileged user par switch karein
USER appuser

# Container runtime par non-root process start hoga
EXPOSE 3000
CMD ["node", "server.js"]
```

> 💡 **Verification Command:**
> Container start karke check karein ke kaun sa user active hai:
> ```bash
> docker run --rm my-secure-app whoami
> # Output: appuser (Root nahi hona chahiye!)
> ```

---

## 3. `.dockerignore` (Clean Build Context)

Jab aap terminal mein `docker build .` chalate hain, Docker client sabse pehle current directory ki tamam files ko Docker daemon ko bhejta hai jise **Build Context** kehte hain.

Agar project root par `.dockerignore` file na ho, toh unnecessary heavy folders aur sensitive credentials image context mein shamil ho jaate hain.

```
Host Directory                 Build Context Transfer
┌──────────────────────┐       ┌──────────────────────┐
│  src/                │ ────► │  src/                │
│  .git/ (200MB)       │ ─❌─► │  (Filtered out)      │
│  node_modules/ (500M)│ ─❌─► │  (Filtered out)      │
│  .env (Secrets!)     │ ─❌─► │  (Filtered out)      │
└──────────────────────┘       └──────────────────────┘
```

### A. Production-Ready `.dockerignore` Template:

```gitignore
# Version control
.git
.gitignore

# Dependencies (Image ke andar fresh install honi chahiye)
node_modules
vendor
__pycache__
*.pyc

# Local environment & secrets (BOHOT AHEM: Secret leaks se bachao!)
.env
.env.*
*.pem
*.key
id_rsa

# Temporary files & logs
*.log
npm-debug.log*
.DS_Store
.idea
.vscode

# Build outputs
dist
build
coverage
```

### Fawaid:
* **Security:** Sensitive `.env` files accidental build layer mein copy nahi hoti.
* **Speed:** Build context ka size 600MB se kam ho kar 2MB reh jata hai, transfer instant hota hai.
* **Cache Integrity:** Local machine ke badalte hue log files ya `.git` commits image cache ko invalidate nahi karte.

---

## 4. Layer Caching (Order of Change Principle)

Docker builds ko super-fast banane ke liye **Layer Caching** sabse ahem technique hai.

### A. Rule: "Least Frequently Changed Steps First"
Docker layers ko upar se niche (top-to-bottom) execute karta hai. **Agar kisi ek line ka cache invalidate (bust) ho jaye, toh uske baad aane wali tamam subsequent layers dubara run hongi.**

```
Code tabdeel hota hai: Har ghante / har commit par (High frequency)
Dependencies tabdeel hoti hain: Hafton mein ek dafa (Low frequency)
OS Tools tabdeel hotay hain: Mahinon mein ek dafa (Rarely)
```

### B. Ghalt vs Sahi Caching Pattern:

#### ❌ Ghalt Pattern (Slow - Har build par `npm install` chalega):
```dockerfile
FROM node:20-alpine
WORKDIR /app

# Pura source code pehle copy kar diya
COPY . .

# Code mein ek typo bhi theek karein, toh yeh expensive step dubara chalega!
RUN npm install

CMD ["node", "server.js"]
```

#### ✅ Sahi Pattern (Fast - Cached Dependencies):
```dockerfile
FROM node:20-alpine
WORKDIR /app

# Step 1: Sirf package manifests copy karein
COPY package.json package-lock.json ./

# Step 2: Dependencies install karein (Yeh layer CACHE ho jayegi!)
RUN npm ci

# Step 3: Application code aakhri marhale par copy karein
COPY . .

CMD ["node", "server.js"]
```

*Nateeja:* Agar aap sirf apne source code (`server.js`) mein tabdeeli karenge, toh Step 1 aur Step 2 instant **`CACHED`** mark honge aur build 1-2 seconds mein complete ho jayegi!

---

## 5. Complete Production-Grade Dockerfile Template

Yeh ek unified production-ready Dockerfile hai jo tamam 4 best practices (Small base, Non-root, Caching, Multi-stage) ko incorporate karti hai:

```dockerfile
# ========================================================
# Stage 1: Build Phase (Heavy dependencies yahan isolate hain)
# ========================================================
FROM node:20-alpine AS builder

WORKDIR /build

# Layer caching: Package manifests pehle
COPY package*.json ./
RUN npm ci

# Source code copy karke compile/bundle karein
COPY . .
RUN npm run build && npm prune --production

# ========================================================
# Stage 2: Production Runtime (Ultra-lightweight & Hardened)
# ========================================================
FROM node:20-alpine AS runner

# Security: Dedicated unprivileged non-root user
RUN addgroup -S appgroup -g 10001 && \
    adduser -S appuser -u 10001 -G appgroup

WORKDIR /home/appuser/app

# Builder se sirf sanitized production artifacts copy karein
COPY --from=builder --chown=appuser:appgroup /build/package.json ./
COPY --from=builder --chown=appuser:appgroup /build/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /build/dist ./dist

# Switch to non-root
USER appuser

EXPOSE 3000

ENV NODE_ENV=production

CMD ["node", "dist/main.js"]
```

---

## 💡 Practical Audit Checklist

| Checkpoint | Target State | Command to Verify |
| :--- | :--- | :--- |
| **Base Image** | Alpine ya Slim base | `docker images` (Check virtual size) |
| **User Account** | Non-root UID | `docker run --rm <image> id` |
| **Build Context** | `.dockerignore` exists | `ls -la .dockerignore` |
| **Layer Cache** | Manifests before source code | `docker build .` (Look for `USING CACHE`) |
| **Secrets Exposure**| No hardcoded keys | `docker history --no-trunc <image>` |

---
**Status:** ✅ Complete