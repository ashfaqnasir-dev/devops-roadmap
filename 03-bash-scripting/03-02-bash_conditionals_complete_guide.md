# 🔀 03.02 Bash Conditionals — Complete Guide

> Conditionals ka matlab hai script mein **faisle karna (decision making)**. Agar koi condition sahi (True) ho toh ek kaam karein, agar ghalat (False) ho toh doosra kaam karein.

---

## 1. `if-else` (Agar / Warna)

Yeh sabse bunyadi faisla karne ka structure hai. Bash mein test condition ke liye hamesha square brackets `[[ ... ]]` use kiye jaate hain.

```bash
AGE=18

if [[ $AGE -ge 18 ]]; then
    echo "Aap vote daalne ke ahal hain."
else
    echo "Aap abhi chhotay hain, vote nahi de sakte."
fi
```

> **Syntax Tip:** `if [[ condition ]]; then` ke format mein brackets ke dono taraf space hona laazmi hai, warna syntax error aayega.

---

## 2. `elif` (Else If — Multiple Checks)

Jab aapke paas do se zyada sharaait (conditions) hon, toh `elif` use hota hai.

```bash
MARKS=78

if [[ $MARKS -ge 80 ]]; then
    echo "Grade: A"
elif [[ $MARKS -ge 70 ]]; then
    echo "Grade: B"
elif [[ $MARKS -ge 60 ]]; then
    echo "Grade: C"
else
    echo "Grade: Fail"
fi
```

---

## 3. `case` (Multiple Choices / Pattern Matching)

Jab ek hi variable ko bohot saari options ke sath match karna ho, toh lambi `if-elif` chain likhne ke bajaye `case` bohot saaf aur aasan rehta hai. CLI arguments aur menus ke liye yeh best hai.

```bash
ACTION="restart"

case "$ACTION" in
    start)
        echo "Service start ho rahi hai..."
        ;;
    stop)
        echo "Service stop ki ja rahi hai..."
        ;;
    restart|reload)
        echo "Service reload ho rahi hai..."
        ;;
    *)
        echo "Ghalat option! Use: start, stop, restart"
        ;;
esac
```

> **Rules:**
> - Har option ke aakhir mein double semi-colon (`;;`) lagana laazmi hota hai.
> - `*)` default fallback hota hai jo kisi bhi unmatched option ko pakadta hai.
> - Statement ka ikhtetaam `esac` (`case` ka ulta) par hota hai.

---

## 4. Comparison Operators (Muazna Karne Ke Nishaan)

Bash mein **Numbers** aur **Strings (Text)** ke liye alag operators use hotay hain:

### A. Number Operators (Integer Comparison)
| Operator | Matlab | Example |
| :--- | :--- | :--- |
| `-eq` | Equal to ($==$) | `[[ $A -eq $B ]]` |
| `-ne` | Not equal to ($\neq$) | `[[ $A -ne $B ]]` |
| `-gt` | Greater than ($>$) | `[[ $A -gt $B ]]` |
| `-ge` | Greater than or equal to ($\ge$) | `[[ $A -ge $B ]]` |
| `-lt` | Less than ($<$) | `[[ $A -lt $B ]]` |
| `-le` | Less than or equal to ($\le$) | `[[ $A -le $B ]]` |

### B. String Operators (Text Comparison)
| Operator | Matlab | Example |
| :--- | :--- | :--- |
| `==` | Strings barabar hain | `[[ "$NAME" == "Ali" ]]` |
| `!=` | Strings barabar nahi hain | `[[ "$ROLE" != "Admin" ]]` |
| `-z` | String bilkul khali (empty) hai | `[[ -z "$PASSWORD" ]]` |
| `-n` | String mein kuch likha hua hai | `[[ -n "$TOKEN" ]]` |

---

## 5. File Test Operators (Files Aur Folders Check Karna)

DevOps scripts mein sabse zyada use hone wale operators jo check karte hain ke disk par file ya folder mojood hai ya nahi:

| Operator | Check Karta Hai | Example |
| :--- | :--- | :--- |
| **`-f`** | Kya yeh ek regular file hai? | `[[ -f "/etc/hosts" ]]` |
| **`-d`** | Kya yeh ek folder (directory) hai? | `[[ -d "/var/log" ]]` |
| **`-e`** | Kya yeh file/folder exist karta hai? | `[[ -e "backup.tar.gz" ]]` |
| **`-s`** | File mojood hai aur khali nahi hai ($size > 0$) | `[[ -s "error.log" ]]` |
| **`-r`** | Kya file ko Read karne ki permission hai? | `[[ -r "data.csv" ]]` |
| **`-w`** | Kya file par Write karne ki permission hai? | `[[ -w "app.log" ]]` |
| **`-x`** | Kya file Executable hai? | `[[ -x "deploy.sh" ]]` |

### Practical DevOps Example:
```bash
BACKUP_DIR="/var/backups"
LOG_FILE="/var/log/app.log"

if [[ -d "$BACKUP_DIR" ]]; then
    echo "Backup directory pehle se mojood hai."
else
    echo "Directory nahi mili, create ki ja rahi hai..."
    mkdir -p "$BACKUP_DIR"
fi

if [[ -s "$LOG_FILE" ]]; then
    echo "Log file mein errors mojood hain, check karein."
fi
```

---
**Status:** ✅ Complete