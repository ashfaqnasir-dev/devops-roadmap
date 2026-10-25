# 🐳 08.01 Docker Basics — Complete Guide

> Software development mein purana mashhoor bahana hota tha: *"Yeh meri machine par chal raha hai, production par pata nahi kyun crash ho gaya!"* (The *"Works on my machine"* problem). **Docker** is maslay ko hamesha ke liye khatam karta hai. Yeh application aur uski tamam dependencies, system libraries, configuration files aur runtimes ko ek lightweight, self-contained unit mein pack kar deta hai jise **Container** kehte hain.

---

## 1. What is Docker? (Docker Kya Hai?)

Docker ek open-source containerization platform hai jo applications ko develop, ship aur run karne ke liye use hota hai.

```
       Code + Libraries + Runtimes + Configs
                         │
                         ▼
             [ Docker Engine / Build ]
                         │
                         ▼
                 [ Docker Image ]  (Blueprint / Read-only template)
                         │
                         ▼ (docker run)
               [ Running Container ]  (Live, running instance)
```

### Core Components of Docker Architecture:
1. **Docker Daemon (`dockerd`):** Background service (engine) jo host machine par chalta hai aur images, containers, networks aur storage volumes ko manage karta hai.
2. **Docker CLI (`docker`):** Command-line client jiske zariye engineer Docker daemon ke sath baat karta hai (e.g., `docker run`, `docker build`).
3. **Docker Image:** Application ka ek immutable (read-only) snapshot ya package.
4. **Docker Container:** Us image ka ek live, runnable instance.
5. **Docker Registry:** Images ko store karne ka markaz (jaise Docker Hub, GitHub Packages, ya Azure Container Registry - ACR).

---

## 2. Containers vs Virtual Machines (VMs)

Dono technologies isolation provide karti hain, magar unka architecture bunyadi tor par mukhtalif hai:

```
          [ Virtual Machines ]                              [ Containers ]
┌───────────────────────────────────────┐       ┌───────────────────────────────────────┐
│  App 1       │  App 2       │  App 3  │       │  App 1       │  App 2       │  App 3  │
├──────────────┼──────────────┼─────────┤       ├──────────────┼──────────────┼─────────┤
│  Bins/Libs   │  Bins/Libs   │Bins/Libs│       │  Bins/Libs   │  Bins/Libs   │Bins/Libs│
├──────────────┼──────────────┼─────────┤       ├───────────────────────────────────────┤
│ Guest OS 1   │ Guest OS 2   │Guest OS3│       │       Docker Container Engine         │
├───────────────────────────────────────┤       ├───────────────────────────────────────┤
│        Hypervisor (Type 1/2)          │       │           Host OS Kernel              │
├───────────────────────────────────────┤       ├───────────────────────────────────────┤
│          Host Infrastructure          │       │          Host Infrastructure          │
└───────────────────────────────────────┘       └───────────────────────────────────────┘
```

| Khasiyat | Virtual Machine (VM) | Docker Container |
| :--- | :--- | :--- |
| **OS Architecture** | Har VM ke paas apna complete **Guest OS** hota hai | Host machine ke **Linux Kernel** ko aapas mein share karte hain |
| **Boot Time** | Chand minute (poora OS boot hota hai) | **Milliseconds se chand seconds** |
| **Resource Usage** | Heavy (Gigabytes of RAM & storage per VM) | **Extremely Lightweight** (Megabytes of RAM) |
| **Isolation Mechanism** | Hardware-level virtualization (Hypervisor) | OS-level isolation (**Linux Namespaces & cgroups**) |
| **Portability** | Heavy VM images (`.vmdk`, `.iso` multiple GBs) | Lightweight portable layers (10MB - 300MB) |

> 💡 **Kernel Isolation Key:** Linux containers host kernel ke do core features use karte hain:
> - **Namespaces:** Process IDs, Network interfaces, aur Mount points ko isolate karta hai (container ko lagta hai ke woh poori machine par akela hai).
> - **cgroups (Control Groups):** CPU, Memory, aur I/O limits enforce karta hai taake ek container doosre container ke resources na nigal sake.

