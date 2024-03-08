resource "aws_cloudwatch_log_group" "logs" {
  for_each          = toset(var.nodes_name)
  name              = "/ecs/${var.project_name}-${each.key}-${var.env_sufix}"
  retention_in_days = var.log_retention_days
  tags = {
    Project   = "${var.project_name}-${each.key}"
    Terraform = "true"
    Name      = "/ecs/${var.project_name}-${each.key}-${var.env_sufix}"
  }
}