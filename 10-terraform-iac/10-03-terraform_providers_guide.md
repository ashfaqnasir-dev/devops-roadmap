# 🔌 10.03 Terraform Providers

Providers Terraform ke plugins hotay hain jo target platforms (jaise AWS, Azure, Google Cloud, Docker, Kubernetes) ki APIs ke sath communicate karte hain. Terraform core ko directly cloud APIs ka pata nahi hota; Provider plugin hi HCL code ko actual API calls mein translate karta hai.

### 10.03.01 AWS Provider (`hashicorp/aws`)

Amazon Web Services ke resources (EC2, S3, RDS, VPC wagaira) provision aur manage karne ke liye use hota hai.

* **Declaration & Credentials:**
  Production mein credentials kabhi hardcode nahi kiye jaate. AWS Provider automatically environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`), `~/.aws/credentials` file, ya IAM Roles (EC2 instance profiles / OIDC) se credentials pick karta hai.

* **Standard Setup:**

  ```
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
  }
  
  provider "aws" {
    region = "us-east-1"
  
    # Default tags jo har resource par automatically lag jaayenge
    default_tags {
      tags = {
        ManagedBy   = "Terraform"
        Environment = "Production"
      }
    }
  }
  
  resource "aws_s3_bucket" "app_data" {
    bucket = "my-secure-unique-app-data-bucket"
  }
  
  ```

### 10.03.02 Azure Provider (`hashicorp/azurerm`)

Microsoft Azure cloud infrastructure (Virtual Machines, Resource Groups, Virtual Networks, AKS) ko manage karne ke liye use hota hai.

* **Authentication:**
  Local machine par Azure CLI (`az login`) se authenticate hota hai, jabke CI/CD ya production mein Azure Service Principal ya Managed Identity use hoti hai.

* **Features Block (Mandatory):**
  AzureRM provider ko ek empty ya configured `features {}` block ki zaroorat hoti hai.

* **Standard Setup:**

  ```
  terraform {
    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 3.0"
      }
    }
  }
  
  provider "azurerm" {
    features {} # Required for azurerm
  }
  
  resource "azurerm_resource_group" "rg" {
    name     = "rg-prod-eastus"
    location = "East US"
  }
  
  ```

### 10.03.03 Provider Configuration & Multiple Instances (`alias`)

Aap provider ke settings customize kar sakte hain aur ek hi configuration ke andar multiple accounts ya regions target karne ke liye `alias` use kar sakte hain.

* **Multiple Regions / Accounts with `alias`:**
  Aksar disaster recovery ya multi-region deployments mein ek hi code se multiple regions target karne padte hain.

* **Example:**

  ```
  # 1. Default AWS provider (us-east-1)
  provider "aws" {
    region = "us-east-1"
  }
  
  # 2. Secondary AWS provider (eu-west-1) with alias
  provider "aws" {
    alias  = "europe"
    region = "eu-west-1"
  }
  
  # Default region mein banega (us-east-1)
  resource "aws_s3_bucket" "primary_bucket" {
    bucket = "primary-corp-data-east"
  }
  
  # European region mein banega (explicit provider argument ke zariye)
  resource "aws_s3_bucket" "replica_bucket" {
    provider = aws.europe
    bucket   = "backup-corp-data-europe"
  }
  
  ```

### 10.03.04 Version Constraints

Cloud providers continuous updates aur breaking changes release karte rehte hain. Team ke darmian consistency maintain karne aur unexpected breaking changes se bachne ke liye version pin karna zaroori hai.

* **`required_providers` Block:**

  ```
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 5.10.0"
      }
    }
  }
  
  ```

* **Version Operators Table:**

  | Operator | Example | Matlab | 
  | ----- | ----- | ----- | 
  | `=` (ya no operator) | `version = "5.10.0"` | **Exact version:** Sirf `5.10.0` use hogi. | 
  | `!=` | `version = "!= 5.0.0"` | Us specific version ko exclude karna. | 
  | `>`, `>=`, `<`, `<=` | `version = ">= 5.0, < 6.0"` | Version ranges define karna. | 
  | `~>` (**Pessimistic Constraint**) | `version = "~> 5.10"` | Right-most digit increase ho sakti hai (`5.10` se lekar `< 6.0` tak). | 
  | `~>` (Patch pin) | `version = "~> 5.10.1"` | Sirf patch releases allow karega (`5.10.1` se lekar `< 5.11.0` tak). | 

* **`.terraform.lock.hcl` File:**
  Jab aap `terraform init` chalate hain, Terraform exact provider version aur hashes ko lock file mein likh deta hai. Is file ko hamesha **Git mein commit** karna chahiye taake har team member ke paas bilkul identical plugin download ho.