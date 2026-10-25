# 📝 10.02 Terraform HCL Syntax

HashiCorp Configuration Language (HCL) ek human-readable aur machine-friendly declarative language hai. Yeh JSON ke muqablay mein likhne aur samajhne mein zyada aasan hoti hai aur Terraform configuration isi syntax par likhi jaati hai.

---

### 10.02.01 Blocks

HCL ka basic building block **Block** hota hai. Yeh containers ki tarah kaam karta hai jisme arguments aur values define hoti hain.

* **Structure:**
  ```hcl
  <BLOCK_TYPE> "<BLOCK_LABEL_1>" "<BLOCK_LABEL_2>" {
    # Block body (Arguments & Values)
    argument_key = "argument_value"
  }
  ```

* **Common Block Types:**
  * `terraform {}`: Global settings aur required provider versions set karne ke liye.
  * `provider {}`: Cloud provider (jaise AWS, Azure, GCP) ko configure karne ke liye.
  * `resource {}`: Actual cloud resource define karne ke liye (jaise EC2 instance, VPC, S3 bucket).

* **Example:**
  ```hcl
  resource "aws_s3_bucket" "my_bucket" {
    bucket = "my-unique-company-logs-bucket"

    tags = {
      Environment = "Dev"
    }
  }
  ```

---

### 10.02.02 Variables (Input Variables)

Configuration ko dynamic, reusable aur customizable banane ke liye variables use hotay hain (parameters ki tarah).

* **Description:** Hardcoding values se bachne ke liye hum variables define karte hain. Har variable ka `type`, `default` value, aur `description` set kiya ja sakta hai.

* **Definition (`variables.tf`):**
  ```hcl
  variable "instance_type" {
    description = "EC2 instance ka size"
    type        = string
    default     = "t2.micro"
  }

  variable "enable_public_ip" {
    type    = bool
    default = true
  }

  variable "allowed_ports" {
    type    = list(number)
    default = [80, 443, 22]
  }
  ```

* **Usage (`main.tf`):**
  ```hcl
  resource "aws_instance" "app_server" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = var.instance_type
  }
  ```

* **Variable Values Pass Karne Ke Tareeqay:**
  1. CLI se: `terraform apply -var="instance_type=t3.small"`
  2. File se: `terraform.tfvars` file create karke (`instance_type = "t3.small"`).

---

### 10.02.03 Outputs (Output Values)

Provisioning complete hone ke baad important values ko display ya doosre modules mein pass karne ke liye use hotay hain (return values ki tarah).

* **Description:** Jab resources create ho jaate hain, to unka auto-generated data (jaise Public IP, Database endpoint, S3 Bucket ARN) console par show karne ke liye `output` block banaya jata hai.

* **Example (`outputs.tf`):**
  ```hcl
  output "server_public_ip" {
    description = "EC2 instance ka public IP address"
    value       = aws_instance.app_server.public_ip
  }

  output "db_password" {
    value     = aws_db_instance.db.password
    sensitive = true # CLI output mein value hide rakhta hai
  }
  ```

* **Command:** Outputs ko kisi bhi waqt print karne ke liye:
  ```bash
  terraform output
  ```

---

### 10.02.04 Data Sources

Cloud provider par pehle se maujood resources ki details read karne ke liye use hotay hain.

* **Description:** Yeh naye resources create **nahi** karte, balki outside infrastructure (jaise default VPC ID, latest AMI ID, ya pehle se bani subnet) ka data fetch karke aapke Terraform code ko provide karte hain.

* **Block Identifier:** `data "<TYPE>" "<NAME>"`

* **Example:**
  ```hcl
  # AWS se latest Ubuntu 22.04 AMI ki ID fetch karein
  data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    owners = ["099720109477"] # Canonical
  }

  # Is fetched AMI ID ko naye instance mein use karein
  resource "aws_instance" "web" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
  }
  ```

---

### 10.02.05 Expressions

Dynamic values calculate aur manipulate karne ke liye HCL expressions provide karta hai.

* **1. String Interpolation:**
  Strings ke darmiyan variables ko combine karna:
  ```hcl
  name = "server-${var.environment}"
  ```

* **2. Ternary (Conditional) Operator:**
  Conditions check karne ke liye (`condition ? true_val : false_val`):
  ```hcl
  instance_type = var.environment == "production" ? "t3.large" : "t2.micro"
  ```

* **3. For Expressions & Loops:**
  Lists ya maps ko transform karne ke liye:
  ```hcl
  # Saare names ko uppercase mein convert karna
  upper_names = [for name in var.user_names : upper(name)]
  ```

* **4. Built-in Functions:**
  HCL mein bohot se useful built-in functions maujood hain:
  ```hcl
  # Lookup with fallback
  instance_type = lookup(var.instance_sizes, var.env, "t2.micro")

  # Join strings
  full_domain = join(".", ["api", var.domain_name])

  # Merge tags
  tags = merge(var.common_tags, { Name = "Backend-Server" })
  ```