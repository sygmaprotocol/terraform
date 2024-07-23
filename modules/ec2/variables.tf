## Required variables

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc" {
  type    = string
  default = "chainbridge"

}

variable "project_name" {
  type    = string
  default = " " // set the name of your project 
}

variable "env" {
  type    = string
  default = "STAGE"
}

variable "image_id" {
  type    = string
  default = " " // add this according to instance image on AWS
}

variable "instance_profile" {
  type = string
  default = " "  // set the name for instance profile
}

variable "health_check_grace_period" {
  type    = number
  default = 300
}

variable "health_check_type" {
  type    = string
  default = "EC2" #"ELB"
}

variable "app_max_capacity" {
  type    = number
  default = 1
}

variable "app_min_capacity" {
  type    = number
  default = 1
}

variable "key_name" {
  type    = string
  default = " "  // add your security key name here
}

variable "app_desired_capacity" {
  type    = number
  default = 1
}

## Non-required variables

variable "tg_protocol" {
  type    = string
  default = "HTTP"
}

variable "instance_type" {
  type    = string
  default = " " //change instance type
}

variable "tg_target_type" {
  type    = string
  default = "instance"
}

variable "tg_healthy_threshold" {
  type    = string
  default = "5"
}

variable "tg_interval" {
  type    = string
  default = "30"
}

variable "tg_matcher" {
  type    = string
  default = "200"
}

variable "tg_timeout" {
  type    = string
  default = "3"
}

variable "tg_health_check_path" {
  type    = string
  default = "/health"
}

variable "app_memory_usage" {
  type    = number
  default = 512
}

variable "app_cpu_usage" {
  type    = number
  default = 256
}

variable "log_retention_days" {
  type    = number
  default = 2
}


variable "deployment_minimum_healthy_percent" {
  type    = number
  default = 0
}


variable "tg_unhealthy_threshold" {
  type    = string
  default = "2"
}