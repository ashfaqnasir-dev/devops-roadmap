# 🌍 10.01 Terraform Basics

HashiCorp Terraform ek open-source **Infrastructure as Code (IaC)** tool hai jo aapko cloud (AWS, Azure, GCP, DigitalOcean) aur on-premise infrastructure ko human-readable declarative configuration files (HCL) ke zariye provision aur manage karne ki sahulat deta hai.

---

### 10.01.01 What is IaC (Infrastructure as Code)?

Infrastructure as Code (IaC) ka matlab hai servers, networks, databases aur storage ko cloud consoles par manual click karne ke bajaye code files ke zariye define aur deploy karna.

* **Traditional Manual Setup ke Maslay:**
  * Human error ka khatra (misconfiguration).
  * Inconsistent environments (dev aur prod alag dikhte hain).
  * Disaster recovery bohot slow hoti hai.
* **IaC ke Fawaid:**
  * **Version Controlled:** Infra code Git mein track hota hai (PR review, history, rollbacks).
  * **Repeatable & Consistent:** Ek click par exact same infra naye region mein recreate kiya ja sakta hai.
  * **Declarative Approach:** Aap Terraform ko batate hain ke *kya chahiye* (end state), yeh khud decide karta hai ke *kaise banana hai*.

---

### 10.01.02 Install Terraform

Terraform ek single standalone binary file ke tor par distribute hota hai.

* **Linux (Ubuntu/Debian):**
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```

* **macOS (via Homebrew):**
  ```bash
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```

* **Windows:**
  * Chocolatey ke zariye: `choco install terraform`
  * Ya official site se `.exe` download karke System `PATH` mein add karein.

* **Verify Installation:**
  ```bash
  terraform -version
  ```

---

### 10.01.03 `terraform init` (Initialize Working Directory)

Kisi bhi Terraform project ka sabse pehla aur laazmi step.

* **Description:** Yeh command configuration files (`*.tf`) ko scan karti hai aur required **Provider Plugins** (jaise AWS, Docker, Azure providers) ko download karti hai.
* **Behind the scenes:**
  * Ek `.terraform` hidden folder banata hai jisme binary plugins download hote hain.
  * Dependency lock file (`.terraform.lock.hcl`) generate karta hai taake team members ke paas exact same provider versions use hon.
* **Command:**
  ```bash
  terraform init
  ```

---

### 10.01.04 `terraform plan` (Dry Run / Preview)

Real infrastructure par koi bhi change apply karne se pehle dry run check karna.

* **Description:** Terraform aapke `.tf` code ko current state se compare karta hai aur execution plan banata hai ke kaunse resources add honge, kaunse modify honge, aur kaunse delete honge.
* **Symbology:**
  * `+` **Create:** Naya resource banne ja raha hai.
  * `~` **Update in-place:** Maujooda resource modify hoga bina delete hue.
  * `-` **Destroy:** Resource delete ho jayega.
  * `- / +` **Replace:** Resource pehle delete hoga, phir naya banega.
* **Command:**
  ```bash
  terraform plan
  # Plan ko file mein save karne ke liye:
  terraform plan -out=tfplan
  ```

---

### 10.01.05 `terraform apply` (Provision Infrastructure)

Plan kiye gaye changes ko cloud provider ke upar physically execute karna.

* **Description:** Yeh command actual cloud APIs call karti hai resources create/update karne ke liye. Execution se pehle yeh user se explicit confirmation (`yes`) maangti hai.
* **State Update:** Resources create hone ke baad Terraform sari live information `terraform.tfstate` file ke andar record kar leta hai.
* **Commands:**
  ```bash
  # Manual confirmation ke sath apply karein:
  terraform apply

  # Automated CI/CD pipelines ke liye (bina prompt ke):
  terraform apply -auto-approve

  # Pehle se save kiye gaye plan ko execute karne ke liye:
  terraform apply tfplan
  ```

---

### 💡 Quick Hands-on Sample (`main.tf`)

Ek simple Docker container chalane ka sample Terraform code:

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Image pull karein
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

# Container run karein
resource "docker_container" "nginx_server" {
  image = docker_image.nginx.image_id
  name  = "my-tf-nginx"
  ports {
    internal = 80
    external = 8080
  }
}
```

*Workflow execution order:*
```bash
terraform init    # Plugins download
terraform plan    # Changes preview
terraform apply   # Container live
```