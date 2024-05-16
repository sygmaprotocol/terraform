## Required variables
variable "vpc_name" {}
variable "project_name" {}
variable "env_sufix" {}
variable "vpc_env" {}
variable "internal_app_container_port" {}
variable "external_app_container_port" {}
variable "efs_port" {}
variable "app_image" {}
variable "nodes_name" {}
variable "certificate_domain" {}
variable "tg_health_check_path" {}
variable "tg_target_type" {}
variable "cluster_name" {}
variable "load_balancer_type" {}

variable "is_lb_internal" {}
variable "lb_delete_protection" {}
variable "tg_protocol" {}
variable "tg_healthy_threshold" {}
variable "tg_interval" {}
variable "tg_matcher" {}
variable "tg_timeout" {}
variable "app_memory_usage" {}
variable "app_cpu_usage" {}
variable "app_max_capacity" {}
variable "log_retention_days" {}
variable "deployment_minimum_healthy_percent" {}
variable "tg_unhealthy_threshold" {}