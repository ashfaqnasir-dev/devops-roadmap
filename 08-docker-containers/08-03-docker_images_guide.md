# 📦 08.03 Docker Images

Docker Image ek lightweight, standalone aur executable software package hota hai jisme code, runtime, libraries, aur configuration shamil hoti hai.

---

### 08.03.01 Pull Images
Docker Hub ya kisi remote registry se bani banayi image apne system par download karne ke liye use hota hai.

* **Description:** Jab aapko kisi official ya community image (jaise `nginx`, `node`, `python`) ki zaroorat hoti hai, to aap use registry se pull karte hain.
* **Command:**
  ```bash
  docker pull <image_name>:<tag>
  ```
* **Example:**
  ```bash
  docker pull python:3.11-slim
  ```

---

### 08.03.02 Build Images
`Dockerfile` se custom Docker image create karne ke liye use hota hai.

* **Description:** Yeh command aapki `Dockerfile` ki saari instructions step-by-step execute karke ek nayi executable image taiyar karti hai.
* **Command:**
  ```bash
  docker build -t <image_name>:<tag> <path_to_dockerfile>
  ```
* **Example:**
  ```bash
  docker build -t my-app:v1 .
  ```

---

### 08.03.03 Tag Images
Maujooda image ko ek naya naam ya version label dene ke liye use hota hai.

* **Description:** Yeh registry mein upload karne ya versions (jaise `v1.0`, `latest`) manage karne ke liye ek alias/pointer banata hai. Isse image dobara copy nahi hoti balki reference add hota hai.
* **Command:**
  ```bash
  docker tag <source_image>:<tag> <target_image>:<tag>
  ```
* **Example:**
  ```bash
  docker tag my-app:v1 username/my-app:1.0.0
  ```

---

### 08.03.04 Push to Registry
Local image ko remote registry (jaise Docker Hub, AWS ECR, GitHub Container Registry) par upload karne ke liye use hota hai.

* **Description:** Iski madad se aap apni application image doosron ke sath share kar sakte hain ya deployment servers (CI/CD) ke liye available kar sakte hain.
* **Command:**
  ```bash
  docker push <registry_username>/<image_name>:<tag>
  ```
* **Example:**
  ```bash
  docker login
  docker push username/my-app:1.0.0
  ```

---

### 08.03.05 Image Layers
Docker images ki internal architecture hoti hai jo caching aur efficiency provide karti hai.

* **Description:** Dockerfile ki har instruction (jaise `FROM`, `RUN`, `COPY`) ek read-only layer banati hai. Yeh layers stack hoti hain aur duplicate layers ko cache kar ke build time aur storage space dono bachati hain.
* **Key Point:** Agar sirf code badla ho (`COPY`), to Docker purani `RUN` (dependencies) wali layer ko cache se utha leta hai aur dobara install nahi karta.
* **Command to inspect layers:**
  ```bash
  docker history <image_name>
  ```