# 🔑 01.07 SSH & Remote Access

Secure Shell (SSH) ek cryptographic network protocol hai jo insecure network par do systems ke darmian secure, encrypted communication provide karta hai. Linux systems, remote cloud servers (AWS, DigitalOcean), aur CI/CD runners ko remote control karne ka yeh standard tareeqa hai.

---

### 01.07.01 SSH Basics

SSH client-server model par kaam karta hai (default port **22**). Server side par `sshd` daemon run ho raha hota hai jo incoming connections accept karta hai.

* **Standard Connection Syntax:**
  ```bash
  ssh <username>@<remote_host_or_ip>
  ```

* **Common Options:**
  * `-p <port>`: Non-default port specify karne ke liye (security best practice).
  * `-i <identity_file>`: Specific private key file pass karne ke liye.
  * `-v` / `-vvv`: Verbose debug mode (connection issues troubleshoot karne ke liye).

* **Examples:**
  ```bash
  # Standard port 22 par connect karna
  ssh ubuntu@192.168.1.50

  # Custom port (e.g. 2222) specify karna
  ssh -p 2222 admin@myserver.com

  # Specific private key ke sath connect karna
  ssh -i ~/.ssh/my_cloud_key.pem ubuntu@ec2-ip.compute.amazonaws.com

  # Remote host par terminal open kiye baghair direct command run karna
  ssh ubuntu@192.168.1.50 "uptime && df -h"
  ```

---

### 01.07.02 SSH Keys (`ssh-keygen`, `ssh-copy-id`)

Password authentication ke muqablay mein **SSH Key Pairs** (Asymmetric Cryptography) bohot zyada secure aur brute-force attack immune hotay hain.

* **Private Key (`id_ed25519`):** Aapke local computer par rehti hai, kisi ke sath share **nahi** karni hoti.
* **Public Key (`id_ed25519.pub`):** Remote server ke `~/.ssh/authorized_keys` file mein add ki jaati hai.

#### 1. Generate SSH Key Pair (`ssh-keygen`)
Modern Ed25519 algorithm generate karne ke liye (fast aur high security):
```bash
ssh-keygen -t ed25519 -C "admin@company.com"
```
*(Legacy RSA key ke liye: `ssh-keygen -t rsa -b 4096 -C "email"`)*

#### 2. Copy Public Key to Remote Server (`ssh-copy-id`)
Yeh command public key ko remote machine par upload karke `~/.ssh/authorized_keys` mein append kar deti hai:
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@192.168.1.50
```

#### 3. Client Config File (`~/.ssh/config`)
IP addresses aur lambe commands yaad rakhne ke bajaye aliases banana:
```text
# ~/.ssh/config file ke andar likhein:
Host prod-web
    HostName 192.168.1.50
    User ubuntu
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```
Ab aap direct connect kar sakte hain:
```bash
ssh prod-web
```

---

### 01.07.03 `scp` (Secure Copy Protocol)

SSH tunnel ke zariye local aur remote machines ke darmian files aur directories copy karne ka tool.

* **Description:** Simple single transfers ke liye quick tool hai, lekin yeh large syncs ya interrupted transfers resume karne ke liye optimized nahi hai.

* **Common Flags:**
  * `-r`: Recursive (directories copy karne ke liye)
  * `-P`: Port specify karne ke liye (Capital `P`)
  * `-i`: Private key specify karne ke liye

* **Examples:**
  ```bash
  # Local file ko remote server par bhejna
  scp app.py ubuntu@192.168.1.50:/var/www/

  # Remote server se file apne local computer par download karna
  scp ubuntu@192.168.1.50:/var/log/syslog ./local_logs/

  # Poora directory upload karna (Custom port ke sath)
  scp -P 2222 -r ./build/ ubuntu@192.168.1.50:/var/www/html/
  ```

---

### 01.07.04 `rsync` (Remote Sync)

Data backup aur remote synchronization ka sabse powerful aur efficient tool.

* **Delta-Transfer Algorithm:** Yeh poori file dobara transfer karne ke bajaye **sirf woh hissa bhejta hai jo badla ho (diff)**. Isse network bandwidth aur time bohot bachta hai.

* **Common Flags Explanation:**
  * `-a` (Archive): Permissions, timestamps, symlinks, aur ownership preserve karta hai (Recursive bhi shamil hai).
  * `-v` (Verbose): Screen par progress show kare.
  * `-z` (Compress): Data transfer ke waqt network compression enable kare.
  * `-P` (Progress + Partial): Live transfer speed dikhaye aur broken transfer ko resume karne ki sahulat de.
  * `--delete`: Destination se woh files delete kar de jo source mein ab maujood nahi hain.

* **Examples:**
  ```bash
  # Local folder remote server ke sath sync karna
  rsync -avzP ./my-app/ ubuntu@192.168.1.50:/var/www/my-app/

  # Remote server se backups download karna
  rsync -avzP ubuntu@192.168.1.50:/var/backups/ ./local_backups/

  # Custom SSH port aur private key ke sath chalana
  rsync -avzP -e "ssh -p 2222 -i ~/.ssh/prod_key" ./dist/ ubuntu@192.168.1.50:/var/www/

  # Exact mirror banana (Source aur Destination ko perfectly match karna)
  rsync -avzP --delete ./static/ ubuntu@192.168.1.50:/var/www/static/
  ```

> ⚠️ **Trailing Slash `/` Rule in rsync:**
> * `rsync -av ./folder /dest/` : Destination ke andar folder create karega (`/dest/folder/...`).
> * `rsync -av ./folder/ /dest/` : Folder ke andar ka sara saman direct destination mein daal dega bina parent folder banaye.