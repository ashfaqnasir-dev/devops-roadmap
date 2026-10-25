# 🧩 03.04 Bash Functions — Complete Guide

> Function code ka ek aisa tukra (reusable block) hota hai jise aap ek naam de dete hain, aur poori script mein jahan bhi zaroorat ho sirf uska naam likh kar usay baar baar chala sakte hain. Isse code duplicate nahi hota aur clean rehta hai (DRY principle: Don't Repeat Yourself).

---

## 1. Basic Functions (Banane aur Call karne ka Tareeqa)

Bash mein function do tareeqon se define kiya ja sakta hai. Function ko use karne ke liye pehle usay script mein define karna laazmi hota hai, phir baad mein call kiya jata hai.

### Syntax Options:
```bash
# Tareeqa 1 (Standard & Recommended):
greet_user() {
    echo "Khush amdeed! Welcome to DevOps Hub."
}

# Tareeqa 2 ('function' keyword ke sath):
function server_status {
    echo "Checking server status..."
    uptime
}

# Function ko chalana (Call karna):
# Sirf function ka naam likhein bina kisi bracket ke!
greet_user
server_status
```

> ⚠️ **Important:** Function ko define karne ke baad call karein. Agar pehle call karenge toh Bash bolega: `command not found`.

---

## 2. Arguments (Parameters Pass Karna)

Functions ko data pass karne ke liye aap unke aage space de kar values likhte hain. Bash functions un values ko positional parameters (`$1`, `$2`, waghera) ke zariye access karte hain.

### Key Positional Variables:
* `$1`, `$2`, `$3` : Pehla, doosra, aur teesra argument.
* `$#` : Function ko kitne total arguments diye gaye.
* `$@` : Tamam arguments ek list ke tor par.

### Example:
```bash
backup_file() {
    local SOURCE_FILE="$1"
    local DEST_DIR="$2"

    echo "Total arguments received: $#"
    echo "Copying $SOURCE_FILE to $DEST_DIR..."
    
    # cp "$SOURCE_FILE" "$DEST_DIR/"
}

# Arguments pass karte hue call karna:
backup_file "app.log" "/var/backups"
backup_file "db.sql" "/mnt/storage"
```

---

## 3. Return Values (Exit Code vs Data Return)

Doosri programming languages (jaise Python ya JavaScript) ki tarah Bash ka `return` keyword data ya string wapis nahi karta! 

Bash mein do mukhtalif cheezon ka farq samajhna zaroori hai:

### A. `return` (Sirf Exit Status / Status Code ke liye):
`return` sirf ek integer number (`0` se `255`) wapis karta hai jo batata hai ke function theek chala (`0`) ya fail hua (non-zero). Yeh value `$?` mein save hoti hai.

```bash
check_port() {
    local PORT="$1"
    if [[ "$PORT" -eq 80 || "$PORT" -eq 443 ]]; then
        return 0  # Success (Port valid hai)
    else
        return 1  # Failure (Port disallowed hai)
    fi
}

check_port 80
if [[ $? -eq 0 ]]; then
    echo "Port check passed ✅"
else
    echo "Port check failed ❌"
fi
```

### B. Output / Data Return Karna (`echo` + Command Substitution):
Agar aapko text, calculate kiya hua number, ya string wapis chahiye, toh function ke andar `echo` karein aur bahir `$(...)` ke sath capture karein:

```bash
calculate_tax() {
    local AMOUNT="$1"
    local TAX=$(( AMOUNT * 15 / 100 ))
    
    echo "$TAX"  # Data return karne ka tareeqa
}

# Output ko variable mein capture karein:
MY_TAX=$(calculate_tax 1000)
echo "Tax amount hai: Rs. $MY_TAX"
```

---

## 4. Local Variables (`local` Keyword)

By default, Bash ke andar banaye gaye saare variables **Global** hote hain—yani agar aapne function ke andar koi variable banaya, toh woh poori script mein change ho jayega.

Is maslay se bachne ke liye hamesha function ke andar `local` keyword use karein taake variable sirf us function ki hadd tak mehdood rahe.

### Comparison Example:
```bash
#!/usr/bin/env bash

APP_NAME="MainProductionApp"

unsafe_function() {
    APP_NAME="StagingApp"  # Global variable overwrite ho gaya!
}

safe_function() {
    local APP_NAME="TestingApp"  # Yeh sirf is function ke andar rahega
    echo "Function ke andar APP_NAME: $APP_NAME"
}

echo "Shuru mein: $APP_NAME"     # Output: MainProductionApp

safe_function                   # Output: Function ke andar: TestingApp
echo "Safe call ke baad: $APP_NAME" # Output: MainProductionApp (Safe!)

unsafe_function
echo "Unsafe call ke baad: $APP_NAME" # Output: StagingApp (Kharab ho gaya!)
```

> 💡 **Best Practice Rule:** Function ke andar jab bhi koi naya variable banayein ya `$1`, `$2` ko save karein, hamesha `local` keyword ka istemal karein!

---

**Status:** ✅ Complete