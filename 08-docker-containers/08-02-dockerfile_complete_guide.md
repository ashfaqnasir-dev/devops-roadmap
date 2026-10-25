# 🐳 08.02 Dockerfile — Complete Guide

> **Dockerfile** ek plain-text configuration file hoti hai jisme instructions ka ek step-by-step silsila likha hota hai. Docker Engine inhi instructions ko line-by-line follow karke ek standalone, runnable **Docker Image** build karta hai.

---

## The Build Context & Layer Caching Mental Model

Jab aap `docker build` chalate hain, toh Docker har instruction se ek **read-only layer** banata hai. Agar pehle se bani hui layer mein koi tabdeeli na ho, toh Docker pichli cached layer reuse karta hai jisse build seconds mein mukammal ho jati hai.

```
┌────────────────────────────────────────────────────────┐
│ Layer 4: CMD ["node", "server.js"]  (Metadata layer)   │
├────────────────────────────────────────────────────────┤
│ Layer 3: COPY . .                   (App code layer)   │
├────────────────────────────────────────────────────────┤
│ Layer 2: RUN npm install            (Dependencies)     │
├────────────────────────────────────────────────────────┤
│ Layer 1: FROM node:20-alpine        (Base OS & Runtime)│
└────────────────────────────────────────────────────────┘
                       ▲
        (Bottom to top immutable layers)
```

> 💡 **Layer Caching Rule:** Agar kisi line ka code ya input change ho jaye (jaise `COPY . .`), toh us line ki aur uske baad aane wali **tamam subsequent layers ka cache invalidate (bust)** ho jata hai. Isliye kam tabdeel hone wali cheezein (jaise packages install karna) hamesha upar rakhi jaati hain.

---

## 1. `FROM` (The Foundation)

Har valid Dockerfile ka shuruat **`FROM`** instruction se hona laazmi hai. Yeh batata hai ke aapka container kis base image aur operating system environment par banega.

### A. Syntax:
```dockerfile
FROM <image>[:<tag>] [AS <stage-name>]
```

### B. Base Image Types:
* **Full OS (Heavy):** `FROM ubuntu:22.04` (~75MB) — Zyadatar build tools pehle se mojood hotay hain magar image size bara hota hai.
* **Slim (Optimized):** `FROM python:3.11-slim` (~120MB) — Extra tools nikal diye gaye hain, lightweight production deployments ke liye standard.
* **Alpine (Ultra-light):** `FROM node:20-alpine` (~5MB base) — Musl libc par mabni super chhota Linux distribution.
* **Scratch (Empty):** `FROM scratch` (0MB) — Zero-byte empty base; sirf pre-compiled Go/Rust static binaries ke liye use hota hai.

---

## 2. Execution Instructions: `RUN`, `CMD`, `ENTRYPOINT`

Yeh teen instructions developers ko sabse zyada confuse karti hain:

```
┌─────────────┬─────────────────────────────────┬────────────────────────────────────┐
│ Instruction │ Kab Execute Hoti Hai?          │ Asal Maqsad                        │
├─────────────┼─────────────────────────────────┼────────────────────────────────────┤
│ RUN         │ Image BUILD time par            │ Packages install karna, compile    │
│ CMD         │ Container RUN time (start) par  │ Default command ya default args    │
│ ENTRYPOINT  │ Container RUN time (start) par  │ Fixed executable jo hamesha chalay │
└─────────────┴─────────────────────────────────┴────────────────────────────────────┘
```

### A. `RUN` (Build Time):
Naye packages install karne aur layers create karne ke liye:
```dockerfile
# Shell form
RUN apt-get update && apt-get install -y curl

# Chaining technique (Layers reduce karne ke liye && use karein)
RUN apt-get update && apt-get install -y \
    git \
    jq \
    && rm -rf /var/lib/apt/lists/*
```

### B. `CMD` vs `ENTRYPOINT` (Run Time):

1. **`CMD` (Overridable Default):**
   Agar user `docker run my-app <command>` chala de, toh `CMD` **mukammal overwrite** ho jati hai.
   ```dockerfile
   CMD ["python", "app.py"]
   # Agar user chalaye: docker run my-app bash
   # Toh "python app.py" ki jagah "bash" chal jayega
   ```

2. **`ENTRYPOINT` (Strict Executable):**
   Yeh container ko ek CLI tool ki tarah behave karwata hai. CLI se pass kiye gaye arguments iske aage append ho jaate hain.
   ```dockerfile
   ENTRYPOINT ["ping"]
   CMD ["8.8.8.8"]
   # docker run my-ping-app          ──► executes: ping 8.8.8.8
   # docker run my-ping-app 1.1.1.1  ──► executes: ping 1.1.1.1 (CMD override hui, ENTRYPOINT barkarar raha)
   ```

> ⚠️ **Exec Form vs Shell Form:**
> Hamesha **Exec form** (JSON array: `["executable", "param1"]`) use karein. Shell form (`CMD node server.js`) container process ko shell ke child process ke tor par chalati hai jisse Linux `SIGTERM` signals theek tarah nahi pohnchte aur graceful shutdowns fail ho jaate hain.

---

## 3. Files Transfer: `COPY` vs `ADD`

Dono instructions host machine se container ke andar files copy karti hain.

```dockerfile
# COPY Syntax:
COPY <source_on_host> <dest_in_container>

# ADD Syntax:
ADD <source_or_url_or_tar> <dest_in_container>
```

