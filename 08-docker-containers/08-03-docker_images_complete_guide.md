# 🖼️ 08.03 Images — Complete Guide

> **Docker Image** ek lightweight, standalone aur executable software package hota hai jisme code run karne ke liye zaroori har cheez mojood hoti hai: application code, runtime, system libraries, tools aur default settings. Images **read-only (immutable)** hoti hain; jab inhein run kiya jata hai toh yeh **Containers** ban jati hain.

---

## The Image Lifecycle

Docker image ka safar development se production deployment tak in 5 core marahil se guzarta hai:

```
                  [ Dockerfile ]
                        │
                        ▼ (1. docker build)
           [ Local Image: myapp:dev ]
                        │
                        ▼ (2. docker tag)
    [ Tagged Image: registry/user/myapp:v1.0 ]
                        │
                        ▼ (3. docker push)
         [ Remote Registry (Docker Hub / ACR) ]
                        │
                        ▼ (4. docker pull)
           [ Production Host Server ]
                        │
                        ▼ (5. docker run)
               [ Running Container ]
```

---

## 1. Pull Images (`docker pull`)

`docker pull` command remote registry (by default **Docker Hub**) se pre-built images aapki local machine par download karti hai.

### A. Anatomy of an Image Name:

```
docker pull [registry_host/][repository_owner/]image_name[:tag]
```

* **Official Docker Hub Image:** `docker pull nginx:alpine` (Registry aur user prefix optional hota hai).
* **Community / User Image:** `docker pull bitnami/redis:7.2`
* **Third-Party / Private Cloud Registry:** `docker pull myregistry.azurecr.io/backend:1.0`

### B. Common Pull Commands:

```bash
# Specific version/tag pull karna (Recommended)
docker pull python:3.11-slim

# Agar koi tag na lagayein, toh default 'latest' tag pull hoga
docker pull ubuntu

# Multi-architecture platform specify karke pull karna
docker pull --platform linux/amd64 node:20-alpine

# Local system par mojood images list karna
docker image ls
# ya
docker images
```

> ⚠️ **The `latest` Tag Trap:** `latest` ka matlab "hamesha newest stable release" nahi hota, balki yeh sirf woh tag hai jo build karte waqt default lagta hai. Production pipelines mein hamesha immutable explicit tags (jaise `node:20.11-alpine` ya Git commit SHA `sha-a8f102c`) use karein.

---

## 2. Build Images (`docker build`)

`docker build` command Dockerfile ki instructions ko read karke local image create karti hai.

### A. Syntax & Build Context:

```bash
docker build [OPTIONS] PATH | URL
```

```bash
# Current directory (.) ke build context se image banana
docker build -t my-web-app:1.0 .

# Specific custom Dockerfile path specify karna
docker build -f docker/Dockerfile.prod -t my-web-app:prod .

# Build arguments pass karna
docker build --build-arg NODE_ENV=production -t my-web-app:v2 .

# Cache bypass karke fresh build banana
docker build --no-cache -t my-web-app:fresh .
```

### B. Build Context Kya Hai?

Terminal mein aakhri dot (`.`) build context path hota hai. Docker client is folder ki tamam files Docker daemon ko bhejta hai.
* Agar context folder mein 5 GB ke unnecessary videos ya `.git` files hon, toh build shuru hone se pehle transfer slow ho jayega.
* **Solution:** Root par `.dockerignore` file lazmi banayein:
  ```text
  .git
  node_modules
  dist
  *.log
  .env
  ```

---

## 3. Tag Images (`docker tag`)

Docker mein image tagging bilkul Git tags ya alias pointer ki tarah kaam karti hai. Ek hi Image ID ke muta'addid (multiple) tags ho sakte hain bina extra disk space liye.

### A. Tagging Syntax:

```bash
docker tag <source_image[:tag]> <target_image[:tag]>
```

### B. Standard Enterprise Tagging Conventions:

```bash
# 1. Local image ko remote repository format mein tag karna
docker tag my-app:test username/my-app:1.0.0

# 2. Semantic Versioning + Floating Tags (Industry Standard Practice)
docker tag my-app:build-94 username/my-app:1.2.3
docker tag my-app:build-94 username/my-app:1.2
docker tag my-app:build-94 username/my-app:latest

# 3. Cloud Registry (Azure ACR / AWS ECR) ke liye tag karna
docker tag my-app:1.0.0 mycompany.azurecr.io/services/auth-api:v1.0.0
```

