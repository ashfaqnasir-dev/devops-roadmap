# 📦 08.04 Containers — Complete Guide

> **Container** Docker Image ka ek zinda (running) instance hota hai. Jahan Image ek static blueprint ya class ki tarah hoti hai, wahan container ek dynamic process ya object hota hai jo isolated environment mein execute hota hai. Container ka apna isolated filesystem, network interfaces, process tree, aur memory allocation hoti hai.

---

## Container Lifecycle State Machine

Ek container apni zindagi mein mukhtalif halaat (states) se guzarta hai:

```
                  ┌────────────────────────┐
                  │      docker create     │
                  └───────────┬────────────┘
                              │
                              ▼
┌──────────────┐  docker run  ┌────────────────────────┐  docker stop   ┌──────────────┐
│  Non-existent├─────────────►│        Created         ├───────────────►│   Exited /   │
└──────────────┘              └───────────┬────────────┘  (SIGTERM/KILL)│   Stopped    │
                                          │                             └──────┬───────┘
                               docker start│                                   │
                                          ▼                                    │ docker rm
                              ┌────────────────────────┐                       │
                              │        Running         │                       ▼
                              └───────────┬────────────┘                ┌──────────────┐
                                          │                             │   Deleted    │
                              docker pause│ ▲ docker unpause            └──────────────┘
                                          ▼ │
                              ┌────────────────────────┐
                              │         Paused         │
                              └────────────────────────┘
```

---

## 1. Run Containers (`docker run`)

`docker run` CLI ka sabse dynamic command hai. Yeh dar-asal do commands ka majmua hota hai: `docker create` (image se container banana) aur `docker start` (process initialize karna).

### A. Core Command Structure:

```bash
docker run [FLAGS] IMAGE[:TAG] [COMMAND] [ARG...]
```

### B. Daily Essential Flags Breakdown:

| Flag | Meaning | Maqsad |
| :--- | :--- | :--- |
| `-d` | Detached Mode | Container ko background daemon ke tor par chalana (terminal free rehta hai) |
| `-it` | Interactive + TTY | Terminal attach karke container ke sath direct interact karna |
| `--name` | Custom Container Name | Random hash/adjective ke bajaye pehchanne ke qabil naam dena |
| `-p` | Port Mapping | Host port ko container port se link karna (`-p <HostPort>:<ContainerPort>`) |
| `-e` | Environment Variable | Runtime configurations aur runtime credentials inject karna |
| `-v` | Volume / Mount | Host directory ya persistent volume bind karna |
| `--rm` | Auto Remove | Container exit / stop hote hi uski container layer ko khud delete kar dena |
| `--restart` | Restart Policy | Machine crash ya exit hone par behavior (`always`, `unless-stopped`, `on-failure`) |

### C. Practical Running Examples:

```bash
# 1. Background Nginx web server with port mapping
docker run -d \
  --name web-portal \
  -p 8080:80 \
  --restart unless-stopped \
  nginx:alpine

# 2. Database with Environment Variables & Volume
docker run -d \
  --name postgres-db \
  -p 5432:5432 \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=SuperSecretPass \
  -e POSTGRES_DB=devdb \
  -v pgdata:/var/lib/postgresql/data \
  postgres:16-alpine

# 3. Disposable one-time troubleshooting tool (Auto cleanup with --rm)
docker run --rm -it alpine:latest ping -c 4 google.com
```

---

## 2. List Containers (`docker ps` / `docker container ls`)

Machine par chalne wale containers ka status aur health monitor karne ke liye:

### A. Running Containers Dekhna:

```bash
docker ps
# ya modern syntax:
docker container ls
```

*Output Header:*
* `CONTAINER ID`: Unique short hexadecimal hash.
* `IMAGE`: Base image ka naam aur tag.
* `COMMAND`: Container ke andar chalne wala primary executable.
* `CREATED`: Container kab banaya gaya tha.
* `STATUS`: Current state (`Up 2 hours`, `Exited (0) 5 mins ago`).
* `PORTS`: Host aur container ke port mappings.
* `NAMES`: Container ka human-readable naam.

### B. Sabhi Containers (Running + Stopped) Dekhna:

Agar container crash ho gaya ho ya stop state mein ho, toh simple `docker ps` par nahi dikhta. Uske liye `-a` (all) flag lazmi hai:

```bash
docker ps -a
```

### C. Formatting & Filtering (Power User Tricks):

