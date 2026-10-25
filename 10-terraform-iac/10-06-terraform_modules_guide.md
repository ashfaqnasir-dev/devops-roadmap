# 📦 10.06 Terraform Modules

Terraform modules reusable, self-contained packages hotay hain jo multiple related resources ko ek container ke andar encapsulate karte hain. Modules infrastructure code ke functions ya classes ki tarah kaam karte hain: inputs le kar resources create karte hain aur zaroori data as output return karte hain.

---

### 10.06.01 Module Basics

Terraform mein har project kam az kam ek module zaroor hota hai:

* **Root Module:** Jis directory mein aap `terraform init` aur `terraform apply` run karte hain, us directory ke saare `.tf` files mil kar root module banti hain.
* **Child Module:** Koi bhi doosra module jise root module (ya kisi doosre child module) ke andar `module` block ke zariye call kiya jaye.
* **DRY Principle (Don't Repeat Yourself):** Modules ka main maqsad code duplication ko khatam karna hai. Misal ke tor par, same VPC ya Web Server architecture ko Dev, Staging, aur Prod environments mein alag alag copy-paste karne ke bajaye ek reusable module bana liya jata hai.

---

### 10.06.02 Create a Custom Module

Ek standard child module ki folder structure clean aur modular honi chahiye:

```text
modules/
└── aws_web_server/
    ├── main.tf          # Core resources definition
    ├── variables.tf     # Module ke inputs
    ├── outputs.tf       # Module ke outputs
    └── README.md        # Usage documentation
```

#### 1. Input Variables (`modules/aws_web_server/variables.tf`)
```hcl
variable "ami_id" {
  description = "Server ki AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t2.micro"
}

variable "server_name" {
  description = "Tag name for the server"
  type        = string
}
```

#### 2. Resource Definition (`modules/aws_web_server/main.tf`)
```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = var.server_name
  }
}
```

#### 3. Outputs (`modules/aws_web_server/outputs.tf`)
```hcl
output "instance_id" {
  description = "Banaye gaye instance ki ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Instance ka public IP"
  value       = aws_instance.web.public_ip
}
```

---

### 10.06.03 Use a Module (Calling Child Modules)

Root module ke andar child module ko `module` block ke zariye call kiya jata hai.

#### 1. Module Call (`main.tf` in Root):
```hcl
module "production_web_server" {
  source = "./modules/aws_web_server" # Local file path

  # Input arguments pass karein
  ami_id        = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.small"
  server_name   = "Prod-App-Server"
}
```

#### 2. Accessing Child Module Outputs:
Child module ke outputs ko root module mein `module.<MODULE_NAME>.<OUTPUT_NAME>` syntax se access kiya jata hai:

```hcl
output "prod_server_ip" {
  value = module.production_web_server.public_ip
}
```

> **Important:** Naya module add karne ya module source change karne ke baad **`terraform init`** ya **`terraform get`** run karna laazmi hota hai taake Terraform module ko initialize/load kar sake.

---

### 10.06.04 Terraform Module Registry

HashiCorp ki official public registry (`registry.terraform.io`) par hazaron verified aur community-maintained modules available hain (e.g., official AWS VPC, EKS, RDS modules).

#### 1. Public Registry Module Use Karna:
Public module call karte waqt `source` aur `version` specify kiye jaate hain:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "production-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "production"
  }
}
```

#### 2. Git Sources:
Aap modules direct GitHub, GitLab ya Bitbucket private repositories se bhi source kar sakte hain:

```hcl
module "security_group" {
  # Git URL with specific branch, tag ya commit hash
  source = "git::https://github.com/my-org/tf-modules.git//aws_sg?ref=v1.2.0"
}
```

#### Best Practices for Module Registry:
1. **Always Pin Versions:** Remote registry modules use karte waqt hamesha exact version constraint (`version = "x.y.z"`) use karein taake upstream changes se infrastructure break na ho.
2. **Review Public Code:** External modules provision karne se pehle unka source code aur security permissions zaroor inspect karein.