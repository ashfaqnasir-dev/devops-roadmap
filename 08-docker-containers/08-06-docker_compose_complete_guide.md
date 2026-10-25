# 🎼 08.06 Docker Compose — Complete Guide

> Jab aapki application mein ek se zyada containers shamil hon—jaise Frontend (React/Nginx), Backend API (Node/Python), Database (Postgres), aur Cache (Redis)—toh har container ko lambi `docker run` commands se alag alag chalana bohot mushkil ho jata hai. **Docker Compose** ek tool hai jo multi-container Docker applications ko ek single YAML file ke zariye define aur run karne ki sahulat deta hai.

## Multi-Container Architecture with Docker Compose

```
                     [ docker-compose.yml ]
                                │
               (docker compose up -d)
                                │
        ┌───────────────────────┴───────────────────────┐
        ▼                                               ▼
[ Default Isolated Network: myapp_default (Auto-Created) ]
 ├── [ Service: web ]      (Frontend / Reverse Proxy :80)
 ├── [ Service: api ]      (Backend App :3000)
 ├── [ Service: cache ]    (Redis Cache :6379)
 └── [ Service: db ]       (PostgreSQL DB :5432)
        │
        └──► [ Named Volume: db_data ] (Persisted on Host)
```

> 💡 **Legacy vs Modern CLI:** 
> * Purana tarika: `docker-compose up` (Python-based standalone binary - Deprecated)
> * Naya tarika: `docker compose up` (Docker CLI ka built-in Go plugin - **Recommended standard**)

---

## 1. `docker-compose.yml` (The Blueprint File)

`docker-compose.yml` project ke root par banayi jaati hai. Yeh application ke tamam components ka declarative blueprint hoti hai.

### Modern Specification Rule:
Purane Compose files mein sabse upar `version: '3.8'` likhna zaroori hota tha. Modern Compose specification ke tehat `version` attribute ab **optional / deprecated** ho chuka hai; Docker Compose CLI file ko automatically latest compose specification ke mutabiq parse kar leta hai.

```yaml
# docker-compose.yml Structure
services:
  # Container definitions yahan aayengi
volumes:
  # Shared / persistent storage volumes
networks:
  # Custom communication networks
```

---

## 2. Services (`services`)

Compose file ke andar har container ek **Service** kehlata hai. Service define karti hai ke container kis image se banega, kaun si ports expose hongi, aur dependencies kya hain.

### Key Service Directives:

| Directive | Maqsad | Example |
| :--- | :--- | :--- |
| `image` | Pre-built registry image pull karna | `image: postgres:16-alpine` |
| `build` | Local Dockerfile se image build karna | `build: ./backend` ya `build: { context: ., dockerfile: Dockerfile }` |
| `ports` | Host aur container port bind karna | `- "8080:80"` (`Host:Container`) |
| `restart` | Reboot / crash par behavior | `restart: unless-stopped` |
| `depends_on` | Startup sequence control karna | Container tab chaley jab dependent database ready/started ho |

### Service Startup Order (`depends_on` with Healthchecks):
Sirf `depends_on: [db]` likhne se container sirf tab chalega jab db start ho, lekin ho sakta hai database abhi queries accept karne ke qabil na ho. Real production mein **Healthcheck condition** lagayi jaati hai:

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_PASSWORD: secretpassword
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  backend:
    build: ./backend
    depends_on:
      db:
        condition: service_healthy   # DB poora ready hone par hi backend start hoga
```

---

## 3. Volumes & Networks in Compose

Docker Compose automatically project folder ke naam par ek default bridge network bana deta hai, jisse tamam services ek doosre ko **service name** se DNS ke zariye ping kar sakti hain.

### A. Volume Configuration:
```yaml
services:
  db:
    image: postgres:16-alpine
    volumes:
      - db_data:/var/lib/postgresql/data       # Named volume (persistent)
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro  # Bind mount (read-only)

volumes:
  db_data:                                     # Root level par declare karna zaroori hai
    driver: local
```

### B. Isolated Custom Networks:
Security behtar karne ke liye frontend aur database ko alag networks par rakha ja sakta hai:

```yaml
services:
  frontend:
    image: nginx:alpine
    networks:
      - public_net

  api:
    build: ./api
    networks:
      - public_net
      - private_net

  db:
    image: postgres:16-alpine
    networks:
      - private_net                            # DB public network se bilkul isolated hai

networks:
  public_net:
  private_net:
```

---

## 4. Environment Variables (`environment` vs `env_file`)

Docker Compose mein variables inject karne ke do aam tareeqay hain:

### A. Direct Inline `environment` Block:
```yaml
services:
  api:
    image: my-api:latest
    environment:
      NODE_ENV: production
      PORT: 3000
      DB_HOST: db                              # Service name used as DNS hostname
```

### B. External `.env` File (`env_file`):
Secrets aur dynamic configurations ko YAML se bahir rakhne ke liye root par `.env` file banayein:

```bash
# .env file
DATABASE_USER=appuser
DATABASE_PASSWORD=SuperSecretPass123!
```

Compose file ke andar direct interpolate karein:
```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DATABASE_USER}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
```

---

## 5. Complete Practical Example: Full-Stack App

Yeh ek complete, production-ready `docker-compose.yml` file hai:

```yaml
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - api
    restart: always

  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      PORT: 5000
      DATABASE_URL: postgres://postgres:${DB_PASSWORD}@db:5432/appdb
      REDIS_HOST: cache
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_started
    restart: always

  cache:
    image: redis:7-alpine
    restart: unless-stopped

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  postgres_data:
```

---

## 6. Docker Compose CLI Cheatsheet (`up`, `down`, & Lifecycle)

| Maqsad | CLI Command |
| :--- | :--- |
| **Tamam containers background mein chalana** | `docker compose up -d` |
| **Code changes ke baad image rebuild karke chalana** | `docker compose up -d --build` |
| **Tamam running containers aur networks stop/remove karna** | `docker compose down` |
| **Containers + Networks + Volumes sab wipe out karna** | `docker compose down -v` |
| **Compose stack ke live logs stream karna** | `docker compose logs -f` |
| **Sirf specific service ke logs dekhna** | `docker compose logs -f api` |
| **Running services ka status dekhna** | `docker compose ps` |
| **Running service ke andar interactive terminal kholna** | `docker compose exec api sh` |
| **Services ko bina delete kiye stop ya restart karna** | `docker compose stop` / `docker compose restart` |

> 🎯 **Summary:** Docker Compose complex multi-container setups ko ek single reproducible command (`docker compose up -d`) mein convert kar deta hai, jo local testing, staging setups aur CI/CD integration ko intihayi aasan bana deta hai.

---
**Status:** ✅ Complete