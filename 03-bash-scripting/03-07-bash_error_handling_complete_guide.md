# 🛡️ 03.07 Error Handling — Complete Guide

> By default, Bash ghaltiyon ko nazar-andaz karta hai aur agar koi command fail bhi ho jaye toh agle steps chalata rehta hai. Production scripts aur CI/CD pipelines mein yeh behavior intehai khatarnaak ho sakta hai. **Error handling** ke zariye hum script ko robust, safe aur predictable banate hain.

---

## 1. Exit Codes (`$?` & `exit`)

Linux mein har command ya script complete hone par ek numeric **Exit Code** (status code) return karti hai jo `$?` variable mein store hota hai.

- **`0`**: Success (Kaam theek se complete hua).
- **`1 - 255`**: Failure (Koi error ya issue aaya).

### Example:
```bash
#!/usr/bin/env bash

mkdir /root/test_dir 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo "Directory ban gayi ✅"
else
    echo "Directory nahi ban saki (Permission denied) ❌"
    exit 1  # Script ko failure code ke sath exit karna
fi
```

---

## 2. `set -e` (Exit on Error)

Agar script mein koi bhi command non-zero status ke sath fail ho, toh `set -e` poori script ko **foran terminate** kar deta hai taake aage ghair-mutawaqqe tabahi na ho.

### Danger without `set -e`:
```bash
cd /non/existent/folder   # Fail ho jayega
rm -rf *                 # Agar script na ruki toh current folder ka sab urr jayega!
```

### Safe with `set -e`:
```bash
#!/usr/bin/env bash
set -e

cd /non/existent/folder  # Yahan script foran ruk jayegi
rm -rf *                 # Yeh line kabhi execute nahi hogi
```

> **Note:** Agar kisi specific command par fail hone ke bawajood script na rokni ho, toh `|| true` use karein:
> ```bash
> grep "pattern" file.txt || true
> ```

---

## 3. `set -u` (Treat Unset Variables as Error)

By default agar aap kisi aise variable ko use karein jo pehle define nahi hua, toh Bash use khali string (`""`) samajh leta hai. `set -u` aisi soorat mein script ko error de kar foran rok deta hai.

### Danger without `set -u`:
```bash
TARGET_DIR="" # Ya define hi nahi kiya
rm -rf "${TARGET_DIR}/*"  # Yeh "rm -rf /*" ban jayega aur poora system delete ho jayega!
```

### Safe with `set -u`:
```bash
#!/usr/bin/env bash
set -u

echo "Connecting to $SERVER_IP"  # Error: SERVER_IP: unbound variable
```

---

## 4. `set -o pipefail` (Pipeline Failure Detection)

Jab aap do ya teen commands ko pipe (`|`) karte hain, toh Bash by default sirf **aakhri command** ka exit status dekhta hai. `set -o pipefail` ensure karta hai ke agar pipeline ke kisi bhi hissay mein koi command fail hui ho, toh poori pipeline ka status failure consider ho.

### Pipeline Behavior:
```bash
# Farz karein missing_file.txt maujood nahi hai:
cat missing_file.txt | grep "admin" | sort
```
- **Bina `pipefail` ke:** `sort` theek chala, isliye exit code `0` aayega (`set -e` trigger nahi hoga).
- **With `set -o pipefail`:** `cat` fail hua, isliye poori chain fail consider hogi aur `set -e` script rok dega.

### 💡 The Golden Standard (Unofficial Bash Strict Mode):
Har production script ke top par yeh line zaroor shamil karein:
```bash
#!/usr/bin/env bash
set -euo pipefail
```

---

## 5. `trap` (Signal Catching & Cleanup Automation)

`trap` script ko signals (jaise Ctrl+C / `SIGINT`, termination / `SIGTERM`) ya normal `EXIT` par makhsoos cleanup functions run karne ki sahulat deta hai.

### Practical Use Case: Temporary files delete karna
```bash
#!/usr/bin/env bash
set -euo pipefail

# Temporary file banayein
TMP_FILE=$(mktemp)
echo "Temp file created at: $TMP_FILE"

# Cleanup function define karein
cleanup() {
    echo "🧹 Cleanup running... Removing temporary files."
    rm -f "$TMP_FILE"
}

# Chahe script normally exit ho ya beech mein fail/cancel ho, cleanup chalega
trap cleanup EXIT

# Script tasks...
echo "Processing critical operations..."
sleep 2

# Script yahan khatam hote hi 'cleanup' automatically execute hoga
```

---

**Status:** ✅ Complete