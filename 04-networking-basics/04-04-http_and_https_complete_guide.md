# 🌐 04.04 HTTP/HTTPS & SSL/TLS — Complete Guide

> **HTTP (Hypertext Transfer Protocol)** Application Layer (L7) ka protocol hai jo web browsers, mobile apps, aur APIs ko web servers ke sath baat karne (communication) ki sahulat deta hai. **HTTPS** iska encrypted aur secure version hai.

---

## 1. HTTP Methods (Verbs)

HTTP methods batate hain ke client server par kya action lena chahta hai (REST APIs ka bunyadi structure):

| Method | Maqsad (Action) | Idempotent? | Request Body hoti hai? | Real-World Example |
| :--- | :--- | :--- | :--- | :--- |
| **`GET`** | Data sirf **retrieve / read** karna | Haan | Nahi | Server se user profile mangwana (`/api/users/10`) |
| **`POST`** | Naya resource **create** karna | Nahi | Haan | Naya account register karna ya form submit karna |
| **`PUT`** | Resource ko **mukammal replace / update** karna | Haan | Haan | Poori user details nayi information se overwrite karna |
| **`PATCH`** | Resource mein **juzwi (partial) tabdeeli** karna | Nahi | Haan | Sirf user ka email ya phone number change karna |
| **`DELETE`** | Resource ko **delete / remove** karna | Haan | Optional (Aam tor par nahi) | Database se product record remove karna |
| **`HEAD`** | GET ki tarah, lekin bina response body ke | Haan | Nahi | Check karna ke file exist karti hai ya header inspect karna |
| **`OPTIONS`**| Server se allow shuda methods poochna | Haan | Nahi | Browser CORS pre-flight checks ke liye use karta hai |

> 💡 **Idempotent ka matlab:** Ek hi request ko 1 martaba bhejein ya 10 martaba, server par resource ki final state par koi naya ya mukhtalif farq nahi padta (e.g., `GET`, `PUT`, `DELETE`).

---

## 2. HTTP Status Codes

Server har response ke sath 3-digit numeric code bhejta hai jo batata hai ke request ka nateeja kya nikla:

```
1xx ─── Informational  (Request mil gayi, process ho rahi hai)
2xx ─── Success        (Kaam kamyabi se mukammal hua)
3xx ─── Redirection    (Target resource kisi naye address par hai)
4xx ─── Client Error   (Client ki taraf se ghalti: bad URL, missing token)
5xx ─── Server Error   (Server side par issue: crash, database down)
```

### Zaroori Status Codes jo DevOps ko yaad hone chahiye:

* **2xx (Success):**
  * `200 OK`: Request standard tareeqay se kamyab ho gayi.
  * `201 Created`: Naya resource kamyabi se ban gaya (POST ke response mein).
  * `204 No Content`: Action kamyab raha lekin response mein koi body nahi bhejni (DELETE ke response mein).

* **3xx (Redirection):**
  * `301 Moved Permanently`: URL hamesha ke liye badal gaya hai (SEO friendly). HTTP se HTTPS redirect mein aam tor par yahi lagta hai.
  * `302 Found (Temporary Redirect)`: عارضی (temporary) redirect.
  * `304 Not Modified`: Cached data valid hai, download karne ki zaroorat nahi.

* **4xx (Client Errors):**
  * `400 Bad Request`: Syntax ghalat hai ya request payload malformed hai.
  * `401 Unauthorized`: Authentication missing hai (Login token/API key nahi di).
  * `403 Forbidden`: Authenticated toh hai lekin is resource ko access karne ki permission nahi hai.
  * `404 Not Found`: URL ya endpoint exist nahi karta.
  * `429 Too Many Requests`: Rate limit cross ho gaya.

* **5xx (Server Errors):**
  * `500 Internal Server Error`: Application backend crash ho gaya ya unhandled code exception.
  * `502 Bad Gateway`: Reverse proxy (e.g. Nginx) backend upstream application server (e.g. Node/Python) se contact nahi kar saki.
  * `503 Service Unavailable`: Server overload hai ya maintenance mode mein hai.
  * `504 Gateway Timeout`: Upstream app server ne time limit ke andar proxy ko jawab nahi diya.

---

## 3. HTTP Headers (Metadata Exchange)

Headers request aur response ke baray mein context, authentication credentials, aur instructions provide karte hain:

