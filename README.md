# Sygma Terraform modules

### Usage

#### Configure the AWS Provider 
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }
  }
  cloud {
    organization = "ChainSafe"
    workspaces {
      name = " " //the name of your workspace
    }
  }
}
```

```
provider "aws" {
  region  = var.region
  profile = "default"
}
```


#### Configure the main.tf
```
module "relayers" {
  source               = "git::https://github.com/sygmaprotocol/terraform.git//modules/relayers?ref=v1.0.1"
  vpc_name             = var.vpc_name
  env_sufix            = var.env_sufix
  project_name         = var.project_name
  vpc_env              = var.vpc_env
  relayers_name        = var.relayers_name
  app_container_port   = var.app_container_port
  efs_port             = var.efs_port
  certificate_domain   = var.certificate_domain
  tg_health_check_path = var.tg_health_check_path
  tg_target_type       = var.tg_target_type
  tg_protocol          = var.tg_protocol
  app_image                          = var.app_image
  is_lb_internal                     = var.is_lb_internal
  lb_delete_protection               = var.lb_delete_protection
  tg_healthy_threshold               = var.tg_healthy_threshold
  tg_interval                        = var.tg_interval
  tg_matcher                         = var.tg_matcher
  tg_timeout                         = var.tg_timeout
  app_memory_usage                   = var.app_memory_usage
  app_cpu_usage                      = var.app_cpu_usage
  app_max_capacity                   = var.app_max_capacity
  log_retention_days                 = var.log_retention_days
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  tg_unhealthy_threshold             = var.tg_unhealthy_threshold
}
```

### Configure Outputs.tf - Script to retrieve the DNS names
`outputs.tf`
```
data "aws_lb" "dns" {
  for_each = toset(var.relayers_name)
  name = "${var.project_name}-${each.value}-lb-${var.env_sufix}"
}

output "dns_address" {
  value = {
    for dns in data.aws_lb.dns : dns.id => {
      name = dns.name
      arn  = dns.arn
    }
  }
}
```

### VPC Configuration
|For creating new VPC
```
module "vpc" {
    source              = "git::https://github.com/sygmaprotocol/terraform.git//modules/vpc?ref=v1.0.1"
    region              = var.region
    env                 = var.env
    project_name        = var.project_name
    public_subnets      = var.public_subnets
    private_subnets     = var.private_subnets
    database_subnets    = var.database_subnets
    elasticache_subnets = var.elasticache_subnets
    cidr                = var.cidr
}
```

### Variables Configuration
This is where to set the values
`varaibles.tf`
```
variable "project_name" {
  type    = string
  default = ""
}

variable "env_sufix" {
  type    = string
  default = ""
}

variable "relayers_name" {
  type    = list(string)
  default = [""]
}

variable "app_container_port" {
  type    = number
  default = 9000
}

variable "efs_port" {
  type    = number
  default = 2049
}

variable "is_lb_internal" {
  type    = bool
  default = false
}

variable "lb_delete_protection" {
  type    = bool
  default = false
}

variable "tg_protocol" {
  type    = string
  default = "HTTP"
}

variable "tg_target_type" {
  type    = string
  default = "ip"
}

variable "tg_health_check_path" {
  type    = string
  default = "/"
}

variable "tg_interval" {
  type    = string
  default = "30"
}

variable "tg_matcher" {
  type    = string
  default = "200"
}

variable "tg_healthy_threshold" {
  type    = string
  default = "5"
}


variable "tg_unhealthy_threshold" {
  type    = string
  default = "2"
}

variable "certificate_domain" {
  type    = string
  default = ""
}

## Non-required variables

variable "tg_timeout" {
  type    = string
  default = "3"
}

variable "app_memory_usage" {
  type    = number
  default = 512
}

variable "app_cpu_usage" {
  type    = number
  default = 256
}

variable "app_max_capacity" {
  type    = number
  default = 1
}

variable "log_retention_days" {
  type    = number
  default = 3
}

variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 0
}

variable "app_image" {
  type    = string
  default = ""
}

############## VPC ##############
variable "vpc_name" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = ""
}

variable "vpc_env" {
  type    = string
  default = ""
}

variable "cidr" {
  type    = string
  default = "*/16"
}

variable "public_subnets" {
  type    = list(string)
  default = [""]
}

variable "private_subnets" {
  type    = list(string)
  default = [""]
}

variable "database_subnets" {
  type    = list(string)
  default = [""]
}

variable "elasticache_subnets" {
  type    = list(string)
  default = [""]
}
```

| Check the Release Tag for the appropraite version to be used
