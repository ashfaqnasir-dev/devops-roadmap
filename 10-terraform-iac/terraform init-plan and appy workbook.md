# Terraform Workbook — init, plan, apply

> Hands-on practice book for Terraform basics.

## 🎯 Purpose

Practice `terraform init`, `plan`, `apply`, `destroy` with **local_file** provider (no cloud needed).

---

## 📋 Exercise 1: First Project (Local File)

### Setup

```bash
cd ~
rm -rf terraform-workbook
mkdir terraform-workbook
cd terraform-workbook
pwd
# /home/ashfaq/terraform-workbook
```

### Create `main.tf`

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "welcome" {
  filename = "${path.module}/welcome.txt"
  content  = "Welcome to Terraform!\nTime: ${timestamp()}"
}
```

**Save:** `Ctrl+O` → `Enter` → `Ctrl+X`

### Step 1: `terraform init`

```bash
terraform init
```

**Kya karta hai:**
- Provider (`local`) download karta hai
- `.terraform/` folder banata hai
- `.terraform.lock.hcl` lock file banata hai

**Expected Output:**
```
Initializing the backend...
Initializing provider plugins...
- Installing hashicorp/local v2.9.1...
Terraform has been successfully initialized!
```

### Step 2: `terraform plan`

```bash
terraform plan
```

**Kya karta hai:**
- `main.tf` parhta hai
- **Preview** dikhata hai (kya banega)
- **Kuch banata nahi**

**Expected Output:**
```
Terraform will perform the following actions:

  # local_file.welcome will be created
  + resource "local_file" "welcome" {
      + content  = "..."
      + filename = "./welcome.txt"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Symbols:**
| Symbol | Matlab |
|---|---|
| `+` | Create |
| `-` | Delete |
| `~` | Modify |

### Step 3: `terraform apply`

```bash
terraform apply
```

**`yes` type karein + Enter.**

**Kya karta hai:**
- Plan dobara dikhata hai
- **Confirmation maangta hai**
- Actual **file banata hai**

**Expected Output:**
```
Do you want to perform these actions?
  Enter a value: yes

local_file.welcome: Creating...
local_file.welcome: Creation complete after 0s

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

### Step 4: Verify

```bash
ls -la
cat welcome.txt
```

**Expected:**
```
welcome.txt
Welcome to Terraform!
Time: 2026-10-09T...
```

✅ **File ban gayi!**

### Step 5: `terraform destroy`

```bash
terraform destroy
```

**`yes` type karein.**

**Kya karta hai:**
- Sab resources **delete** karta hai
- State file **update** karta hai

**Expected Output:**
```
local_file.welcome: Destroying...
local_file.welcome: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
```

### Verify

```bash
ls -la
```

**`welcome.txt` gayab!** ✅

---

## 📋 Exercise 2: Multiple Files

### Update `main.tf`

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "file1" {
  filename = "${path.module}/file1.txt"
  content  = "Yeh pehli file hai"
}

resource "local_file" "file2" {
  filename = "${path.module}/file2.txt"
  content  = "Yeh doosri file hai"
}

resource "local_file" "file3" {
  filename = "${path.module}/file3.txt"
  content  = "Yeh teesri file hai"
}
```

### Practice

```bash
terraform init      # (agar pehle se kiya, skip)
terraform plan      # 3 files dikhengi
terraform apply     # yes
# yes type karein

ls -la              # file1.txt, file2.txt, file3.txt

terraform destroy
# yes type karein
```

**Expected:** 3 files banti hain, phir delete hoti hain.

---

## 📋 Exercise 3: File Update

### Pehla Version

```hcl
resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0"
}
```

```bash
terraform apply
# yes

cat config.txt
# version=1.0
```

### Update Version

```hcl
resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=2.0"
}
```

```bash
terraform plan
```

**Expected:**
```
~ resource "local_file" "config" {
    ~ content = "version=1.0" -> "version=2.0"
  }

Plan: 0 to add, 1 to change, 0 to destroy.
```

**`~` = Modify!**

```bash
terraform apply
# yes

cat config.txt
# version=2.0
```

**Ahem:** Terraform ne **change detect** kiya (`~`) aur **file update** ki.

---

## 📋 Exercise 4: Variables

### Update `main.tf`

```hcl
variable "filename" {
  default = "config.txt"
}

variable "content" {
  default = "default content"
}

resource "local_file" "config" {
  filename = "${path.module}/${var.filename}"
  content  = var.content
}
```

### Practice

```bash
terraform apply
# yes

cat config.txt
# default content
```

### Change Values

```bash
terraform apply -var="filename=app.txt" -var="content=Hello Terraform"
# yes

cat app.txt
# Hello Terraform
```

**Ahem:** `-var` flag se **runtime par values change** kar sakte hain.

---

## 📋 Exercise 5: Outputs

### Add Output

```hcl
resource "local_file" "info" {
  filename = "${path.module}/info.txt"
  content  = "Terraform practice"
}

output "file_path" {
  value = local_file.info.filename
}

output "file_content" {
  value = local_file.info.content
}
```

### Practice

```bash
terraform apply
# yes
```

**Output:**
```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

file_path    = "./info.txt"
file_content = "Terraform practice"
```

**Outputs** = Aap ki config ka **result** — `terraform output` se kabhi bhi dekh sakte hain:

```bash
terraform output
```

---

## 🎯 Command Reference

| Command | Kaam | Confirmation |
|---|---|---|
| `terraform init` | Setup + download | Nahi |
| `terraform plan` | Preview | Nahi |
| `terraform apply` | Execute | **Haan** (yes) |
| `terraform destroy` | Cleanup | **Haan** (yes) |
| `terraform output` | Show outputs | Nahi |
| `terraform fmt` | Format code | Nahi |
| `terraform validate` | Check syntax | Nahi |

---

## 📊 State File — Important

### Kya Hai?

Terraform **state file** (`terraform.tfstate`) mein record rakhta hai:
- Kya resources bane
- Unki current state
- Dependencies

### Kahan Hai?

```bash
ls -la *.tfstate*
```

**Output:**
```
terraform.tfstate
terraform.tfstate.backup
```

### Kyun Zaroori?

Agar state file **delete** ho jaye, to Terraform **nahi jaanega** ke kya bana hua hai — aur **sab kuch dobara banayega**.

**State file ko `.gitignore` mein daalein:**
```
*.tfstate
*.tfstate.backup
```

---

## 🎯 Common Workflows

### Workflow 1: Naya Resource Add

```bash
# 1. main.tf edit karein (naya resource)
# 2. Plan
terraform plan     # Naya resource dikhega (+)

# 3. Apply
terraform apply
# yes
```

### Workflow 2: Resource Change

```bash
# 1. main.tf edit karein (existing resource)
# 2. Plan
terraform plan     # Change dikhega (~)

# 3. Apply
terraform apply
# yes
```

### Workflow 3: Resource Delete

```bash
# 1. main.tf se resource hataayein
# 2. Plan
terraform plan     # Delete dikhega (-)

# 3. Apply
terraform apply
# yes
```

---

## 💡 Key Learnings

- `terraform init` — **ek baar** per project
- `terraform plan` — **hamesha** apply se pehle
- `terraform apply` — **`yes`** confirm karta hai
- `terraform destroy` — **cleanup**
- State file — **kabhi GitHub par commit nahi**
- `+` `-` `~` — Create, Delete, Modify

---

## 🎁 Practice Checklist

- [ ] Exercise 1: First project (local_file)
- [ ] Exercise 2: Multiple files
- [ ] Exercise 3: File update
- [ ] Exercise 4: Variables
- [ ] Exercise 5: Outputs

---

**Status:** 📘 Workbook
**Level:** Beginner
**Date:** 2026-10-09