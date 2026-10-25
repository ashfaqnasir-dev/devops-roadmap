Yeh poora content paste karein:

markdown
# Docker CLI — Complete Guide

> Docker CLI = Terminal se Docker control karne ka tool.

## Docker CLI Kya Hai?

Docker CLI (Command Line Interface) aap aur Docker Engine ke beech bridge hai.

Flow:
Aap (Terminal) → Docker CLI → Docker Engine → Container

text

- **Aap** — Commands likhte hain
- **Docker CLI** — Commands interpret karti hai
- **Docker Engine** — Actual kaam karta hai (background)
- **Container** — Aap ka application

## Command Ka Structure

```bash
docker run -d -p 8080:80 --name my-nginx nginx
│      │   │  │        │          │
│      │   │  │        │          └── Image name
│      │   │  │        └───────────── Container name
│      │   │  └────────────────────── Port mapping (host:container)
│      │   └───────────────────────── Detached mode (background)
│      └──────────────────────────── Sub-command
└─────────────────────────────────── Main command
3 Parts:

Part	Kya	Example
Main command	Base	docker
Sub-command	Kya karna	run, ps, pull
Flags	Kaise karna	-d, -p, -it
Common Sub-Commands
Sub-command	Purpose
run	Container chalao
ps	Running containers
ps -a	All containers
images	Downloaded images
pull	Image download
push	Image upload
stop	Container band
start	Container start
rm	Container delete
rmi	Image delete
logs	Container logs
exec	Container mein command
build	Image banao
inspect	Details dekho
Common Flags
Flag	Purpose
-d	Detached (background)
-it	Interactive terminal
-p 8080:80	Port mapping
-v /host:/container	Volume mount
-e KEY=value	Environment variable
--name	Container name
--rm	Auto-delete after stop
Practical Commands
Version Check
bash
docker --version
docker compose version
docker info
Containers Manage
bash
# Running containers
docker ps

# All containers (including stopped)
docker ps -a

# Container start
docker start my-nginx

# Container stop
docker stop my-nginx

# Container delete
docker rm my-nginx

# Force delete
docker rm -f my-nginx
Images Manage
bash
# Downloaded images
docker images

# Download image
docker pull nginx

# Specific version
docker pull nginx:alpine

# Delete image
docker rmi nginx
Run Container
bash
# Foreground
docker run nginx

# Background
docker run -d nginx

# With port mapping
docker run -d -p 8080:80 nginx

# With name
docker run -d -p 8080:80 --name my-nginx nginx

# Interactive shell
docker run -it ubuntu bash
Debug Container
bash
# Logs
docker logs my-nginx

# Live logs
docker logs -f my-nginx

# Shell access
docker exec -it my-nginx bash

# Container details
docker inspect my-nginx

# Resource usage
docker stats
Real Example — nginx
bash
# 1. Pull image
docker pull nginx:alpine

# 2. Run container
docker run -d -p 9090:80 --name my-nginx nginx

# 3. Verify
docker ps

# 4. Test
curl localhost:9090

# 5. Logs
docker logs my-nginx

# 6. Shell access
docker exec -it my-nginx bash

# 7. Stop
docker stop my-nginx

# 8. Delete
docker rm my-nginx

# 9. Delete image
docker rmi nginx:alpine
Useful One-Liners
bash
# All containers stop
docker stop $(docker ps -q)

# All containers delete
docker rm $(docker ps -aq)

# All images delete
docker rmi $(docker images -q)

# Cleanup unused
docker system prune -a

# Disk usage
docker system df
Docker CLI vs Docker Desktop
Feature	CLI	Desktop
Interface	Terminal	GUI
Speed	Fast	Slow
Scripting	Yes	No
Learning	Medium	Easy
Use case	Automation	Beginners
Both do same thing — different interface.

Aap Ke Setup Mein
Component	Location
Docker Desktop	Windows (GUI)
Docker CLI	WSL (Terminal)
Docker Engine	Inside Docker Desktop
Containers	Docker Engine
WSL mein:

bash
docker --version
Yeh Docker CLI hai — jo Docker Desktop Engine se connect hoti hai.

Common Issues
docker: command not found
Solution:

Docker Desktop kholein

Settings → Resources → WSL Integration

Ubuntu toggle ON

Apply & Restart

WSL terminal restart

Port already in use
Solution: Different port use karein:

bash
docker rm -f my-nginx
docker run -d -p 9091:80 --name my-nginx nginx
Container exits immediately
Solution: Logs dekho:

bash
docker logs <container-id>
Status: Complete
Last Updated: 2026-10-14

text

**Save karein.**

---

## 🎯 Ab Images Ko Repo Mein Kaise Daalein?

### **Tareeqa: `images/` Folder Banao**

**Structure:**
devops-practice/
├── 08-docker-containers/
│ ├── docker-cli.md
│ ├── setup.md
│ ├── wsl-integration-how-to.md
│ └── images/ ← Naya folder
│ ├── docker-version.png
│ ├── docker-desktop.png
│ └── nginx-browser.png

text

### **Step 1: Folder Banao**

```bash
cd /mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice/08-docker-containers
mkdir -p images
Step 2: Screenshots Save Karein
Windows mein:

