# 📄 01.02 Linux File Operations

Linux terminal par files aur directories ke sath rozmarra ka kaam karne ke liye standard core utilities use ki jaati hain. Yeh commands files banane, copy karne, rename karne, inspect karne aur dhoondne ke liye bunyadi auzar hain.

### 01.02.01 Create (`touch`, `mkdir`)

Nayi empty files aur directories (folders) banane ke liye commands:

* **`touch`**: Nayi khali file banata hai ya pehle se maujood file ka timestamp update karta hai.

  ```
  touch app.py                # Single file banana
  touch index.html style.css  # Ek sath multiple files banana
  
  ```

* **`mkdir` (Make Directory)**: Naya folder create karta hai.

  ```
  mkdir projects              # Single folder banana
  mkdir -p api/v1/routes      # Parent folders ke sath nested structure banana (-p = parents)
  
  ```

### 01.02.02 Copy (`cp`)

Files aur folders ko duplicate karne ke liye use hota hai.

* **Description**: Original file apni jagah rehti hai aur specified destination par uski copy ban jaati hai. Folders ko copy karne ke liye recursive flag (`-r`) lazmi hota hai.

* **Common Flags**:

  * `-r` ya `-R`: Recursive (folders aur unke andar ka sara content copy karne ke liye)

  * `-i`: Interactive (agar file pehle se maujood ho to overwrite se pehle confirm karta hai)

  * `-v`: Verbose (screen par dikhata hai kya copy ho raha hai)

* **Examples**:

  ```
  cp config.json config.json.bak      # File ki backup copy banana
  cp app.py /opt/backup/              # File ko doosri directory mein copy karna
  cp -r ./src /opt/backup/src_backup  # Poora directory tree copy karna
  
  ```

### 01.02.03 Move & Rename (`mv`)

Files aur folders ko ek jagah se doosri jagah shift karne ya unka naam badalne ke liye use hota hai.

* **Description**: Linux mein file ka "naam badalna" aur "move karna" ek hi operation hai (`mv`). Isme original file previous location se hat jaati hai.

* **Common Flags**:

  * `-i`: Pehle se bani file overwrite hone se pehle confirmation maangta hai.

  * `-u`: Sirf tab move/overwrite karega jab source file destination wali se nayi (newer) ho.

* **Examples**:

  ```
  mv old_name.txt new_name.txt        # File rename karna
  mv script.sh ./scripts/             # File ko folder ke andar move karna
  mv server.js ./src/app.js           # Move aur rename ek sath karna
  
  ```

### 01.02.04 Delete (`rm`, `rmdir`)

Files aur directories ko delete (remove) karne ke liye use hota hai.

> ⚠️ **Warning**: Linux terminal par graphical Recycle Bin / Trash nahi hota. Yahan se delete kiya gaya data direct permanently delete ho jata hai.

* **`rmdir`**: Sirf **khali** (empty) directories ko delete karta hai.

  ```
  rmdir empty_folder
  
  ```

* **`rm`**: Files aur non-empty directories ko delete karne ke liye standard tool hai.

  * `-r`: Folders aur unke andar ka sara data recursively delete karna.

  * `-f`: Force delete (bina warning ya write-protected confirmation maange).

  * `-i`: Har file delete hone se pehle user se confirmation maangta hai (safe practice).

* **Examples**:

  ```
  rm temp.txt                         # Single file delete
  rm -i *.log                         # Saari .log files confirmation ke sath delete
  rm -rf ./build/                     # Folder aur uska tamam data forcibly delete karna
  
  ```

### 01.02.05 View File Contents (`cat`, `less`, `head`, `tail`)

Files ko open ya modify kiye baghair terminal par unka data dekhne ke tools:

| Command | Best Use Case | Features / Options | 
| ----- | ----- | ----- | 
| **`cat`** | Choti files ko terminal par print karna | File ke saare contents ek sath stream kar deta hai. Line numbers ke liye: `cat -n file.txt` | 
| **`less`** | Badi files ya configs ko scroll karke padhna | Paging utility; arrow keys se up/down scroll karein, `/` se search karein, aur `q` daba kar exit karein. | 
| **`head`** | File ki shuruati lines dekhna | Default par pehli 10 lines dikhata hai. Custom lines: `head -n 20 file.txt` | 
| **`tail`** | File ki aakhri lines dekhna (Logs ke liye ideal) | Default par aakhri 10 lines show karta hai. Custom lines: `tail -n 50 file.log` | 

* **Real-time Log Monitoring (`tail -f`)**:
  DevOps aur system troubleshooting ka sabse ahem tool jo live logs stream karta rehta hai:

  ```
  tail -f /var/log/nginx/access.log
  
  ```

### 01.02.06 Find (`find`, `locate`)

System par specific criteria ke mutabiq files aur folders dhoondne ke auzar:

#### 1. `find` (Real-time File Search)

Direct disk scan karta hai. Yeh sabse flexible aur powerful search tool hai.

* **Search by Name**:

  ```
  find /var/www -name "*.html"        # Exact case-sensitive match
  find . -iname "config.json"         # Case-insensitive match
  
  ```

* **Search by Type**:

  ```
  find /home/ubuntu -type f -name "*.py"  # Sirf regular files (-type f)
  find /etc -type d -name "nginx*"        # Sirf directories (-type d)
  
  ```

* **Search by Size & Modification Time**:

  ```
  find /var/log -type f -size +100M       # 100MB se badi files
  find /tmp -type f -mtime -2             # Pichle 48 ghanton (2 din) mein modify hui files
  
  ```

* **Find and Execute (`-exec`)**:
  Dhoondi gayi files par direct koi command chalana:

  ```
  # Tamam .log files dhoond kar delete karna:
  find /var/log/app -name "*.log" -exec rm -f {} \;
  
  ```

#### 2. `locate` (Database-based Fast Search)

Disk scan karne ke bajaye pehle se bani database (`mlocate.db`) se search karta hai, is liye yeh instant search result deta hai.

* **Description**: Tez hota hai lekin newly created files shayad na dikhaye jab tak iska database update na ho.

* **Commands**:

  ```
  sudo updatedb                       # Database manually update karna
  locate nginx.conf                   # Fast path lookup
  
  ```