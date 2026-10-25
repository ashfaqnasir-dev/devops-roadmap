# 🛡️ 08.07 Docker Production & Best Practices

Production environment mein containers chalana local development se kaafi mukhtalif hota hai. Production containers ko **secure**, **lightweight**, **fault-tolerant**, aur **resource-efficient** hona chahiye.

---

### 08.07.01 Minimal & Distroless Base Images

Badi standard images (jaise full `ubuntu` ya `python:3.11`) ke bajaye choti aur focused images use karein.

* **Kyun zaroori hai?** Choti images download aur deploy jaldi hoti hain aur unka attack surface (vulnerabilities) bohot kam hota hai.
* **Best Choices:**
  * `*-alpine`: Bohot lightweight (5MB base) Linux distro.
  * `*-slim`: Debian ka stripped-down version (Python/Node ke liye best balanced option).
  * `Distroless` (Google): Isme package manager ya bash shell tak nahi hota, sirf runtime aur application code hota hai.
* **Example:**
  ```dockerfile
  # Bad: Full image (~1 GB)
  FROM python:3.11

  # Good: Slim image (~150 MB)
  FROM python:3.11-slim
  ```

---

### 08.07.02 Non-Root User Execution (Security Hardening)

Default par Docker containers `root` user ke taur par chalte hain. Production mein yeh bohot bada security risk hai.

* **Kyun zaroori hai?** Agar container compromise ho jaye, to attacker host system par root privileges hasil karne ki koshish kar sakta hai (container breakout).
* **Fix:** Hamesha dedicated non-root user banayein aur `USER` directive switch karein.
* **Example:**
  ```dockerfile
  FROM node:18-alpine

  WORKDIR /app
  COPY package*.json ./
  RUN npm ci --only=production
  COPY . .

  # Non-root user create ya switch karein
  USER node

  CMD ["node", "server.js"]
  ```

---

### 08.07.03 Proper Layer Caching & `.dockerignore`

Build time aur image size ko control karne ke liye build instructions ka sequence bohot matter karta hai.

* **Cache Optimization:** Un cheezon ko pehle run karein jo kam change hoti hain (jaise dependencies install karna), aur application code ko aakhri steps mein copy karein.
* **`.dockerignore`:** Hamesha create karein taake unnecessary files (`.git`, `node_modules`, `.env`, temp logs) image ke andar na jayein.
* **Optimized Dockerfile Order:**
  ```dockerfile
  FROM python:3.11-slim
  WORKDIR /app

  # 1. Sirf requirements copy karein aur install karein (cached rahega)
  COPY requirements.txt .
  RUN pip install --no-cache-dir -r requirements.txt

  # 2. Source code baad mein copy karein (code badalne par pip install dobara nahi chalega)
  COPY . .
  ```

---

### 08.07.04 Healthchecks & Restart Policies

Production orchestrator ko pata hona chahiye ke container sirf "running" hai ya waqai traffic accept karne ke qabil hai.

* **`HEALTHCHECK`:** Batata hai ke app internally theek kaam kar rahi hai ya deadlocked ho chuki hai.
* **`restart: unless-stopped` / `always`:** System reboot ya crash ke baad container khud ba khud dobara start ho sake.
* **Example in Dockerfile / Compose:**
  ```dockerfile
  HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1
  ```
  ```yaml
  services:
    web:
      image: my-app:prod
      restart: unless-stopped
  ```

---

### 08.07.05 Resource Limits (CPU & Memory)

Kisi ek container ko host server ki saari RAM ya CPU consume karne se rokna (OOM killer protection).

* **Kyun zaroori hai?** Agar ek container mein memory leak ho jaye, to wo pooray server ko freeze kar sakta hai.
* **Compose Example:**
  ```yaml
  services:
    api:
      image: my-api:v1
      deploy:
        resources:
          limits:
            cpus: '0.50'      # Maximum 50% of single CPU core
            memory: 512M      # Maximum 512 MB RAM
          reservations:
            cpus: '0.25'
            memory: 256M
  ```

---

### 08.07.06 Stateless Containers & Secrets Management

Container ke andar hardcoded credentials ya persistent state kabhi mat rakhein.

* **Secrets:** Passwords aur API keys ko image ke andar `ENV` ya Dockerfile mein hardcode **kabhi na karein**. Docker secrets ya environment injection tools (e.g., HashiCorp Vault, AWS Secrets Manager) use karein.
* **Statelessness:** Containers ko disposable rakhein. User uploads, logs, aur session data ko containers ke andar store na karein, balki S3 bucket, centralized logging (e.g., Datadog, ELK), aur Redis jaise external services par push karein.

---

### 08.07.07 Log Management (Log Rotation)

Default standard output (`stdout` / `stderr`) logs agar limit na kiye jayein to server ki hard drive full ho sakti hai.

* **Log Driver Configuration (`docker-compose.yml`):**
  ```yaml
  services:
    web:
      image: my-app
      logging:
        driver: "json-file"
        options:
          max-size: "10m"     # Max 10MB per file
          max-file: "3"       # Maximum 3 log files retain hongi
  ```