```bash
# Sirf Container IDs print karna (Scripts aur automation ke liye)
docker ps -q

# Sirf specific image ke chalte hue containers filter karna
docker ps --filter "ancestor=nginx:alpine"

# Sirf exited / stopped containers filter karna
docker ps --filter "status=exited"

# Custom neat table format dekhna
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 3. Stop, Start & Restart

### A. Stop Container (`docker stop`):

```bash
docker stop <container_name_or_id>
```

* **Process Under the Hood:** Docker container ke primary process (PID 1) ko pehle **`SIGTERM`** signal bhejta hai. Yeh container ko **10 seconds** ka waqt deta hai taake database connections close kar sake aur pending requests finish kar sake (Graceful Shutdown). Agar 10 seconds mein exit na ho, toh Docker **`SIGKILL`** bhej kar forcefully process terminate kar deta hai.

> ⚡ **Immediate Termination:** Agar intezar kiye baghair foran terminate karna ho:
> ```bash
> docker kill <container_name_or_id>   # Direct sends SIGKILL (-9)
> ```

### B. Start Container (`docker start`):

Stopped container ko usi pehle wali configuration aur data state ke sath dobara activate karna:

```bash
# Background mein start karna
docker start web-portal

# Start karke fauran interactive terminal attach karna
docker start -ai my-test-container
```

### C. Restart Container (`docker restart`):

Container ko stop karke naye sirey se chalana (configuration update ya process bounce karne ke liye):

```bash
docker restart web-portal
```

---

## 4. Remove Containers (`docker rm`)

Jab container ki zaroorat khatam ho jaye, toh disk space bachanay ke liye uski writable layer ko delete kiya jata hai.

### A. Standard Remove:

Pehle container ko `stop` karna parta hai, phir remove kiya jata hai:

```bash
# 1. Stop karein
docker stop web-portal

# 2. Delete karein
docker rm web-portal
```

### B. Forceful Remove (`-f`):

Running container ko bina pehle stop kiye terminate aur delete karna:

```bash
docker rm -f web-portal
```

### C. Bulk Cleanups (DevOps Workstation Maintenance):

```bash
# Tamam stopped containers ko ek dafa mein delete karna
docker container prune -f

# Advanced: Tamam exited containers dhoond kar delete karna via CLI piping
docker rm $(docker ps -a -q -f status=exited)

# Dangerous (Dev Environment): Tamam containers forcefully wipe out karna
docker rm -f $(docker ps -aq)
```

---

## 5. Exec Into Containers (`docker exec`)

`docker exec` running container ke andar ek naya process execute karta hai. Yeh containers ki internal state inspect karne, debugging karne, live files check karne, aur connectivity verify karne ka sabse ahem tool hai.

```
       Host Terminal
             │
             ▼ `docker exec -it <name> sh`
┌──────────────────────────────────────────────┐
│  Running Container Space                     │
│                                              │
│   PID 1: node server.js (Main Process)       │
│   PID 14: /bin/sh       (Spawned Shell) ◄────┼── Live Interactive Session
│                                              │
└──────────────────────────────────────────────┘
```

### A. Interactive Shell Kholna (`-it`):

```bash
# Alpine Linux based containers (Bash nahi hota, 'sh' hota hai)
docker exec -it web-portal sh

# Ubuntu / Debian based containers (Bash available hota hai)
docker exec -it web-portal bash
```

> 💡 **Exit without stopping:** Terminal se bahir nikalne ke liye `exit` likhein ya keyboard par `Ctrl + D` dabayein. Yeh sirf spawned shell ko band karega; aapka main application container **chalta rahega**.

### B. One-Off Ad-hoc Commands (Bina Shell Khole):

Shell session shuru kiye bina direct container ke andar command execute karke output host screen par lena:

```bash
# Container ke andar ki IP configuration dekhna
docker exec web-portal ip addr

# Database container ke andar direct query run karna
docker exec -it postgres-db psql -U admin -d devdb -c "SELECT version();"

# Root user ke tor par command run karna (permission bypass debugging)
docker exec -u 0 -it web-portal whoami
```

---

## 💡 Practical Cheatsheet: Commands Summary

| Action | Target Command |
| :--- | :--- |
| **Run in Background** | `docker run -d --name <name> -p <host>:<cont> <image>` |
| **View Active Containers** | `docker ps` |
| **View All (including stopped)** | `docker ps -a` |
| **Graceful Stop** | `docker stop <name>` |
| **Instant Kill** | `docker kill <name>` |
| **Start Stopped Container** | `docker start <name>` |
| **Reboot Container** | `docker restart <name>` |
| **Delete Stopped Container** | `docker rm <name>` |
| **Purge All Stopped** | `docker container prune` |
| **Interactive Terminal Shell** | `docker exec -it <name> sh` |
| **View Live Streaming Logs** | `docker logs -f <name>` |

---
**Status:** ✅ Complete