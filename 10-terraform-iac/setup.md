# Terraform — Installation & Basics

> Quick guide to install Terraform on WSL and run first project.

## 🛠️ Installation Steps

### 1. Install Tools

```bash
sudo apt update
sudo apt install -y wget unzip
```

### 2. Download Terraform

```bash
wget https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip
```

### 3. Unzip

```bash
unzip terraform_1.9.5_linux_amd64.zip
```

### 4. Install to System Path

```bash
sudo mv terraform /usr/local/bin/
```

**Kyun `/usr/local/bin/`:** System binaries folder — `$PATH` mein hai, is liye `terraform` kahin se chalti hai.

### 5. Verify

```bash
terraform --version
# Terraform v1.9.5 on linux_amd64
```

---

## 🎯 First Project

### 1. Setup Folder

```bash
mkdir ~/terraform-practice
cd ~/terraform-practice
```

### 2. Create `main.tf`

```hcl
terraform {
  required_version = ">= 1.0"
}

resource "local_file" "example" {
  filename = "${path.module}/hello.txt"
  content  = "Terraform se banaya gaya file!\nTimestamp: ${timestamp()}"
}
```

### 3. Run Commands

```bash
terraform init      # Setup + download provider
terraform plan      # Preview
terraform apply     # Execute (type: yes)
terraform destroy   # Cleanup (type: yes)
```

---

## 📊 Terraform Workflow

```
main.tf       ← Aap likhte hain (WHAT?)
    ↓
terraform init    ← Providers setup
    ↓
terraform plan    ← Preview
    ↓
terraform apply   ← Execute
    ↓
terraform destroy ← Cleanup
```

---

## 💡 Provider Concept

**Provider** = Plugin jo Terraform ko kisi service se connect karta hai.

| Category | Examples | Kya Connect |
|---|---|---|
| **Cloud** | `azurerm`, `aws`, `google` | Cloud APIs (credentials chahiye) |
| **Local** | `local`, `null`, `random` | Aap ka computer |

**Provider 2 jagah:**
1. **Registry** — `registry.terraform.io` (download source)
2. **Aap ka PC** — `.terraform/providers/` (download ke baad)

---

## 📂 Files Jo Banti Hain

| File | Kaam |
|---|---|
| `main.tf` | Configuration |
| `.terraform/` | Downloaded providers |
| `.terraform.lock.hcl` | Version lock |
| `terraform.tfstate` | State (kya bana) |

**`.gitignore` mein daalein:**
```
.terraform/
*.tfstate
*.tfstate.backup
```

---

## 🎯 Useful Commands

| Command | Kaam |
|---|---|
| `terraform init` | Setup + download providers |
| `terraform plan` | Preview changes |
| `terraform apply` | Execute |
| `terraform destroy` | Delete everything |
| `terraform fmt` | Format code |
| `terraform validate` | Check syntax |

---

**Status:** ✅ Terraform v1.9.5 installed
**Date:** 2026-10-09