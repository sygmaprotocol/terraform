# EC2 Instance

## Usage 

```
module "ec2" {
  source                             = "git::https://github.com/sygmaprotocol/terraform.git//modules/ec2?ref=v1.0.16"
  vpc                                = var.vpc
  env                                = var.env
  project_name                       = var.project_name
  image_id                           = var.image_id
  key_name                           = var.key_name
  instance_profile                   = var.instance_profile
  instance_type                      = var.instance_type
  health_check_type                  = var.health_check_type
  tg_target_type                     = var.tg_target_type
  health_check_grace_period          = var.health_check_grace_period
  app_max_capacity                   = var.app_max_capacity
  app_min_capacity                   = var.app_min_capacity
  app_desired_capacity               = var.app_desired_capacity
}

```

### The Following variables needs your input

```
variable "project_name" {
  type    = string
  default = " " // set the name of your project 
}


variable "image_id" {
  type    = string
  default = " " // add this according to instance image on AWS
}

variable "instance_profile" {
  type = string
  default = " "  // set the name for instance profile
}

variable "key_name" {
  type    = string
  default = " "  // add your security key name here
}

variable "instance_type" {
  type    = string
  default = " " //change instance type
}


variable "region" {
  type    = string
  default = " "  // set the region
}

```

### Set the workspace for the backend on main.tf file
```
  cloud {
    organization = "ChainSafe"
    workspaces {
      name = " " // set the workspace
    }
  }

```
