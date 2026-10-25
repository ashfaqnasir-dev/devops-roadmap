# 🧱 10.04 Terraform Resources

Resources Terraform HCL ka sabse eham building block hotay hain. Har resource infrastructure ke kisi real-world cloud component (jaise EC2 instance, VPC, database, ya DNS record) ko represent aur manage karta hai.

---

### 10.04.01 Resource Blocks

Resource block batata hai ke kaunsa resource type create karna hai aur uske attributes kya honge.

* **Syntax Structure:**
  ```hcl
  resource "<RESOURCE_TYPE>" "<LOCAL_NAME>" {
    attribute_name = "value"
  }
  ```
  * `<RESOURCE_TYPE>`: Provider dwara diya gaya resource type (e.g., `aws_instance`, `azurerm_virtual_network`).
  * `<LOCAL_NAME>`: Terraform code ke andar refer karne ke liye unique identifier.
  * **Reference Address:** Pure code mein is resource ko `<RESOURCE_TYPE>.<LOCAL_NAME>` ke zariye access kiya jata hai.

* **Example:**
  ```hcl
  resource "aws_instance" "web_server" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    tags = {
      Name = "PrimaryWebServer"
    }
  }
  ```

---

### 10.04.02 Resource Dependencies

Terraform automatically resources ka **Dependency Graph** banata hai taake unhe sahi tarteeb (order) mein create aur delete kiya ja sake.

* **1. Implicit Dependency (Recommended):**
  Jab ek resource doosre resource ke kisi attribute ko direct refer karta hai, to Terraform khud samajh jata hai ke pehle kaunsa resource banana hai:
  ```hcl
  # Pehle VPC banega
  resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
  }

  # Subnet VPC banne ke baad hi banegi (Implicit)
  resource "aws_subnet" "web_subnet" {
    vpc_id     = aws_vpc.main_vpc.id
    cidr_block = "10.0.1.0/24"
  }
  ```

* **2. Explicit Dependency (`depends_on`):**
  Jab do resources ke darmiyan direct attribute link na ho, lekin ek ko doosre se pehle run hona laazmi ho (jaise IAM role ya S3 permission attach hona):
  ```hcl
  resource "aws_instance" "app" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    # Explicitly enforce karein ke pehle S3 bucket bane
    depends_on = [
      aws_s3_bucket.app_storage
    ]
  }
  ```

---

### 10.04.03 Lifecycle Rules (`lifecycle` Block)

Terraform ke default behavior ko customize karne ke liye resource ke andar `lifecycle` block use hota hai.

* **Common Lifecycle Arguments:**
  1. `create_before_destroy`: Zero-downtime deployment ke liye purane resource ko destroy karne se pehle naya resource ready karta hai.
  2. `prevent_destroy`: Accidental deletion rokne ke liye (e.g., Production databases). Is par `terraform destroy` fail ho jayega.
  3. `ignore_changes`: Agar kuch attributes outside Terraform (jaise Auto Scaling policies ya external console se) change hon, to Terraform unhe overwrite na kare.

* **Example:**
  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    lifecycle {
      create_before_destroy = true
      prevent_destroy       = false
      ignore_changes = [
        tags["LastModified"]
      ]
    }
  }
  ```

---

### 10.04.04 Provisioners (Last Resort)

Provisioners resource create ya destroy hone ke waqt local machine ya remote server par scripts execute karne ke liye use hotay hain.

> ⚠️ **Best Practice Warning:** HashiCorp provisioners ko **Last Resort** manta hai. Inki jagah `cloud-init`, Packer custom images, ya Ansible/Puppet prefer karein kyunki provisioners Terraform ke declarative state model ko break karte hain.

* **1. `remote-exec`:** SSH ya WinRM ke zariye instance ke andar command chalana:
  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    provisioner "remote-exec" {
      inline = [
        "sudo apt update -y",
        "sudo apt install -y nginx"
      ]
    }
  }
  ```

* **2. `local-exec`:** Terraform execute karne wale computer/runner par local script run karna:
  ```hcl
  resource "aws_instance" "web" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"

    provisioner "local-exec" {
      command = "echo Server IP is ${self.public_ip} >> server_ips.txt"
    }
  }
  ```

---

### 10.04.05 Import Existing Resources

Agar cloud par koi resource pehle se bana hua hai (jaise AWS console se banaya gaya EC2 instance ya S3 bucket), to use Terraform management aur state ke andar lana.

* **Method 1: Modern `import` Block (Terraform v1.5+):**
  Declarative tareeqe se configuration file ke andar import define karna:
  ```hcl
  # 1. Code mein import block define karein
  import {
    to = aws_s3_bucket.legacy_bucket
    id = "my-existing-cloud-bucket-name"
  }

  # 2. Target resource block define karein
  resource "aws_s3_bucket" "legacy_bucket" {
    bucket = "my-existing-cloud-bucket-name"
  }
  ```

* **Method 2: CLI Command (`terraform import`):**
  Direct CLI command chala kar live resource ko state file mein map karna:
  ```bash
  terraform import aws_s3_bucket.legacy_bucket my-existing-cloud-bucket-name
  ```

* **Workflow after Import:**
  1. HCL code mein resource block likhein ya generate karein.
  2. `terraform plan` chalayein aur check karein ke plan `0 to add, 0 to change, 0 to destroy` dikha raha ho.