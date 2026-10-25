# 🐳 Dockerfile — Complete Guide

> Dockerfile = Recipe jo batati hai image kaise banao.

---

## 📚 Table of Contents

1. [Dockerfile Kya Hai?](#dockerfile-kya-hai)
2. [Basic Structure](#basic-structure)
3. [FROM](#from)
4. [RUN, CMD, ENTRYPOINT](#run-cmd-entrypoint)
5. [COPY, ADD](#copy-add)
6. [WORKDIR, EXPOSE](#workdir-expose)
7. [ENV, ARG](#env-arg)
8. [Multi-Stage Builds](#multi-stage-builds)
9. [Real Example — Flask App](#real-example--flask-app)
10. [Best Practices](#best-practices)

---

## Dockerfile Kya Hai?

**Dockerfile** = **Text file** — jismein **step-by-step instructions** hoti hain **Docker image banane ke liye**.

**Analogy:** Ghar banane ka **naksha** — har step likha hota hai.

```
Dockerfile  →  docker build  →  Image  →  docker run  →  Container
   (Recipe)      (Cook)         (Cake)     (Eat)          (Chalta hua)
```

---

## Basic Structure

```dockerfile
# 1. Base image
FROM python:3.11-slim

# 2. Working directory
WORKDIR /app

# 3. Dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# 4. App code
COPY app.py .

# 5. Port
EXPOSE 5000

# 6. Run command
CMD ["python", "app.py"]
```

---

## FROM

### Kya Hai?

**Base image** — kis image se shuru karna hai.

### Syntax

```dockerfile
FROM <image>:<tag>
```

### Examples

```dockerfile
FROM ubuntu:22.04
FROM python:3.11-slim
FROM node:20-alpine
FROM nginx:latest
```

### Notes

- **Pehli line** hamesha `FROM` hoti hai
- **`slim`** ya **`alpine`** — chhoti images
- **`latest`** — avoid karein production mein

---

## RUN, CMD, ENTRYPOINT

### Comparison Table

| Command | Kab Chalta | Purpose | Override |
|---|---|---|---|
| **RUN** | Build time | Image banate waqt | ❌ |
| **CMD** | Run time | Container start | ✅ Easy |
| **ENTRYPOINT** | Run time | Container start | ⚠️ Hard |

### RUN — Build Time

```dockerfile
RUN apt-get update
RUN apt-get install -y nginx
RUN pip install flask
```

**Kab:** Image build karte waqt.

### CMD — Default Command

```dockerfile
CMD ["python", "app.py"]
CMD ["nginx", "-g", "daemon off;"]
```

**Sirf ek CMD** — last wala chalta hai.

**Override:**

```bash
docker run my-image bash
```

### ENTRYPOINT — Fixed Command

```dockerfile
ENTRYPOINT ["python", "app.py"]
```

**Override:**

```bash
docker run --entrypoint bash my-image
```

### Best Practice — Dono Saath

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Result:

```bash
docker run my-image          # python app.py
docker run my-image test.py  # python test.py
```

---

## COPY, ADD

### COPY — Files Copy

```dockerfile
COPY app.py /app/
COPY requirements.txt .
COPY . /app
```

**Simple aur clear.**

### ADD — Extra Features

```dockerfile
ADD https://example.com/file.tar.gz /app/
ADD file.tar.gz /app/
```

**Extra:**
- URL download
- Auto-extract

### Best Practice

**`COPY` use karein** — unless URL/extract zaroori ho.

---

## WORKDIR, EXPOSE

### WORKDIR — Working Directory

```dockerfile
WORKDIR /app
```

**Baad ke commands** is folder mein chalte hain.

**Agar nahi hai** — automatically ban jata hai.

### EXPOSE — Port Document

```dockerfile
EXPOSE 5000
EXPOSE 80/tcp
EXPOSE 8080
```

**Note:** Yeh sirf **documentation** hai — port publish nahi karta.

**Port publish:**

```bash
docker run -p 8080:5000 my-image
```

---

## ENV, ARG

### ENV — Runtime Variable

```dockerfile
ENV APP_NAME=myapp
ENV PORT=5000
ENV FLASK_ENV=production
```

**Persist:** Container ke andar hamesha.

### ARG — Build Variable

```dockerfile
ARG VERSION=1.0
ARG NODE_VERSION=20
```

**Build time:**

```bash
docker build --build-arg VERSION=2.0 .
```

### Comparison

| Feature | ENV | ARG |
|---|---|---|
| **Kab** | Build + Run | Build only |
| **Persist** | ✅ | ❌ |
| **Override** | Runtime | Build time |

---

## Multi-Stage Builds

### Kya Hai?

**Multiple `FROM`** — final image **chhota**.

### Example — Python

```dockerfile
# Stage 1: Builder
FROM python:3.11 AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Final
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
```

### Fayda

| Stage | Size |
|---|---|
| Builder | ~900 MB |
| Final | ~150 MB |

**Chhota** = fast deploy.

---

## Real Example — Flask App

### Folder Structure

```
flask-docker/
├── app.py
├── requirements.txt
├── Dockerfile
└── .dockerignore
```

### app.py

```python
from flask import Flask
import socket
from datetime import datetime

app = Flask(__name__)

@app.route('/')
def home():
    hostname = socket.gethostname()
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"<h1>Flask in Docker</h1><p>Hostname: {hostname}</p><p>Time: {now}</p>"

@app.route('/health')
def health():
    return {"status": "ok"}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir flask

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

### .dockerignore

```
.git/
.gitignore
__pycache__/
*.pyc
venv/
.venv/
*.log
README.md
```

### Build & Run

```bash
# Build
docker build -t my-flask-app .

# Run
docker run -d -p 5000:5000 --name flask-container my-flask-app

# Verify
docker ps
curl localhost:5000

# Browser
# http://localhost:5000
```

---

## Best Practices

### 1. Chhoti Base Image

```dockerfile
✅ FROM python:3.11-slim
❌ FROM python:3.11
```

### 2. Specific Tags

```dockerfile
✅ FROM python:3.11.5
❌ FROM python:latest
```

### 3. Combine RUN Commands

```dockerfile
✅ RUN apt-get update && apt-get install -y nginx
❌ RUN apt-get update
❌ RUN apt-get install -y nginx
```

### 4. .dockerignore Use Karein

```
.git/
__pycache__/
venv/
node_modules/
*.log
```

### 5. Non-Root User

```dockerfile
RUN useradd -m appuser
USER appuser
```

### 6. Multi-Stage Builds

**Builder** stage → **Final** stage.

### 7. Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1
```

---

## Common Commands

| Command | Purpose |
|---|---|
| `docker build -t name .` | Image banao |
| `docker build --no-cache -t name .` | Fresh build |
| `docker run -d -p 5000:5000 name` | Container chalao |
| `docker ps` | Running containers |
| `docker logs <id>` | Logs dekho |
| `docker exec -it <id> bash` | Shell |
| `docker stop <id>` | Stop |
| `docker rm <id>` | Delete container |
| `docker rmi name` | Delete image |

---

## Troubleshooting

### Issue 1: Build Fail

**Solution:** Line-by-line dekho — error message padho.

### Issue 2: Image Bara

**Solution:** Multi-stage + slim base + `.dockerignore`.

### Issue 3: Port Already in Use

**Solution:** Different port:

```bash
docker run -d -p 5001:5000 my-app
```

### Issue 4: Container Exits Immediately

**Solution:** Logs dekho:

```bash
docker logs <container-id>
```

---

## Checklist

- [ ] Dockerfile banayi
- [ ] FROM specific
- [ ] WORKDIR set
- [ ] Dependencies install
- [ ] App code copy
- [ ] EXPOSE port
- [ ] CMD set
- [ ] .dockerignore banaya
- [ ] Build successful
- [ ] Container running
- [ ] Browser test

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
