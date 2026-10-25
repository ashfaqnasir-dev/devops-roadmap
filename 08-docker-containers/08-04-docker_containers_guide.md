# 📦 08.04 Docker Containers

Docker Container ek running instance hota hai jo image se banta hai. Yeh ek isolated environment provide karta hai jisme aapki app apni dependencies ke sath run hoti hai.

---

### 08.04.01 Run Containers
Kisi Docker image se ek naya container create aur start karne ke liye use hota hai.

- **Description:** Yeh command background (detached mode) ya foreground mein container chala sakti hai, ports bind kar sakti hai, aur container ko custom naam de sakti hai.
- **Common Flags:**
  - `-d`: Detached mode (background mein chalane ke liye)
  - `-p <host_port>:<container_port>`: Port mapping
  - `--name <name>`: Container ko specific naam dena
- **Command:**
  ```bash
  docker run [options] <image_name>
  ```
- **Example:**
  ```bash
  docker run -d -p 8080:80 --name my-web-server nginx
  ```

---

### 08.04.02 List Containers
System par maujood containers dekhne aur unka status check karne ke liye use hota hai.

- **Description:** Default par yeh sirf active (running) containers dikhata hai, lekin flag use karke band containers bhi dekhe ja sakte hain.
- **Commands:**
  - Running containers dekhne ke liye:
    ```bash
    docker ps
    ```
  - Saare containers (running + stopped) dekhne ke liye:
    ```bash
    docker ps -a
    ```

---

### 08.04.03 Stop / Start / Restart
Running containers ki lifecycle ko control karne ke liye use hota hai.

- **`stop`**: Running container ko gracefully shutdown karta hai.
  ```bash
  docker stop <container_id_or_name>
  ```
- **`start`**: Pehle se stopped container ko dobara chalata hai.
  ```bash
  docker start <container_id_or_name>
  ```
- **`restart`**: Container ko pehle stop aur phir foran start karta hai (configuration reload ya crash ke baad useful).
  ```bash
  docker restart <container_id_or_name>
  ```
- **Example:**
  ```bash
  docker stop my-web-server
  docker start my-web-server
  ```

---

### 08.04.04 Remove Containers
Un-needed ya stopped containers ko disk space free karne ke liye delete karta hai.

- **Description:** Default par running container delete nahi hota (pehle stop karna padta hai), lekin `-f` flag se force remove bhi kiya ja sakta hai.
- **Commands:**
  - Stopped container delete karna:
    ```bash
    docker rm <container_id_or_name>
    ```
  - Running container ko zabardasti remove karna:
    ```bash
    docker rm -f <container_id_or_name>
    ```
  - Tamam stopped containers ko ek sath delete karna:
    ```bash
    docker container prune
    ```

---

### 08.04.05 Exec into Containers
Kisi chalte hue container ke andar ghus kar commands run karne ya debugging karne ke liye use hota hai.

- **Description:** Yeh command container ke andar terminal shell (bash/sh) open kar deti hai taake aap files inspect ya debug kar sakein.
- **Flags:**
  - `-i`: Interactive mode
  - `-t`: Pseudo-TTY allocate karta hai (terminal interface ke liye)
- **Command:**
  ```bash
  docker exec -it <container_id_or_name> <shell_or_command>
  ```
- **Example:**
  ```bash
  docker exec -it my-web-server bash
  # Agar bash na mile to sh use karein:
  docker exec -it my-web-server sh
  ```