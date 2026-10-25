# 🔁 03.03 Bash Loops — Complete Guide

> Loop ka matlab hai ek hi code block ko **baar baar repeat** karna jab tak koi makhsoos condition poori na ho jaye. Automation aur tasks ko repeat karne ke liye loops bunyadi hathyar hain.

---

## 1. `for` Loop (Fixed Iterations)

Jab aapko pehle se pata ho ke kisi code ko kitni martaba chalana hai ya kisi list ke har item par kaam karna hai, toh `for` loop use hota hai.

### A. List ya Elements par chalana:
```bash
for SERVER in web01 web02 db01; do
    echo "Connecting to: $SERVER"
done
```

### B. Number Range ke sath chalana `{start..end}`:
```bash
# 1 se 5 tak ginti
for i in {1..5}; do
    echo "Iteration: $i"
done

# Step size ke sath (1 se 10 tak, har dafa 2 barhana):
for i in {1..10..2}; do
    echo "Odd number: $i"
done
```

### C. C-Style Syntax (Traditional counter):
```bash
for ((i=1; i<=3; i++)); do
    echo "Step number: $i"
done
```

### D. Files par iterate karna (Real-world DevOps use case):
```bash
for FILE in *.log; do
    echo "Backing up log: $FILE"
    # tar -czf "$FILE.tar.gz" "$FILE"
done
```

---

## 2. `while` Loop (Jab tak Condition True ho)

`while` loop tab tak chalta rehta hai jab tak uski condition **True** rehti hai. Jaise hi condition False hoti hai, loop ruk jata hai.

```bash
COUNT=1

while [[ $COUNT -le 3 ]]; do
    echo "Count hai: $COUNT"
    COUNT=$((COUNT + 1))
done
```

### File ko Line-by-Line parhna (`while IFS= read`):
```bash
# servers.txt file se har line bari bari read karna
while IFS= read -r LINE; do
    echo "Pinging: $LINE"
done < servers.txt
```

---

## 3. `until` Loop (Jab tak Condition False ho)

`until` loop `while` ka bilkul ulta hota hai. Yeh tab tak chalta rehta hai jab tak condition **False** rehti hai, aur jaise hi condition **True** hoti hai, foran ruk jata hai.

> *Sochne ka tareeqa:* "Tab tak chalo jab tak yeh kaam na ho jaye!"

```bash
ATTEMPTS=1

until [[ $ATTEMPTS -gt 3 ]]; do
    echo "Checking connection... Attempt: $ATTEMPTS"
    ATTEMPTS=$((ATTEMPTS + 1))
done
```

---

## 4. Loop Control (`break` & `continue`)

Loop ke natural flow ko control karne ke liye do keywords use hotay hain:

### A. `break` (Loop ko foran khatam karna)
Jab koi makhsoos shart poori ho jaye aur baaqi loop chalane ki zaroorat na ho:

```bash
for NUM in {1..10}; do
    if [[ $NUM -eq 5 ]]; then
        echo "5 mil gaya! Loop yahan khatam."
        break
    fi
    echo "Number: $NUM"
done
```

### B. `continue` (Current iteration ko skip karna)
Agla round shuru karne ke liye current round ko adhoora chhor dena:

```bash
for NUM in {1..5}; do
    if [[ $NUM -eq 3 ]]; then
        echo "3 ko skip kar rahe hain..."
        continue
    fi
    echo "Number: $NUM"
done
```

---

## 5. Nested Loops (Loop ke andar Loop)

Jab ek loop ke andar doosra loop chalaya jaye to usay **Nested Loop** kehte hain. Yeh matrix, grids, ya multi-server environments deploy karne ke kaam aata hai.

```bash
# Bahir wala loop environments ke liye, andar wala servers ke liye
for ENV in "dev" "prod"; do
    echo "--- Setting up Environment: $ENV ---"
    
    for NODE in "node-1" "node-2"; do
        echo "Deploying container on $ENV-$NODE"
    done
done
```

*Output:*
```text
--- Setting up Environment: dev ---
Deploying container on dev-node-1
Deploying container on dev-node-2
--- Setting up Environment: prod ---
Deploying container on prod-node-1
Deploying container on prod-node-2
```

---
**Status:** ✅ Complete