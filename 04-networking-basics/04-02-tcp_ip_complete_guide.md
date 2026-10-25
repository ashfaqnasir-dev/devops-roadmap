# 🌐 04.02 TCP/IP — Complete Guide

> **TCP/IP (Transmission Control Protocol / Internet Protocol)** internet aur modern computer networks ka asal practical protocol suite hai. Jahan OSI model ek theoretical reference model hai, wahan TCP/IP woh framework hai jis par practical world wide web kaam karta hai.

---

## 1. TCP vs UDP (Transport Layer Protocols)

Transport layer par data deliver karne ke do bunyadi protocols hain:

| Feature | TCP (Transmission Control Protocol) | UDP (User Datagram Protocol) |
| :--- | :--- | :--- |
| **Connection Type** | Connection-Oriented (Pehle handshake hota hai) | Connectionless (Bina connection direct bhejta hai) |
| **Reliability** | **100% Reliable** (Har packet ka acknowledgement aata hai) | **Unreliable** (Packet pohncha ya drop hua, parwah nahi) |
| **Data Order** | Strict ordering (Packets usi sequence mein receive hotay hain) | No order (Packets aage peeche pohnch sakte hain) |
| **Retransmission** | Agar packet gir jaye, toh dobara bhejta hai | Lost packets dobara nahi bheje jaate |
| **Speed & Overhead** | Heavy header ($20\text{ bytes}$), comparatively slow | Lightweight header ($8\text{ bytes}$), extremely fast |
| **Typical Use Cases** | HTTP/HTTPS (Web), SSH, Database connections, File transfer | Video Streaming, Online Gaming, VoIP (Calls), DNS queries |

> 💡 **Thumb Rule:** Agar accuracy aur no-data-loss zaroori hai toh **TCP**; agar speed aur real-time stream zaroori hai toh **UDP**.

---

## 2. IP Addressing (IPv4 vs IPv6)

Network layer par har connected machine ko pehchanne ke liye **IP Address** use hota hai.

### A. IPv4 (32-bit Address):
* Format: 4 octets jo dots se separate hotay hain (e.g., `192.168.1.1`).
* Har octet 0 se 255 ke darmiyan hota hai ($8\text{ bits} \times 4 = 32\text{ bits}$).
* Total possible addresses: $2^{32} \approx 4.3\text{ billion}$ (jo ab duniya mein khatam ho chuke hain).
* **Private vs Public IP:**
  * **Private IPs (Local LAN):**
    * `10.0.0.0` - `10.255.255.255` (Class A)
    * `172.16.0.0` - `172.31.255.255` (Class B)
    * `192.168.0.0` - `192.168.255.255` (Class C - Ghar aur small office routers)
  * **Public IPs:** Internet par globally unique addresses jo ISP ya Cloud provider assign karta hai.

### B. IPv6 (128-bit Address):
* Format: 8 groups jo hexadecimal numbers aur colons se separate hotay hain (e.g., `2001:0db8:85a3:0000:0000:8a2e:0370:7334`).
* Total addresses: $2^{128}$ (itne taadad ke duniya ke har reet ke zarre ko bhi hazaron IPs di ja sakti hain).
* NAT (Network Address Translation) ki zaroorat nahi rehti; har device ko direct publicly routable IP mil sakti hai.

---

## 3. Subnetting & CIDR (Classless Inter-Domain Routing)

Subnetting ka matlab hai ek baray network ko chhotay, manageable aur secure pieces (subnets) mein todna.

### CIDR Notation (`/slash` format):
Slash ke baad ka number batata hai ke IP ke kitne bits **Network** ke liye lock hain aur baaqi kitne bits **Hosts (machines)** ke liye bachte hain.

* Formula for Total IPs:
  $$N_{\text{total}} = 2^{(32 - \text{prefix})}$$
* Formula for Usable IPs (2 IPs nikal jaati hain: ek Network ID aur ek Broadcast ID):
  $$N_{\text{usable}} = 2^{(32 - \text{prefix})} - 2$$

### Common DevOps Subnets:

| CIDR Prefix | Subnet Mask | Total IPs | Usable IPs | DevOps Context |
| :--- | :--- | :--- | :--- | :--- |
| **/32** | `255.255.255.255` | 1 | 1 | Single specific host (e.g. firewall whitelist rule) |
| **/24** | `255.255.255.0` | 256 | 254 | Standard office LAN ya single AWS subnet |
| **/20** | `255.255.240.0` | 4,096 | 4,094 | Medium cloud VPC subnets |
| **/16** | `255.255.0.0` | 65,536 | 65,534 | Standard AWS/Azure VPC root range |

> ⚠️ **Cloud Provider Note (AWS/GCP):** AWS har subnet mein se **5 IPs** reserve karta hai (Network, Router, DNS, Future use, Broadcast), isliye AWS `/24` subnet mein $256 - 5 = 251$ usable IPs hoti hain.

---

## 4. Ports & Sockets

IP address sirf yeh batata hai ke data kis computer par bhejna hai, jabke **Port** yeh batata hai ke us computer ke andar kis program ya service ko data dena hai.

* **Port Range:** $0$ se $65,535$
  * **Well-Known Ports ($0 - 1023$):** Standard system services (root permissions required).
    * `22`: SSH
    * `53`: DNS
    * `80`: HTTP
    * `443`: HTTPS
  * **Registered Ports ($1024 - 49151$):** Common applications.
    * `3306`: MySQL
    * `5432`: PostgreSQL
    * `6379`: Redis
    * `8080`: Web apps / Jenkins
  * **Ephemeral / Dynamic Ports ($49152 - 65535$):** Client machines temporary outgoing connection ke liye use karti hain.

* **Socket (IP + Port):**
  Network par communication ka exact endpoint:
  $$\text{Socket} = \text{IP Address} : \text{Port Number}$$
  *Example:* `192.168.1.50:443`

---

## 5. TCP Three-Way Handshake (SYN, SYN-ACK, ACK)

TCP connection banate waqt client aur server aapas mein 3-step synchronization process perform karte hain taake reliable link verify ho sake:

```
[ Client ]                                          [ Server ]
    │                                                   │
    │  1. SYN (Synchronize: "Kya aap baat kar sakte?")  │
    │ ────────────────────────────────────────────────> │
    │                                                   │
    │  2. SYN-ACK ("Haan main ready hoon, aap ready?")  │
    │ <──────────────────────────────────────────────── │
    │                                                   │
    │  3. ACK (Acknowledge: "Haan main bhi ready hoon") │
    │ ────────────────────────────────────────────────> │
    │                                                   │
    ▼                                                   ▼
[ Connection ESTABLISHED: Actual data transfer shuru ]
```

### Steps Breakdown:
1. **Step 1 (SYN):** Client ek random sequence number ($x$) ke sath `SYN` packet bhejta hai server ko request karne ke liye. (Client state: `SYN_SENT`).
2. **Step 2 (SYN-ACK):** Server packet receive karta hai, apna random sequence number ($y$) banata hai aur acknowledgment ($x + 1$) ke sath `SYN-ACK` packet bhejta hai. (Server state: `SYN_RCVD`).
3. **Step 3 (ACK):** Client acknowledgment ($y + 1$) bhejta hai. Connection form ho jata hai (Dono states: `ESTABLISHED`).

### Connection Terminate Karna (4-Way Handshake):
Data transfer khatam hone par connection close karne ke liye **FIN** (Finish) packets exchange hotay hain:
`FIN` $\rightarrow$ `ACK` $\rightarrow$ `FIN` $\rightarrow$ `ACK`.

---

**Status:** ✅ Complete