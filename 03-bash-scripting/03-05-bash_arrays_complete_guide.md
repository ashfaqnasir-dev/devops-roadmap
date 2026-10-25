# 📚 03.05 Bash Arrays — Complete Guide

> Array ek aisi list hoti hai jisme hum ek hi variable ke andar **ek se zyada values** store kar sakte hain. Jab humein multi-server setups, container names, ya file lists ko manage karna ho, toh alag alag variables banane ke bajaye array use karna best practice hai.

## 1. Array Declaration (Array Banane ka Tareeqa)

Bash mein arrays space-separated values ke sath parentheses `( )` mein define kiye jaate hain (commas `,` use nahi hotay).

### A. Direct Assignment (Standard):

```
# Strings ki array (items ke darmiyan space hoti hai)
SERVERS=("web01" "web02" "db01" "cache01")

# Numbers ki array
PORTS=(80 443 8080 3306)

```

### B. `declare` Keyword ke sath:

```
# -a flag indexed array ke liye hota hai
declare -a APPS=("nginx" "redis" "postgres")

```

### C. Naye Elements Add Karna (Append):

```
# Existing array ke aakhir mein item add karna:
SERVERS+=("backup01")

```

## 2. Accessing Elements (Elements ko Read Karna)

Array ka index hamesha **0** se shuru hota hai. Kisi element ko access karne ke liye curly braces `${ARRAY[index]}` ka istemal laazmi hai.

```
SERVERS=("web01" "web02" "db01" "cache01")

# Pehla element (Index 0):
echo "${SERVERS[0]}"     # Output: web01

# Doosra element (Index 1):
echo "${SERVERS[1]}"     # Output: web02

# Aakhri element (Negative index):
echo "${SERVERS[-1]}"    # Output: cache01

# Tamam elements ek sath print karna (@ ya *):
echo "${SERVERS[@]}"     # Output: web01 web02 db01 cache01

```

> ⚠️ **Common Mistake:** Agar aap `$SERVERS` likhenge (bina curly braces aur index ke), toh Bash sirf pehla element (`web01`) print karega.

## 3. Array Length (Count & Size Maloom Karna)

Array mein kitne elements hain ya kisi specific item ka character count kitna hai, yeh `#` symbol se maloom kiya jata hai.

### A. Total Elements ki Tadad (Array Length):

```
SERVERS=("web01" "web02" "db01" "cache01")

# Array ke total items count karne ke liye {#ARRAY[@]}
TOTAL_COUNT="${#SERVERS[@]}"
echo "Total servers: $TOTAL_COUNT"   # Output: Total servers: 4

```

### B. Kisi Specific Item ki String Length:

```
# Pehle element ("web01") mein kitne characters hain:
echo "${#SERVERS[0]}"                # Output: 5

```

## 4. Looping Arrays (Elements par Bari Bari Kaam Karna)

Arrays ke upar iterate karne ke liye `for` loop sabse zyada use hota hai. Hamesha double quotes ke andar `"${ARRAY[@]}"` likhein taake agar kisi element mein spaces hon toh woh alag item na ban jaye.

### A. Har Value par Iterate Karna (Values Only):

```
#!/usr/bin/env bash

ENVIRONMENTS=("development" "staging" "production")

for ENV in "${ENVIRONMENTS[@]}"; do
    echo "Deploying updates to environment: $ENV"
done

```

*Output:*

```
Deploying updates to environment: development
Deploying updates to environment: staging
Deploying updates to environment: production

```

### B. Keys/Indices ke sath Iterate Karna (`!ARRAY[@]`):

Agar aapko item ke sath uska index number bhi chahiye:

```
DOCKER_CONTAINERS=("api_gateway" "auth_svc" "payment_svc")

for i in "${!DOCKER_CONTAINERS[@]}"; do
    echo "Index $i par container hai: ${DOCKER_CONTAINERS[$i]}"
done

```

*Output:*

```
Index 0 par container hai: api_gateway
Index 1 par container hai: auth_svc
Index 2 par container hai: payment_svc

```

**Status:** ✅ Complete