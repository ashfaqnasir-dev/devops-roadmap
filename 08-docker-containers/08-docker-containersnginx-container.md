# Docker — Nginx Container Setup

> Quick guide to run Nginx container and view it in browser.

## 🛠️ Steps

### 1. Install Docker Desktop

**Download:** https://www.docker.com/products/docker-desktop/

**Install:**
- ✅ Use WSL 2 instead of Hyper-V
- Location: `C:\Program Files\Docker\` (~2 GB)

### 2. Set Data Location to E: Drive

**Settings** → **Resources** → **Disk image location** → `E:\Docker`

**Kyun:** Docker data bara hota hai — C: SSD bhar jata, E: HDD mein space hai.

### 3. Enable WSL Integration

**Settings** → **Resources** → **WSL Integration** → Ubuntu **ON**

**Verify:**
```bash
docker --version
# Docker version 29.8.2, build 7fc2dff
```

### 4. Run Nginx Container

```bash
docker run -d -p 9090:80 --name my-nginx nginx
```

| Flag | Matlab |
|---|---|
| `-d` | Detached (background) |
| `-p 9090:80` | Host port 9090 → Container port 80 |
| `--name my-nginx` | Container ka naam |
| `nginx` | Image name |

### 5. Verify Container

```bash
docker ps
```

**Output:**
```
CONTAINER ID   IMAGE   STATUS         PORTS
e11c2c09d79f   nginx   Up 1 minute    0.0.0.0:9090->80/tcp
```

### 6. Open in Browser

**Windows browser** mein:
```
http://localhost:9090
```

**Output:** **"Welcome to nginx!"** page. ✅

---

## ⚠️ Important Note

**Terminal ≠ Browser**

| Jagah | Kya |
|---|---|
| **Terminal** | `docker ps`, `docker run` |
| **Browser** | `http://localhost:9090` |

**URL terminal mein nahi chalti.**

---

## 🔧 Common Issue: Port Busy

**Error:**
```
docker: Error: ports are not available
```

**Kyun:** Port 8080 already busy (Windows ne use kiya).

**Solution:** Different port try karein:
```bash
docker rm -f my-nginx
docker run -d -p 9090:80 --name my-nginx nginx
```

**Port check (PowerShell):**
```powershell
netstat -ano | findstr :9090
```

---

## 📊 Docker Flow — Andar Kya Hota Hai

```
docker run nginx
    ↓
Docker Daemon
    ↓
1. Docker Hub se image pull
2. Image se container create
3. Container start (port 80)
4. Host port 9090 → Container port 80
    ↓
Browser: http://localhost:9090
    ↓
Nginx returns HTML page
```

---

## 💡 Key Concepts

- **Image** = Blueprint (read-only)
- **Container** = Running instance
- **Port mapping** = Host port → Container port
- **Detached** (`-d`) = Background mode
- **Docker Hub** = Images ka online store

---

## 🎯 Useful Commands

| Command | Kaam |
|---|---|
| `docker ps` | Running containers |
| `docker ps -a` | All containers |
| `docker images` | Downloaded images |
| `docker logs my-nginx` | Container logs |
| `docker exec -it my-nginx bash` | Container ke andar |
| `docker stop my-nginx` | Container band |
| `docker rm -f my-nginx` | Container delete |
| `docker rmi nginx` | Image delete |

---

**Status:** ✅ Nginx running at `http://localhost:9090`
**Version:** Docker 29.8.2
**Date:** 2026-10-09