| Feature | `COPY` (Recommended) | `ADD` (Specialized) |
| :--- | :--- | :--- |
| **Local file copy** | ✅ Transparent aur predictable | ✅ Kaam karta hai |
| **Remote URLs** | ❌ Support nahi karta (Use `RUN curl`) | ✅ Direct HTTP/HTTPS download kar sakta hai |
| **Auto-Extraction** | ❌ Compressed files ko waise hi copy karta hai | ✅ Local `.tar.gz` files ko automatically uncompress karta hai |
| **Industry Practice** | **95% cases mein COPY hi standard hai** | Sirf local tar auto-extract ke liye use hota hai |

```dockerfile
# Best Practice: Sirf dependencies manifest pehle copy karein taake cache optimize rahe
COPY package.json package-lock.json ./
RUN npm ci

# Source code baad mein copy karein
COPY . .
```

---

## 4. Environment & Context: `WORKDIR` & `EXPOSE`

### A. `WORKDIR` (Working Directory):
Container ke andar target directory set karta hai. Agar folder exist na karta ho, toh yeh use **khud bana deta hai**.
```dockerfile
# ❌ Ghalt (Har RUN line nayi shell spawn karti hai, 'cd' agle step par persist nahi rehti):
RUN cd /app
RUN npm install

# ✅ Sahi (Docker native persistent path):
WORKDIR /usr/src/app
```

### B. `EXPOSE` (Documentation Port):
Yeh container ke metadata mein record karta hai ke container kis port par listen karega.
```dockerfile
EXPOSE 8080
```
> ⚠️ **Important Note:** `EXPOSE` likhne se port host par **automatically publish nahi hoti**. Bahir se traffic bhejne ke liye runtime par `-p 8080:8080` lagana hi parta hai. `EXPOSE` sirf documentation aur container inter-linking ke liye hota hai.

---

## 5. Variables: `ENV` vs `ARG`

```
┌────────────────────────────────────────────────────────┐
│                        ARG                             │
│   (Sirf `docker build --build-arg` ke waqt active hai) │
└──────────────────────────┬─────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────┐
│                        ENV                             │
│  (Image ke metadata mein store hota hai;               │
│   Runtime / `docker run` par bhi active rehta hai)     │
└────────────────────────────────────────────────────────┘
```

| Khasiyat | `ARG` (Build Argument) | `ENV` (Environment Variable) |
| :--- | :--- | :--- |
| **Lifetime** | Sirf image build hone ke doran | Build time **AUR** running container dono mein |
| **Overriding** | `docker build --build-arg KEY=val` | `docker run -e KEY=val` |
| **Security Note** | Image layers mein visible ho sakta hai (no secrets!) | `docker inspect` se readable hota hai (no raw passwords!) |
| **Use Case** | Tool version decide karna (`ARG NODE_VER=20`) | App environment (`ENV NODE_ENV=production`) |

### Example in Dockerfile:
```dockerfile
ARG APP_VERSION=1.0.0
ENV PORT=3000
ENV ENVIRONMENT=production

# ARG ko hum image build ke andar use kar sakte hain:
RUN echo "Building version ${APP_VERSION}..."
```

---

## 6. Multi-Stage Builds (Production Optimization)

Traditional builds mein compilers (Go compiler, TypeScript build tools, SDKs) image size ko 1 GB+ tak phula dete hain jabke production runtime par un tools ki zaroorat nahi hoti.

**Multi-Stage Build** ek hi Dockerfile mein multiple `FROM` lines use karta hai:
1. **Builder Stage:** Bhari SDKs ke sath code compile karta hai.
2. **Final Stage:** Lightweight minimal image leta hai aur builder stage se **sirf compiled binaries** copy karta hai.

```
Stage 1: [ golang:1.22-alpine (Heavy SDK ~300MB) ]
                │
                ▼ (Compiles source code to single binary: /app/server)
Stage 2: [ alpine:3.19 (Minimal OS ~7MB) ]
                ▲
                │ (COPY --from=builder /app/server /bin/server)
         Final Image Size: ~15MB! ⚡
```

### Production Example (Go API Service):
```dockerfile
# ================= Stage 1: Build Phase =================
FROM golang:1.22-alpine AS builder

WORKDIR /src

# Dependency cache layer
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build static binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /bin/api-server .

# ================= Stage 2: Final Minimal Runtime =================
FROM alpine:3.19 AS runner

# Security: Non-root user setup
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /home/appuser

# Builder stage se sirf compiled binary copy karein
COPY --from=builder /bin/api-server ./api-server

# Switch to unprivileged user
USER appuser

EXPOSE 8080

CMD ["./api-server"]
```

---

## 💡 Dockerfile Production Best Practices Cheatsheet

1. **`.dockerignore` File Lazmi Banayein:** Hamesha project root par `.dockerignore` file rakhein taake `node_modules`, `.git`, `.env`, aur temporary test files container context mein copy na hon.
2. **Sort Multi-line Arguments Alphabetically:** Tools install karte waqt packages ko alphabetize karein taake maintenance aasan ho.
3. **Run as Non-Root User:** By default Docker containers root user se run hotay hain jo security risk hai. Hamesha production images mein `USER <name>` switch karein.
4. **Specific Base Image Tags:** Kabhi bhi `FROM node:latest` production mein use na karein; hamesha exact version tag lagayein jaise `FROM node:20.11.1-alpine`.

---
**Status:** ✅ Complete