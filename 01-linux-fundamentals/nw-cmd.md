# 🌐 Networking Commands — Simple Guide

Yeh commands check karne ke liye use hote hain ke network theek chal raha hai ya nahi.

### 1. Connectivity & Files (`ping`, `curl`, `wget`)
- **`ping google.com`**: Check karta hai ke internet chal raha hai ya nahi.
- **`curl -I https://google.com`**: Website ka status (Headers) check karta hai.
- **`wget <url>`**: Internet se file download karta hai.

### 2. Ports & Connections (`ss`, `netstat`)
- **`ss -tulpn`**: Batata hai ke system par kaunse ports open hain aur kaunsa program unhe use kar raha hai. (`netstat` iska purana version hai).

### 3. IP Address (`ip`, `ifconfig`)
- **`ip addr`**: Aapke system ka IP address aur network details dikhata hai. (`ifconfig` iska purana version hai).

### 4. DNS Lookup (`dig`, `nslookup`)
- **`nslookup google.com`**: Batata hai ke website ka IP address kya hai.
- **`dig google.com`**: Wahi kaam karta hai lekin thori zyada detail mein.

### 5. Troubleshooting (`traceroute`, `tcpdump`)
- **`traceroute google.com`**: Batata hai ke data server tak pohanchne ke liye kitne routers se guzarta hai.
- **`sudo tcpdump`**: Network ka live traffic (packets) screen par dikhata hai.

---
**Status:** Complete