---

## 3. Install Docker (Ubuntu / Linux Quick Setup)

Modern production setups mein standard Linux servers par Docker Engine install karne ka industry standard tareeqa:

```bash
# 1. System packages update karein aur zaroori tools install karein
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 2. Docker ka official GPG key add karein
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Official Docker apt repository configure karein
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Docker Engine aur CLI install karein
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Non-root user ko docker group mein shamil karein (bina 'sudo' chalane ke liye)
sudo usermod -aG docker $USER
newgrp docker

# 6. Installation verify karein
docker run hello-world
```

---

## 4. Docker CLI Cheatsheet (Daily DevOps Commands)

### A. Container Lifecycle Management:

```bash
# 1. Naya container background mein run karna (detach mode) with port forward
docker run -d -p 8080:80 --name my-web-app nginx:alpine

# 2. Running containers dekhna
docker ps

# 3. Tamam containers (running aur stopped) dekhna
docker ps -a

# 4. Container stop aur start karna
docker stop my-web-app
docker start my-web-app

# 5. Container remove / delete karna
docker rm my-web-app
docker rm -f my-web-app   # Forcefully remove running container
```

### B. Image Operations:

```bash
# Public registry se image pull karna
docker pull python:3.11-slim

# Local machine par mojood tamam images list karna
docker images

# Purani / unneeded image delete karna
docker rmi python:3.11-slim

# Unused containers, networks aur images ek command se saaf karna
docker system prune -a --volumes
```

### C. Troubleshooting & Debugging Inside Containers:

```bash
# Container ke live logs dekhna (-f = follow)
docker logs -f my-web-app

# Running container ke andar interactive terminal shell kholna
docker exec -it my-web-app sh     # (ya 'bash' agar installed ho)

# Container ke resource usage stats (CPU, RAM, Network I/O) live monitor karna
docker stats

# Container ki low-level details (IP address, mounts, environment vars) inspect karna
docker inspect my-web-app
```

---

## 5. Docker Hub (The Global Image Registry)

**Docker Hub** dunya ka sabse bara cloud-based image repository hai jahan official images (Ubuntu, Node.js, Redis, Postgres) aur community images host hoti hain.

```
[ Local Workstation ] ──( docker push )──► [ Docker Hub (hub.docker.com) ]
                                                        │
                                                        ▼ ( docker pull )
                                             [ Production Server / K8s ]
```

### A. Official vs Community Images:
- **Official Images (e.g., `nginx`, `redis`, `node`):** Docker team aur verified maintainers ki taraf se scan aur curate ki gayi images. Inke naam ke aage koi username nahi hota (`docker pull nginx`).
- **Community / User Images (e.g., `bitnami/redis`, `mycompany/auth-api`):** Individuals ya private companies ki banayi gayi images jinke aage account username ya organization prefix lazmi hota hai.

### B. Docker Hub Workflow:

```bash
# 1. Docker CLI se login karna
docker login -u your_username

# 2. Local image ko apne Docker Hub username ke mutabiq tag karna
# Format: docker tag <source-image> <username>/<repo-name>:<tag>
docker tag my-local-app:latest your_username/my-local-app:1.0.0

# 3. Docker Hub par image push karna
docker push your_username/my-local-app:1.0.0
```

---

## 💡 Practical Cheatsheet: Port Mapping Mental Model

```
docker run -d -p 8080:80 nginx
                 │    │
                 │    └──► Container Port (Nginx listens inside container)
                 └──────── Host Server Port (Browser hits: http://localhost:8080)
```

> Agar host port busy ho, toh aap host port badal sakte hain (e.g. `-p 9090:80`), container ke andar Nginx ko pata bhi nahi chalega ke bahir port badal chuka hai.

---
**Status:** ✅ Complete