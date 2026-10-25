# 🌐 08.05 Docker Volumes & Networks

Containers naturally stateless hotay hain (container delete hone par data khatam ho jata hai) aur isolated hotay hain. Volumes persistent data store karne ke liye aur Networks containers ke darmiyan communication ke liye use hotay hain.

---

## 💾 Storage (Volumes & Mounts)

### 08.05.01 Named Volumes
Docker ke zariye manage hone wali persistent storage jo container delete hone ke baad bhi mehfooz rehti hai.

- **Description:** Yeh Docker engine ke internal directory (`/var/lib/docker/volumes/`) mein create hoti hai. Database files aur persistent application data ke liye best practice hai kyunki iska access Docker ke paas hota hai, host OS permissions ke maslay nahi aate.
- **Commands:**
  ```bash
  # Volume create karein
  docker volume create my_data

  # Container ke sath attach karein (-v volume_name:container_path)
  docker run -d --name db -v my_data:/var/lib/mysql mysql:8.0

  # Volumes list karein
  docker volume ls
  ```

### 08.05.02 Bind Mounts
Host machine (aapke computer) ke kisi specific folder ya file ko direct container ke andar mount karna.

- **Description:** Named volume ke bar'aks, yeh host ke kisi bhi absolute path ko point karta hai. Development ke waqt live-reloading ke liye perfect hota hai kyunki host par code change karte hi container ke andar foran reflect ho jata hai.
- **Example:**
  ```bash
  # Current project folder ko container ke /app folder se link karna
  docker run -d -p 3000:3000 -v $(pwd):/app --name web-dev node:18
  ```
- **Difference Tip:**
  - `Named Volume`: Production databases aur persistent storage ke liye.
  - `Bind Mount`: Local development aur source code live sync ke liye.

---

## 🔌 Networks

### 08.05.03 Bridge Networks (Default)
Docker ka default private virtual network jisme har container ko ek internal IP address milta hai.

- **Description:** Jab aap koi network specify nahi karte, container default `bridge` network se connect hota hai.
- **Limitation:** Default bridge network par containers ek doosre ko unke container name (DNS) se call nahi kar sakte, sirf raw IP address ke zariye connect ho sakte hain.
- **Check Command:**
  ```bash
  docker network inspect bridge
  ```

### 08.05.04 Host Networks
Container ki network isolation ko bilkul khatam kar dena.

- **Description:** Container ko koi alag virtual IP ya private network nahi milta; yeh direct host machine ke network interface aur ports ko use karta hai. Isme `-p` port mapping ki zaroorat nahi hoti.
- **Use Case:** High-performance web servers jahan network overhead minimize karna ho.
- **Command:**
  ```bash
  docker run -d --network host --name my-server nginx
  ```
- *(Note: Host networking mainly Linux par natively kaam karta hai; Docker Desktop on macOS/Windows par iske limitations hain).*

### 08.05.05 Custom Networks (User-defined Bridge)
Apna custom virtual bridge network banana taake multiple containers aapas mein easily aur securely communicate kar sakein.

- **Description:** Iska sabse bada faida **Automatic DNS Resolution** hai. Containers ek doosre ke naam (e.g., `http://db:5432` ya `http://backend:8000`) se connect kar sakte hain, IP yaad rakhne ki zaroorat nahi padti.
- **Workflow & Commands:**
  ```bash
  # 1. Custom bridge network banayein
  docker network create app-net

  # 2. Database container ko is network par chalayein
  docker run -d --name my-db --network app-net mongo

  # 3. Backend container ko same network par chalayein (yeh 'my-db' naam se communicate karega)
  docker run -d --name my-api --network app-net -p 5000:5000 my-api-image

  # Networks list check karein
  docker network ls
  ```