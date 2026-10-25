# 🐝 08.08 Docker Swarm & Container Orchestration

Jab aapki application ek single server se nikal kar multiple servers par distribute hoti hai, tab aapko **Container Orchestration** ki zaroorat padti hai. Docker Swarm Docker ka native clustering aur orchestration tool hai jo multiple Docker hosts ko ek single virtual system ke taur par treat karta hai.

---

### 08.08.01 Swarm Architecture (Managers vs. Workers)

Swarm cluster do tarah ke nodes (servers/machines) se milkar banta hai:

* **Manager Nodes:**
  * Cluster ke brain hotay hain.
  * Cluster state maintain karte hain (via Raft consensus algorithm).
  * Tasks schedule karte hain aur services ko distribute karte hain.
  * Production mein recommended hai ke odd number of managers hon (e.g., 3 ya 5) taake split-brain issue na ho.
* **Worker Nodes:**
  * Inka kaam sirf assigned containers (tasks) ko execute aur run karna hota hai.
  * Inke paas cluster management ya scheduling rights nahi hotay.

---

### 08.08.02 Initializing a Swarm Cluster

Cluster set up karne ke commands simple aur straightforward hain:

* **Initialize Manager Node:**
  Current machine ko primary manager banayein:
  ```bash
  docker swarm init --advertise-addr <MANAGER-IP>
  ```
  *Yeh command ek join token generate karti hai.*

* **Join Worker Node:**
  Kisi doosre machine par ja kar cluster join karein:
  ```bash
  docker swarm join --token <WORKER-JOIN-TOKEN> <MANAGER-IP>:2377
  ```

* **Join Additional Manager:**
  Manager join token hasil karne ke liye:
  ```bash
  docker swarm join-token manager
  ```

* **Cluster Status Check:**
  Manager node par run karein:
  ```bash
  docker node ls
  ```

---

### 08.08.03 Services vs. Containers

Swarm mein direct container run karne ke bajaye **Services** define ki jaati hain.

* **Concept:** Service ek declarative state hoti hai (jaise "mujhe NGINX ke 3 copies har waqt running chahiyein").
* **Tasks:** Ek service ke individual running containers ko Swarm terminology mein **Tasks** kaha jata hai.
* **Service Create Command:**
  ```bash
  docker service create --name web-service --replicas 3 -p 80:80 nginx
  ```
* **List & Inspect Services:**
  ```bash
  docker service ls
  docker service ps web-service
  ```

---

### 08.08.04 Scaling & Self-Healing (High Availability)

Swarm continuous reconciliation loop chalata hai jo desired state aur actual state ko match karta rehta hai.

* **Dynamic Scaling:**
  Traffic badhne par replicas instantly increase/decrease karein:
  ```bash
  docker service scale web-service=5
  ```

* **Self-Healing:**
  Agar koi worker server crash ho jaye ya container fail ho jaye, to Manager node automatically kisi doosre healthy worker node par missing replica create kar deta hai taake count hamesha desired state (e.g., 5) ke barabar rahe.

---

### 08.08.05 Overlay Networks & Ingress Routing Mesh

Multi-host networking Swarm ka sabse powerful feature hai.

* **Overlay Network:**
  Multiple hosts par chalne wale containers ke darmiyan secure, encrypted virtual network banata hai taake woh aapas mein direct communicate kar sakein.
  ```bash
  docker network create --driver overlay my-swarm-net
  ```

* **Routing Mesh (Ingress):**
  Swarm cluster ke kisi bhi node ke exposed port par traffic bhejein, routing mesh us request ko automatically us node par route kar deta hai jahan service ka container physically run ho raha hota hai. Iske aage external load balancer lagana nihayat aasan ho jata hai.

---

### 08.08.06 Deploying Stacks (`docker stack deploy`)

`docker-compose.yml` file ko use karke poore multi-service production stack ko Swarm par deploy karna.

* **Deploy Command:**
  ```bash
  docker stack deploy -c docker-compose.yml my-app-stack
  ```
* **Stack Management:**
  ```bash
  docker stack ls                       # Active stacks
  docker stack services my-app-stack    # Services inside stack
  docker stack rm my-app-stack          # Remove stack
  ```

---

### 08.08.07 Rolling Updates & Rollbacks

Bina kisi downtime ke nayi image versions deploy karna.

* **Rolling Update:**
  ```bash
  docker service update --image my-app:v2 --update-parallelism 2 --update-delay 10s web-service
  ```
  *(Yeh ek waqt mein 2 containers update karega aur har batch ke darmian 10 seconds ka gap rakhega).*

* **Rollback:**
  Agar nayi release fail ho jaye to instantly purani stable state par revert karein:
  ```bash
  docker service rollback web-service
  ```