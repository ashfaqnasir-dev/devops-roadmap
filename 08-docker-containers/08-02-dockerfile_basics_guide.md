# 🐳 Dockerfile Basics — Complete Guide

> Dockerfile ek text file hai jo recipe ki tarah kaam karti hai. Isme likha hota hai ke Docker Image kaise banani hai.

---

## 1. `FROM` (Base Image)
Har Dockerfile isi se shuru hoti hai. Yeh batata hai ke image kis base par banegi.
- **Example:** `FROM ubuntu:22.04` ya `FROM python:3.11-slim`

---

## 2. `RUN`, `CMD`, `ENTRYPOINT` (Commands)
- **`RUN`**: Image build hote waqt command chalata hai (jaise software install karna).
  - *Example:* `RUN apt-get install nginx`
- **`CMD`**: Container start hote waqt default command chalata hai. Ise run karte waqt easily override kar sakte hain.
  - *Example:* `CMD ["python", "app.py"]`
- **`ENTRYPOINT`**: Container start hote waqt fixed command chalata hai. Ise override karna mushkil hota hai. Aksar `CMD` ke sath use hota hai.

---

## 3. `COPY`, `ADD` (Files Transfer)
- **`COPY`**: Aapke computer (host) se files container mein copy karta hai.
  - *Example:* `COPY app.py /app/`
- **`ADD`**: Copy karta hai, lekin isme extra features hain (jaise URL se download karna ya ZIP extract karna). Hamesha `COPY` use karein jab tak `ADD` ki khaas zaroorat na ho.

---

## 4. `WORKDIR`, `EXPOSE` (Directory & Port)
- **`WORKDIR`**: Container ke andar kaam karne ka folder set karta hai.
  - *Example:* `WORKDIR /app`
- **`EXPOSE`**: Batata hai ke app kis port par chalegi. *(Note: Yeh sirf documentation hai, port bahar kholne ke liye `docker run -p` use hota hai).*

---

## 5. `ENV`, `ARG` (Variables)
- **`ENV`**: Environment variable set karta hai jo container chalne ke baad bhi zinda rehta hai (jaise database ka password ya app ka naam).
- **`ARG`**: Sirf build time ke liye variable hota hai. Image banne ke baad yeh khatam ho jata hai.

---

## 6. Multi-stage Builds (Pro Level)
Iski madad se hum build tools (jaise Maven, npm) ko final image se bahar nikal dete hain. Isse final image **bohot choti aur fast** ban jati hai.

---

## 💻 Complete Real-World Example

Ek simple Python Flask app ki Dockerfile:

```dockerfile
# 1. Base Image
FROM python:3.11-slim

# 4. Working Directory
WORKDIR /app

# 5. Environment Variable
ENV APP_NAME="MyApp"

# 3. Files Copy karein
COPY app.py .

# 2. Dependencies Install karein (Build time)
RUN pip install flask

# 4. Port batayein
EXPOSE 5000

# 2. Container start hote hi command chalayein
CMD ["python", "app.py"]
```