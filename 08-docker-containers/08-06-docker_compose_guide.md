# 🐙 08.06 Docker Compose

Docker Compose ek tool hai jo multi-container Docker applications ko define aur run karne ke liye use hota hai. Ek single YAML file ke zariye aap multiple containers, unke networks, aur volumes ko ek sath manage kar sakte hain.

### 08.06.01 `docker-compose.yml`

Compose configuration ki main blueprint file hoti hai.

* **Description:** Yeh ek YAML formatted file hoti hai jisme aap batate hain ke aapki application mein kaunse containers (services) chalenge, kaunse ports expose honge, aur unki configurations kya hongi.

* **Basic Structure:**

  ```
  version: '3.8'
  
  services:
    # Services yahan define hoti hain
  
  volumes:
    # Top-level persistent volumes yahan aate hain
  
  networks:
    # Top-level custom networks yahan aate hain
  
  ```

### 08.06.02 Services

Compose ke andar har container ko ek **Service** kaha jata hai.

* **Description:** Har service specify karti hai ke container kis image se banega (ya Dockerfile se build hoga), kaunsa port bind hoga, dependencies kya hain (`depends_on`), aur container ka behavior kya hoga.

* **Example:**

  ```
  services:
    web:
      build: .                  # Current folder ki Dockerfile se build karega
      ports:
        - "5000:5000"           # Host port : Container port
      depends_on:
        - db                    # Pehle 'db' container start hoga
  
    db:
      image: postgres:15        # Docker Hub se image pull karega
      restart: always
  
  ```

### 08.06.03 Volumes & Networks

Compose ke zariye persistent storage aur inter-container communication ko declare karna.

* **Description:**

  * **Networks:** Compose automatically ek default network create karta hai jisme saari services ek doosre ko service name (jaise `db`, `web`) ke zariye DNS se access kar sakti hain.

  * **Volumes:** Containers ke darmian data persist karne ke liye top-level volumes define kiye jate hain.

* **Example:**

  ```
  services:
    db:
      image: postgres:15
      volumes:
        - db_data:/var/lib/postgresql/data   # Named volume mount
      networks:
        - backend_net
  
    web:
      build: .
      networks:
        - backend_net
  
  volumes:
    db_data:                                 # Top-level volume declaration
  
  networks:
    backend_net:                             # Custom network definition
  
  ```

### 08.06.04 Environment Variables

Sensitive data (passwords, API keys) ya configuration values container ke andar pass karne ka tareeqa.

* **Description:** Inhe direct `environment` key ke andar likha ja sakta hai ya ek alag `.env` file se secure tareeqe se load kiya ja sakta hai.

* **Methods:**

  1. **Direct YAML mapping:**

     ```
     services:
       db:
         image: postgres:15
         environment:
           POSTGRES_USER: admin
           POSTGRES_PASSWORD: secretpassword
     
     ```

  2. **Using `.env` file (Recommended):**
     Compose automatically project folder mein maujood `.env` file read kar leta hai:

     ```
     services:
       db:
         image: postgres:15
         env_file:
           - .env
     
     ```

### 08.06.05 `docker compose up` / `down`

Multi-container stack ko start aur destroy karne ki primary commands.

* **`up`**: Saari images build/pull karta hai, networks aur volumes banata hai, aur containers start karta hai.

  * Background (detached mode) mein chalane ke liye:

    ```
    docker compose up -d
    
    ```

  * Code changes ke baad nayi image force rebuild karne ke liye:

    ```
    docker compose up -d --build
    
    ```

* **`down`**: Running containers aur networks ko safely stop aur remove kar deta hai (volumes bache rehte hain).

  * Normal shutdown:

    ```
    docker compose down
    
    ```

  * Containers ke sath volumes ko bhi delete karne ke liye:

    ```
    docker compose down -v
    
    ```

* **Status Check Commands:**

  ```
  docker compose ps       # Running services dekhne ke liye
  docker compose logs -f  # Saari services ke logs live stream karne ke liye
  
  ```