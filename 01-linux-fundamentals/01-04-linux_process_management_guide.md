# ⚙️ 01.04 Linux Process Management

Linux mein har running program, service, ya command ko ek **Process** kaha jata hai. Har process ko operating system ek unique identification number deta hai jise **PID (Process ID)** kehte hain.

---

### 01.04.01 View Processes (`ps`, `top`, `htop`)

System par chalne wale processes, resource usage (CPU/RAM), aur state ko inspect karne ke tools:

#### 1. `ps` (Process Snapshot)
Yeh current moment ka static snapshot dikhata hai:
* **Standard BSD Syntax (Sabse zyada use hone wala):**
  ```bash
  ps aux
  ```
  * `a`: Saare users ke processes dikhaye.
  * `u`: Process ke owner aur detailed resource usage (CPU/MEM%) show kare.
  * `x`: Un processes ko bhi show kare jo terminal se attach nahi hain (daemons/background services).
* **Process filter karne ke liye (`grep` ke sath):**
  ```bash
  ps aux | grep nginx
  ```

#### 2. `top` (Real-Time Dynamic Monitor)
System ka default built-in interactive monitor hai:
* Terminal par live CPU, RAM, load average, aur running tasks dikhata hai.
* Real-time update hota rehta hai (default: har 3 seconds baad).
* Useful shortcuts inside `top`:
  * `M`: Memory consumption ke hisab se sort karein.
  * `P`: CPU consumption ke hisab se sort karein.
  * `k`: Process kill karein (PID type karke).
  * `q`: Quit karein.

#### 3. `htop` (Enhanced Interactive Viewer)
`top` ka advanced, user-friendly aur color-coded version:
* Horizontal aur vertical scrolling support karta hai.
* Mouse clicks, function keys (`F1` - `F10`), aur color bars (CPU core usage/Memory/Swap) provide karta hai.
* Install & Run:
  ```bash
  sudo apt install htop -y   # Ubuntu/Debian
  htop
  ```

---

### 01.04.02 Kill Processes (`kill`, `killall`, `pkill`)

Aise processes ko band karna jo stuck ho gaye hon, freeze ho gaye hon, ya unhe terminate karna zaroori ho. Linux processes ko rokne ke liye signals bhejta hai.

#### Common Signals:
| Signal Number | Signal Name | Meaning / Behavior |
| :--- | :--- | :--- |
| **`15`** | `SIGTERM` | **Graceful Shutdown (Default):** Process ko file save aur clean-up karne ka mauqa deta hai. |
| **`9`** | `SIGKILL` | **Force Kill (Nuclear Option):** Kernel process ko foran zabardasti terminate kar deta hai; clean-up nahi hota. |
| **`1`** | `SIGHUP` | **Reload Configuration:** Service ko restart kiye baghair config reload karne ke liye. |

#### Commands:
* **`kill` (PID ke zariye):**
  ```bash
  kill 1234          # SIGTERM (Graceful - signal 15)
  kill -9 1234       # SIGKILL (Forced kill - signal 9)
  ```
* **`pkill` (Process Name pattern ke zariye):**
  ```bash
  pkill -f "python3 app.py"
  pkill -9 nginx
  ```
* **`killall` (Exact Process Name ke zariye sab instances band karna):**
  ```bash
  killall -9 node    # Saare running node instances ek sath terminate karein
  ```

---

### 01.04.03 Background Jobs (`&`, `bg`, `fg`, `jobs`)

Terminal par commands ko background mein bhejna aur manage karna taake current prompt free rahe:

* **Command ko direct background mein chalana (`&`):**
  Command ke aakhir mein `&` lagane se command background mein start hoti hai aur prompt free ho jata hai:
  ```bash
  python3 backup.py &
  ```
* **Running job ko suspend karna (`Ctrl + Z`):**
  Agar koi process chal raha ho aur aapko prompt chahiye, to `Ctrl + Z` dabayein; process pause ho jayega (`Stopped`).
* **Active jobs list dekhna (`jobs`):**
  Current terminal session ki background jobs list karta hai:
  ```bash
  jobs -l
  # Output: [1]+ 15420 Running python3 backup.py &
  ```
* **Background mein resume karna (`bg`):**
  Paused job ko background mein chalata rehta hai:
  ```bash
  bg %1
  ```
* **Foreground mein wapis lana (`fg`):**
  Job ko dobara samnay screen par le aata hai:
  ```bash
  fg %1
  ```

---

### 01.04.04 Process Persistence: `nohup` aur `tmux` / `screen`

Jab aap SSH session close karte hain ya connection toot'ta hai, to system `SIGHUP` signal bhej kar us terminal ke saare running processes band kar deta hai. Long-running jobs ko zinda rakhne ke liye yeh tools use hotay hain:

#### 1. `nohup` (No Hang Up)
Process ko `SIGHUP` signal ignore karne par majboor karta hai taake terminal band hone ke bawajood kaam jari rahe:
```bash
nohup python3 server.py > server.log 2>&1 &
```
* Yeh command terminal exit hone ke baad bhi background mein chalti rehti hai aur output `server.log` mein redirect kar deti hai.

#### 2. Terminal Multiplexers (`tmux` / `screen`)
Virtual persistent terminal sessions create karte hain jo server side par detached halat mein zinda rehte hain:
* **`tmux` Basic Workflow:**
  ```bash
  # 1. Naya session shuru karein
  tmux new -s training_session

  # 2. Session ke andar command chalayein
  python3 train_model.py

  # 3. Detach session (Bahir nikalne ke liye):
  # Press 'Ctrl + b' then press 'd'

  # 4. SSH close karke wapis aane ke baad session re-attach karein:
  tmux attach -t training_session
  ```

---

### 01.04.05 Process Priorities (`nice`, `renice`)

Linux kernel CPU resource ko prioritize karne ke liye **Nice Value** use karta hai.
* **Nice Scale:** `-20` se lekar `+19` tak hoti hai.
  * **Negative (-20):** High priority (Kernel is process ko sabse zyada CPU dega).
  * **Positive (+19):** Low priority (Bohot "nice" process hai, CPU khali hoga to chalega).
  * **Default value:** `0`

#### 1. `nice` (Naya process specific priority par start karna)
```bash
# Low priority (nice value +10) par backup chalana taake CPU choke na ho
nice -n 10 tar -czf backup.tar.gz /var/www

# High priority (-10) par chalana (Root privileges required):
sudo nice -n -10 ./critical_task
```

#### 2. `renice` (Running process ki priority change karna)
Pehle se chalte hue process ka nice level badalna:
```bash
# Running process (PID 4321) ki priority kam karke +15 karna
renice +15 -p 4321

# High priority set karna (Sudo zaroori hai):
sudo renice -10 -p 4321
```