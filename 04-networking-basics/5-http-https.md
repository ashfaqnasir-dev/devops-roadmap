# 🌐 HTTP/HTTPS — Complete Guide

> HTTP = Web ka protocol. HTTPS = Secure HTTP.

---

## 📚 Table of Contents

1. [HTTP Kya Hai?](#http-kya-hai)
2. [HTTP Methods](#http-methods)
3. [Status Codes](#status-codes)
4. [Headers](#headers)
5. [HTTPS & TLS](#https--tls)
6. [Certificates](#certificates)
7. [Commands](#commands)

---

## HTTP Kya Hai?

**HTTP** = **H**yper**T**ext **T**ransfer **P**rotocol

**HTTP** = **Protocol** — web par data transfer ke liye.

**Stateless:** Har request independent.

### Request/Response

```
Client                              Server
  │                                   │
  │────── HTTP Request ──────────────►│
  │  GET /index.html HTTP/1.1         │
  │  Host: example.com                │
  │                                   │
  │◄───── HTTP Response ──────────────│
  │  HTTP/1.1 200 OK                  │
  │  Content-Type: text/html          │
  │  <html>...</html>                 │
```

---

## HTTP Methods

| Method | Purpose |
|---|---|
| **GET** | Data retrieve |
| **POST** | Data create |
| **PUT** | Data update (full) |
| **PATCH** | Data update (partial) |
| **DELETE** | Data delete |
| **HEAD** | Headers only |
| **OPTIONS** | Allowed methods |

### Examples

```bash
# GET
curl https://api.example.com/users

# POST
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Ashfaq"}'

# PUT
curl -X PUT https://api.example.com/users/1 \
  -d '{"name": "Updated"}'

# DELETE
curl -X DELETE https://api.example.com/users/1
```

---

## Status Codes

### Categories

| Range | Meaning |
|---|---|
| **1xx** | Informational |
| **2xx** | Success |
| **3xx** | Redirection |
| **4xx** | Client error |
| **5xx** | Server error |

### Common Codes

| Code | Meaning |
|---|---|
| **200** | OK |
| **201** | Created |
| **301** | Moved Permanently |
| **302** | Found |
| **400** | Bad Request |
| **401** | Unauthorized |
| **403** | Forbidden |
| **404** | Not Found |
| **500** | Internal Server Error |
| **502** | Bad Gateway |
| **503** | Service Unavailable |

---

## Headers

### Request Headers

```
GET /api/users HTTP/1.1
Host: api.example.com
User-Agent: Mozilla/5.0
Accept: application/json
Authorization: Bearer token123
Content-Type: application/json
```

### Response Headers

```
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 1234
Cache-Control: max-age=3600
Set-Cookie: session=abc123
```

### Important Headers

| Header | Purpose |
|---|---|
| **Host** | Target server |
| **User-Agent** | Client info |
| **Accept** | Response format |
| **Authorization** | Credentials |
| **Content-Type** | Body format |
| **Cache-Control** | Caching rules |

---

## HTTPS & TLS

### HTTPS Kya Hai?

**HTTPS** = **HTTP + TLS/SSL**

**Secure:** Data encrypted.

### TLS Handshake

```
Client                              Server
  │                                   │
  │────── ClientHello ───────────────►│
  │  (TLS version, ciphers)           │
  │                                   │
  │◄───── ServerHello ────────────────│
  │  (Certificate, public key)        │
  │                                   │
  │────── Key Exchange ──────────────►│
  │                                   │
  │◄───── Finished ───────────────────│
  │                                   │
  │◄══════ Encrypted Data ═══════════►│
```

### HTTP vs HTTPS

| Feature | HTTP | HTTPS |
|---|---|---|
| Port | 80 | 443 |
| Encryption | ❌ | ✅ |
| Speed | Fast | Slightly slower |
| Security | None | TLS |
| SEO | Lower | Higher |

---

## Certificates

### Types

| Type | Purpose |
|---|---|
| **DV** | Domain Validation |
| **OV** | Organization Validation |
| **EV** | Extended Validation |
| **Wildcard** | *.example.com |
| **SAN** | Multiple domains |

### Free Certificates

- **Let's Encrypt** — letsencrypt.org
- **Cloudflare** — Free SSL

### Check Certificate

```bash
# Expiry date
echo | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 -noout -dates

# Full info
echo | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 -noout -text
```

---

## Commands

### Basic Request

```bash
curl https://google.com
```

### Headers Only

```bash
curl -I https://google.com
```

### Verbose

```bash
curl -v https://google.com
```

### POST

```bash
curl -X POST https://api.example.com/data \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

### Status Code

```bash
curl -o /dev/null -s -w "%{http_code}\n" https://google.com
```

### Follow Redirects

```bash
curl -L https://example.com
```

### Save Output

```bash
curl -o file.html https://example.com
```

---

## Checklist

- [ ] HTTP methods yaad
- [ ] Status codes clear
- [ ] Headers samjha
- [ ] HTTPS/TLS concept
- [ ] Certificates
- [ ] curl commands

---

**Status:** ✅ Complete
**Last Updated:** 2026-10-15
**Author:** Ashfaq Nasir
