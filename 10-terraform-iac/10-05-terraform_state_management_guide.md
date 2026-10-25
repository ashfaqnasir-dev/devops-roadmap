# 🗄️ 10.05 Terraform State Management

Terraform ka state file (`terraform.tfstate`) aapke HCL code aur cloud par actual running infrastructure ke darmian bridge ka kaam karta hai. Is file ke zariye hi Terraform ko pata chalta hai ke kaunsa resource kab bana tha aur uske metadata attributes kya hain.

---

### 10.05.01 Local State

By default, jab aap `terraform apply` chalate hain, to Terraform usi working directory mein ek file create karta hai jiska naam `terraform.tfstate` hota hai.

* **Kaise kaam karta hai:**
  * JSON format mein resources ki mappings aur metadata save hota hai.
  * Har plan/apply se pehle Terraform is file ko cloud provider se refresh karke live drift check karta hai.
* **Local State ke Nuqsanaat:**
  * **Team Collaboration Impossible:** Team members ek doosre ke local state se sync nahi reh sakte.
  * **Accidental Loss:** Agar developer ki machine crash ho jaye to state file zaya ho sakti hai.
  * **No Git Compatibility:** State file ko Git repository mein commit **hargiz nahi** karna chahiye kyunki isme plain text sensitive passwords aur tokens shamil hotay hain.

---

### 10.05.02 Remote State (S3, Azure Blob)

Production aur team environments ke liye state file ko centralized, shared remote storage par rakha jata hai jise **Backend** kehte hain.

#### 1. AWS S3 Backend Setup
```hcl
terraform {
  backend "s3" {
    bucket         = "my-company-tf-state-prod"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks" # For state locking
  }
}
```

#### 2. Azure Blob Storage Backend Setup
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatestorageacct"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

> **Migration Tip:** Local se remote backend par switch karne ke liye `backend` block add karne ke baad `terraform init -migrate-state` command run ki jaati hai.

---

### 10.05.03 State Locking

Jab team ke do log ya multiple CI/CD pipelines ek hi waqt mein `terraform apply` run karein, to state file corrupt hone ka khatra hota hai. **State Locking** is race condition ko prevent karti hai.

* **Mechanism:**
  * Jab koi operation (plan/apply) shuru hota hai, Terraform backend par lock acquire karta hai.
  * Doosra user agar apply karega to use `Error: Error acquiring the state lock` message milega.
  * Process khatam hote hi lock release ho jata hai.
* **Implementations:**
  * **AWS S3:** DynamoDB table ke zariye (table mein primary key `LockID` string honi chahiye).
  * **Azure Blob:** Native blob leasing mechanism ke zariye automatically lock manage karta hai.
* **Emergency Command:** Agar koi pipeline crash hone se lock stuck reh jaye:
  ```bash
  terraform force-unlock <LOCK_ID>
  ```

---

### 10.05.04 `terraform state` CLI Commands

State file ko directly text editor mein manually edit karna safe nahi hota. Terraform is file ko safely inspect aur modify karne ke liye CLI commands provide karta hai:

* **1. Resources list dekhna:**
  ```bash
  terraform state list
  ```
* **2. Kisi specific resource ka data inspect karna:**
  ```bash
  terraform state show aws_instance.web
  ```
* **3. Resource rename ya module move karna (bina destroy kiye):**
  ```bash
  terraform state mv aws_instance.old_name aws_instance.new_name
  ```
* **4. Resource ko state se nikalna (Cloud par delete nahi hota, sirf Terraform manage karna chhod deta hai):**
  ```bash
  terraform state rm aws_s3_bucket.legacy_data
  ```
* **5. Raw state read ya write karna:**
  ```bash
  terraform state pull > state_backup.json
  ```

---

### 10.05.05 State File Security

State file Terraform architecture ka sabse sensitive hissa hoti hai kyunki isme databases ke passwords, IAM secrets, private keys, aur internal network IPs plain text JSON mein maujood hoti hain.

* **Top Security Best Practices:**
  1. **Never Commit to Git:** `.gitignore` mein in files ko lazmi add karein:
     ```gitignore
     *.tfstate
     *.tfstate.*
     .terraform/
     .terraform.tfstate.lock.info
     ```
  2. **Encryption at Rest:** Remote bucket par server-side encryption (jaise AWS KMS ya Azure SSE) lazmi enable karein (`encrypt = true`).
  3. **Encryption in Transit:** Remote backends hamesha TLS/HTTPS enforce karte hain.
  4. **Strict IAM Access (Least Privilege):** Sirf CI/CD pipeline aur senior DevOps admins ko state bucket ka read/write access dein.
  5. **Bucket Versioning:** S3 bucket ya Azure container par Object Versioning enable rakhein taake accidental state corruption par purana version restore kiya ja sake.