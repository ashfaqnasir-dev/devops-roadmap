# 📝 03.06 Text Processing — Complete Guide

> Linux aur DevOps mein zyadatar data (logs, configuration files, outputs) text ki soorat mein hota hai. **Text Processing tools** ki madad se hum lakhon lines ke logs mein se zaroori data search, filter, replace, aur format kar sakte hain.

---

## 1. `grep` (Global Regular Expression Print — Search Karna)

`grep` kisi file ya command ke output mein se **makhsoos pattern ya text dhoondne** ke liye use hota hai.

### Common Flags:
- `-i` : Case-insensitive (chhotay baray letters ka farq nazar-andaz karein).
- `-v` : Invert match (jo line match **na** kare sirf woh dikhaye).
- `-r` / `-R` : Recursive (folder ke andar tamam sub-folders aur files mein search karein).
- `-n` : Line number sath show kare.
- `-c` : Matching lines ki total count bataye.
- `-E` : Extended regex support kare.

### Practical Examples:
```bash
# File mein "ERROR" word dhoondna (case-insensitive)
grep -i "error" /var/log/syslog

# Nginx config mein se comments (#) aur khali lines filter karke nikalna
grep -v "^#" /etc/nginx/nginx.conf | grep -v "^$"

# Pure project directory mein "DATABASE_URL" dhoondna
grep -rn "DATABASE_URL" ./src/
```

---

## 2. `awk` (Pattern Scanning & Column Processing)

`awk` ek mukammal mini-programming language hai jo tabular (rows aur columns wale) data ko process aur summarize karne ke liye best tool hai.

### Core Concepts:
- `$0` : Poori line.
- `$1, $2, $3` : Pehla column, doosra column, teesra column (by default space ya tab par split karta hai).
- `-F` : Custom delimiter specify karna (e.g. `:` ya `,`).
- `NR` : Number of Records (line number).
- `NF` : Number of Fields (us line mein total columns kitne hain).

### Practical Examples:
```bash
# df -h ke output se sirf Filesystem ($1) aur Usage% ($5) print karna
df -h | awk '{print $1, $5}'

# /etc/passwd file (jo ':' separated hoti hai) se sirf usernames ($1) nikalna
awk -F: '{print $1}' /etc/passwd

# Nginx access log mein se sirf HTTP 500 status code ($9) wali lines filter karna
awk '$9 == 500 {print $1, $7, $9}' /var/log/nginx/access.log
```

---

## 3. `sed` (Stream Editor — Find & Replace)

`sed` text stream ko modify karne ke liye use hota hai. Iska sabse aam istemal files ke andar **words ko replace (substitute)** karna ya makhsoos lines delete karna hota hai.

### Basic Syntax:
```bash
sed 's/dhoondo/badlo/flags' filename
```

### Common Flags & Modifiers:
- `s/` : Substitute (replace) command.
- `/g` : Global replace (line mein jitni dafa word aaye sab ko badal de, warna sirf pehle match ko badlega).
- `-i` : In-place edit (original file ko direct modify kar deta hai).

### Practical Examples:
```bash
# Screen par "localhost" ko "127.0.0.1" se replace karke dikhana
sed 's/localhost/127.0.0.1/g' config.env

# Original config file ke andar direct replace karna (-i)
sed -i 's/PORT=3000/PORT=8080/g' .env

# File se pehli line delete karna (e.g., CSV header nikalna)
sed '1d' data.csv

# File mein se har khali line delete karna
sed -i '/^$/d' server.list
```

---

## 4. `cut` (Sections & Columns Ko Katna)

`cut` lines mein se makhsoos columns, fields, ya characters ko extract karne ke liye ek lightweight tool hai (jab `awk` ki heavy scripting ki zaroorat na ho).

### Common Flags:
- `-d` : Delimiter specify karna (default tab hota hai).
- `-f` : Field (column) number specify karna.
- `-c` : Specific character positions cut karna.

### Practical Examples:
```bash
# /etc/passwd file se usernames (pehla field) cut karna
cut -d: -f1 /etc/passwd

# CSV file se 1st aur 3rd columns nikalna
cut -d, -f1,3 customers.csv

# Har line ke pehle 10 characters cut karna
cut -c 1-10 /var/log/syslog
```

---

## 5. `sort` & `uniq` (Tartib Dena aur Duplicates Hatana)

Yeh dono commands aksar sath use hoti hain data ko arrange karne aur unique/frequent items calculate karne ke liye.

### A. `sort` (Tartib Dena):
- `-n` : Numerical sort (e.g. 2, 10, 100 — warna default alphabetic sort 10 ko 2 se pehle layega).
- `-r` : Reverse sort (ulta order: Z-A ya baray se chhota).
- `-k` : Makhsoos column number ke hisab se sort karna.

### B. `uniq` (Duplicates Handle Karna):
> ⚠️ **Golden Rule:** `uniq` sirf **adjacent (ek sath aane wali)** duplicate lines ko pakadta hai, isliye isay hamesha pehle `sort` ke sath pipe (`|`) karna laazmi hota hai!

- `-c` : Har line kitni baar aayi hai uski count sath show kare.
- `-d` : Sirf duplicate lines dikhaye.
- `-u` : Sirf unique (jo sirf 1 baar aayi hon) lines dikhaye.

### Practical DevOps Pipeline Example:
```bash
# Web server log mein se Top 5 IP addresses dhoondna jo sabse zyada requests bhej rahe hain
awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head -n 5
```
*Flow breakdown:*
1. `awk '{print $1}'` $\rightarrow$ Har line se IP address nikalta hai.
2. `sort` $\rightarrow$ Identical IPs ko ek sath lata hai.
3. `uniq -c` $\rightarrow$ Duplicates count karta hai (`45 192.168.1.10`).
4. `sort -nr` $\rightarrow$ Count ke hisab se descending (baray se chhotay) order mein sort karta hai.
5. `head -n 5` $\rightarrow$ Top 5 culprit IPs print karta hai.

---
**Status:** ✅ Complete