### A. Common Request Headers (Client bhejta hai):
```http
Host: api.example.com
User-Agent: Mozilla/5.0 / curl/8.5.0
Authorization: Bearer eyJhbGciOiJIUzI1Ni...
Accept: application/json
Content-Type: application/json
```

### B. Common Response Headers (Server bhejta hai):
```http
Content-Type: application/json; charset=UTF-8
Content-Length: 348
Set-Cookie: session_id=xyz789; Secure; HttpOnly; SameSite=Strict
Location: https://example.com/login  (Redirects ke waqt)
Cache-Control: max-age=3600, public
```

### C. Security Headers (Best Practices for Production):
* `Strict-Transport-Security (HSTS)`: Browser ko majboor karta hai ke sirf HTTPS use kare.
* `Content-Security-Policy (CSP)`: XSS attacks ko rokne ke liye scripts ke sources restrict karna.
* `X-Frame-Options: DENY`: Clickjacking attacks se bachane ke liye iframe mein load hona block karna.

---

## 4. HTTPS & TLS/SSL (Securing Communication)

* **HTTP (Port 80):** Plain text traffic. Network par koi bhi "Man-in-the-Middle" (MITM) attack ke zariye passwords, cookies aur traffic sniff/tamper kar sakta hai.
* **HTTPS (Port 443):** HTTP over TLS (Transport Layer Security). Is mein tamam data client aur server ke darmiyan mathematically encrypt hota hai.

```
       Plain HTTP:  [ Client ] ──────── Plain Text Data ────────> [ Server ]
                                  (Sniffing possible ⚠️)

      Secure HTTPS: [ Client ] ══ Encrypted Tunnel (TLS) ══════> [ Server ]
                               (Confidentiality & Integrity 🔒)
```

### TLS Handshake (Simplified Flow):
1. **Client Hello:** Client server ko supported TLS versions aur encryption ciphers bhejta hai.
2. **Server Hello + Certificate:** Server apna TLS certificate (jisme server ki **Public Key** hoti hai) bhejta hai.
3. **Authentication & Validation:** Client system (browser/OS) CA roots ke zariye check karta hai ke certificate valid aur untampered hai.
4. **Key Exchange (Session Key):** Client aur server aapas mein ek temporary **Symmetric Session Key** generate/exchange karte hain.
5. **Secure Channel Established:** Dono sides is session key se high-speed symmetric encryption shuru kar deti hain.

---

## 5. SSL/TLS Certificates & Management

Web traffic encrypt karne aur domain identity verify karne ke liye server par digital certificate install karna parta hai.

### A. Public Key Infrastructure (PKI):
* **Certificate Authority (CA):** Trusted third-party idaray (jaise Let's Encrypt, DigiCert) jo certificates issue aur verify karte hain.
* **Private Key:** Hamesha server par secret rakhi jaati hai. Kisi ke sath share nahi ki jaati.
* **Public Key:** Certificate ke sath attach hoti hai aur dunya ko publicly available hoti hai.
* **CSR (Certificate Signing Request):** Server par banai gayi request jisme domain ka naam aur public key hoti hai taake CA use sign kar sake.

### B. Certificate File Formats:
* `.crt` / `.pem`: Base64 encoded text certificates (production Linux/Nginx mein sabse aam).
* `.key`: Private key file.
* `fullchain.pem`: Aapka domain certificate + Intermediate CA certificates (chain of trust).

### C. Practical DevOps Tools & Commands:

#### 1. Free Automation with Let's Encrypt (`certbot`):
```bash
# Nginx ke sath automated SSL issue aur configure karna
sudo certbot --nginx -d example.com -d www.example.com

# Auto-renewal check
sudo certbot renew --dry-run
```

#### 2. OpenSSL ke zariye Certificate Inspect karna:
```bash
# Remote website ka certificate aur expiry check karna
openssl s_client -connect example.com:443 -servername example.com </dev/null | openssl x509 -noout -dates

# Local certificate file ke contents dekhna
openssl x509 -in cert.pem -text -noout
```

#### 3. `curl` ke sath HTTP Headers inspect karna:
```bash
# -I sirf headers mangta hai, -v verbose TLS handshake dikhata hai
curl -Iv https://example.com
```

---
**Status:** ✅ Complete