> 💡 Tagging naye layers create nahi karti; yeh sirf usi existing Image ID par ek naya reference pointer set kar deti hai. Verify karne ke liye `docker images` chalayein: dono ka Image ID bilkul same hoga.

---

## 4. Push to Registry (`docker push`)

Build aur tag hone ke baad image ko team ke sath share karne ya cloud cluster par deploy karne ke liye remote container registry par upload kiya jata hai.

```
Local Host                  Docker Hub / Azure ACR
┌──────────────┐            ┌──────────────────────┐
│  Image Tag   │ ──push──►  │ Layer 1 (Exists? Skip)│
│  7 Layers    │            │ Layer 2 (Uploaded)   │
└──────────────┘            │ Layer 3 (Uploaded)   │
                            └──────────────────────┘
```

### A. Workflow for Docker Hub:

```bash
# 1. Authenticate with registry
docker login -u your_username

# 2. Image push karein
docker push your_username/my-app:1.0.0

# 3. Logout when done (Security best practice)
docker logout
```

### B. Workflow for Azure Container Registry (ACR):

```bash
# Azure CLI ke zariye ACR par login
az acr login --name myregistry

# ACR target tag image push karna
docker push myregistry.azurecr.io/services/auth-api:v1.0.0
```

> 💡 **Layer Deduplication:** Registry sirf wahi layers upload karegi jo pehle se registry par mojood nahi hain. Agar base OS layer pehle se kisi doosri image mein upload ho chuki hai, toh Docker push us layer ke aage `Mounted from ...` ya `Layer already exists` likh kar band-width bacha lega.

---

## 5. Image Layers & Storage Drivers

Docker images **Union File System (UnionFS / Overlay2)** par mabni hoti hain. Image alag alag read-only layers ka ek stack hoti hai.

```
┌────────────────────────────────────────────────────────┐
│  [Container Layer] - Read/Write (Ephemeral, Topmost)   │  ◄── Running Container writes here
├────────────────────────────────────────────────────────┤
│  Layer 4: CMD ["node", "app.js"]         (~0 B)        │
├────────────────────────────────────────────────────────┤
│  Layer 3: COPY . /app                    (~12 MB)      │  ◄── Application Code
├────────────────────────────────────────────────────────┤
│  Layer 2: RUN npm install                (~85 MB)      │  ◄── Dependencies
├────────────────────────────────────────────────────────┤
│  Layer 1: FROM node:20-alpine            (~180 MB)     │  ◄── Base Runtime & OS
└────────────────────────────────────────────────────────┘
          ▲
          └── All layers below the Container layer are IMMUTABLE (Read-Only)
```

### A. Layer Creation Rules:
1. Sirf **`RUN`**, **`COPY`**, aur **`ADD`** instructions nayi physical filesystem layers banati hain (jinse size barhta hai).
2. Metadata instructions (jaise `CMD`, `ENTRYPOINT`, `ENV`, `EXPOSE`, `WORKDIR`) sirf image configuration JSON update karti hain, storage layer create nahi karti.

### B. Copy-on-Write (CoW) Mechanism:
* Jab container start hota hai, toh Docker tamam read-only layers ke upar ek patli **Read/Write Container Layer** add karta hai.
* Jab running container kisi file ko modify karta hai, toh woh original image layer ko modify nahi karta; balki file ko read-only layer se upar container layer mein copy karta hai aur modify karta hai (**Copy-on-Write**).
* Agar 100 containers ek hi image se run ho rahe hon, toh woh sabhi **niche ki wahi identical read-only layers share** karte hain—RAM aur disk space ki zabardast bachat hoti hai!

### C. Inspecting Image Layers:

```bash
# Image ke layers aur execution history dekhna
docker history my-web-app:1.0

# Complete low-level JSON details (layers hashes, env, entrypoint)
docker image inspect my-web-app:1.0
```

---

## 💡 Practical Cheatsheet: Commands Summary

| Task | Command |
| :--- | :--- |
| **Download Image** | `docker pull <image>:<tag>` |
| **Build from Dockerfile** | `docker build -t <name>:<tag> .` |
| **Re-tag for Registry** | `docker tag <source> <target_repo>:<tag>` |
| **Upload Image** | `docker push <target_repo>:<tag>` |
| **Inspect Layer History** | `docker history <image>` |
| **Delete Local Image** | `docker rmi <image_name_or_id>` |
| **Clean Dangling Images**| `docker image prune` |

---
**Status:** ✅ Complete