# EC2 Instance

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