Screenshot lein (Win + Shift + S)

Save karein: C:\Users\anpk\Desktop\ashfaqnasir-dev\devops-practice\08-docker-containers\images\

Naam: docker-version.png

Step 3: Markdown Mein Reference Karein
File: docker-cli.md

Yeh line add karein:

markdown
## Screenshots

### Docker Version

![Docker Version](./images/docker-version.png)

### Docker Desktop

![Docker Desktop](./images/docker-desktop.png)
Markdown syntax:

markdown
![Alt text](./images/filename.png)
Part	Matlab
!	Image
[Alt text]	Description (agar image load na ho)
(./images/file.png)	Path
Step 4: Commit + Push
bash
cd /mnt/c/Users/anpk/Desktop/ashfaqnasir-dev/devops-practice

git add 08-docker-containers/
git commit -m "Add Docker CLI guide with screenshots"
git push origin main
GitHub par images automatically render hongi.

📊 Images Ka Size
Type	Size	Recommendation
PNG screenshot	100-500 KB	✅ Good
JPG photo	50-200 KB	✅ Good
Large PNG	2-5 MB	⚠️ Compress karein
GIF	1-10 MB	⚠️ Avoid
Rule: 500 KB se kam rakhein — GitHub fast load karega.

🎯 Screenshots Ka Naam Convention
Screenshot	File name
Docker version	docker-version.png
Docker Desktop	docker-desktop.png
nginx browser	nginx-browser.png
WSL integration	wsl-integration.png
Container list	containers-list.png
Rule: lowercase, hyphens (-), no spaces.

📝 Mujhe Batayein
text
✅ 1. `docker-cli.md` file banayi?
✅ 2. Content paste kiya?
✅ 3. `images/` folder banaya?
✅ 4. Screenshots save kiye?
✅ 5. Markdown mein reference kiya?
✅ 6. Commit + push?
✅ 7. GitHub par dikh raha hai?
✅ 8. Screenshot bhejein

Sawal: [koi confusion ho]
💡 Aasan Summary
text
Docker CLI Markdown:

File: 08-docker-containers/docker-cli.md

Content:
  ✅ Docker CLI kya hai
  ✅ Command structure
  ✅ Sub-commands
  ✅ Flags
  ✅ Practical commands
  ✅ Real example (nginx)
  ✅ One-liners
  ✅ CLI vs Desktop
  ✅ Troubleshooting

75% Clarity:
  → Koi bhi padhe → samajh jaye
  → Practical use kar sake
  → Commands yaad rahein

Images Ka Tareeqa:
  1. images/ folder banao
  2. Screenshots save karo (PNG)
  3. Markdown mein reference:
     ![Alt text](./images/file.png)
  4. Commit + push
  5. GitHub par render honge

Fayde:
  ✅ Visual documentation
  ✅ Reference
  ✅ Portfolio
  ✅ Screenshots yaad dilayenge
Chalein, docker-cli.md banayein + screenshots add karein — output paste karein! 🚀

Ab documentation complete hoga. 💪


