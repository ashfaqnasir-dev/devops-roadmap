# 📝 07.01 YAML Syntax — Complete Guide

> **YAML** (YAML Ain't Markup Language) ek human-readable data serialization language hai. Modern DevOps aur Cloud engineering mein yeh configuration file format ka be-taj badshah hai. Chahe **Kubernetes manifests**, **Docker Compose files**, **GitHub Actions / Azure Pipelines**, ya **Ansible playbooks** hon—har jagah YAML istemal hoti hai.

## 1. Indentation (Tabs vs Spaces Rule)

YAML mein indentation (spacing) sirf khubsoorti ke liye nahi hoti, balki yeh data ke structure aur parent-child hierarchy ko define karti hai (bilkul Python ki tarah).

```
# Parent-Child Relationship:
parent:
  child:
    grandchild: value

```

### ⚠️ The Golden Rule: Never Use Tabs!

* **Sirf Spaces use karein:** YAML parser mein **Tab (`\t`) characters strictly prohibited hain**. Agar aapne ghalti se Tab key daba di toh file parse error de degi.

* **Standard Width:** Industry standard aam tor par **2 spaces** per indentation level hota hai.

* **Consistent Alignment:** Same hierarchy level ke tamam elements ka left margin bilkul barabar (aligned) hona chahiye.

```
# ❌ Ghalt (Invalid - Tab character use kiya ya inconsistent spaces):
server:
	port: 8080      # <--- Yahan TAB lagaya (Syntax Error!)

# ✅ Sahi (Valid - 2 spaces per level):
server:
  host: 127.0.0.1
  port: 8080

```

> 💡 **VS Code Tip:** Settings mein `"editor.insertSpaces": true` aur `"editor.tabSize": 2` lazmi set karein taake Tab dabane par automatically 2 spaces insert hon.

## 2. Key-Value Pairs & Data Types

YAML ka basic building block **Key-Value Pair** hota hai. Key aur Value ke darmiyan colon (`:`) ke baad **ek space (` `) lazmi** aati hai.

```
# ❌ Ghalt:
name:John     # Colon ke baad space missing hai!

# ✅ Sahi:
name: John    # Colon ke baad space mojood hai

```

### Common Data Types:

```
# Strings (Quotes optional hain, magar special characters hon toh quotes zaroori hain)
app_name: devops-portal
environment: "production:us-east"

# Integers & Floats
replicas: 3
cpu_limit: 1.5

# Booleans (true/false, yes/no, on/off)
enabled: true
auto_scale: false

# Null Values (null ya tilde `~`)
database_password: null
backup_path: ~

# Inline Object / Map (JSON-style alternative)
database_config: { host: "localhost", port: 5432, timeout: 30 }

```

> ⚠️ **Boolean & String Trap:**
> Agar aap version number ya country code likh rahe hon jaise `version: 1.10` ya `country: NO`, toh YAML parser `1.10` ko float `1.1` samajh sakta hai aur `NO` ko boolean `false` samajh sakta hai! Isliye aisi values ko hamesha quotes mein band karein:
>
> ```
> version: "1.10"
> country: "NO"
> 
> ```

## 3. Lists / Arrays (Sequences)

Lists ko represent karne ke do mukhtalif tareeqay hain:

### A. Block Style (Dash `-` notation — Recommended):

Har list item naye line par dash aur space (`- `) ke sath shuru hota hai.

```
# Simple List
supported_browsers:
  - Chrome
  - Firefox
  - Edge

# List of Objects (Aam tor par Kubernetes pods ya pipelines mein use hota hai)
containers:
  - name: web-app
    image: nginx:alpine
    port: 80
  - name: backend-api
    image: node:18-slim
    port: 3000

```

### B. Flow Style (Inline brackets notation):

Chhoti lists ke liye JSON jaisa inline format:

```
allowed_ports: [80, 443, 8080]
tags: ["web", "frontend", "prod"]

```

## 4. Multi-Line Strings (`|` Literal vs `>` Folded)

Jab aapko lambi shell scripts ya multi-line documentation YAML ke andar likhni ho, toh do operators use hotay hain:

```
               ┌────────────────────────────────────────────────────────┐
               │                  Multi-line Operators                  │
               └───────────┬────────────────────────────────┬───────────┘
                           │                                │
                           ▼                                ▼
                 Literal Block: [ | ]             Folded Block: [ > ]
               • Newlines PRESERVED             • Newlines REPLACED with spaces
               • Output bilkul jaisa likha hai  • Pura para single line ban jata hai
               • Shell scripts ke liye behtareen• Long descriptions ke liye mufeed

```

### A. Literal Style (`|`) — "Keep Line Breaks"

Har line break (enter) bilkul waise hi mehfooz rehti hai. Pipelines aur shell commands ke liye yahi use hota hai:

```
# GitHub Actions / Azure Pipelines task example:
run_script: |
  echo "Step 1: Updating packages..."
  apt-get update -y
  echo "Step 2: Installing Docker..."
  apt-get install -y docker.io

```

*Result:* Commands line-by-line alag alag execute honge.

### B. Folded Style (`>`) — "Fold into Single Line"

Line breaks ko spaces mein tabdeel kar diya jata hai jab tak khali line na aaye:

```
description: >
  This is a very long sentence that spans across
  multiple lines in the YAML file for readability,
  but will be parsed as one single continuous line.

```

*Result:* `"This is a very long sentence that spans across multiple lines in the YAML file for readability, but will be parsed as one single continuous line."`

## 5. Comments & Directives

### A. Comments (`#`):

YAML mein single line comment ke liye hash symbol (`#`) use hota hai. YAML mein koi native multi-line comment tag (jaise `/* ... */`) nahi hota; har line ke shuru mein `#` lagana parta hai.

```
# Database Configuration
database:
  host: db.internal.local  # Production database endpoint
  port: 5432               # Standard PostgreSQL port

```

### B. Document Separator (`---`) & End Marker (`...`):

Ek hi file ke andar muta'addid (multiple) YAML documents ko alag alag karne ke liye teen dashes (`---`) use hoti hain (Kubernetes manifests mein yeh bohot aam hai):

```
# Pehla Resource: Service
apiVersion: v1
kind: Service
metadata:
  name: web-service
---
# Doosra Resource: Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
...

```

## 💡 Practical Cheatsheet: Common YAML Mistakes to Avoid

1. **Tab vs Space:** Hamesha space use karein; tab se YAML fail hoti hai.

2. **Missing Space after Colon:** `key: value` (theek), `key:value` (ghalat).

3. **Missing Space after Dash:** `- item` (theek), `-item` (ghalat).

4. **Unquoted Special Characters:** Agar value mein colons, curly braces, ya asterisks hon toh quotes lagayein: `cron: "* * * * *"`.

5. **YAML Linting Tool:** Terminal mein check karne ke liye `yamllint` CLI tool use karein:

   ```
   yamllint azure-pipelines.yml
   
   ```

**Status:** ✅ Complete