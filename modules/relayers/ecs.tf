# check for the ecs cluster if it exist
data "aws_ecs_cluster" "cluster_exist" {
  cluster_name = var.cluster_name
}

# Create the ECS cluster if it doesn't exist
resource "aws_ecs_cluster" "main" {
  count = length(data.aws_ecs_cluster.cluster_exist.arn) == 0 ? 1 : 0
  name  = var.cluster_name
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

locals {
  aws_ecs_cluster_main = one(aws_ecs_cluster.main[*].id)
}

resource "aws_ecs_task_definition" "main" {
  for_each                 = toset(var.nodes_name)
  network_mode             = "awsvpc"
  family                   = "${var.project_name}-${each.key}-container-${var.env_sufix}"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu_usage
  memory                   = var.app_memory_usage
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[each.key].arn
  task_role_arn            = aws_iam_role.ecs_task_role[each.key].arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${each.key}-container-${upper(var.env_sufix)}"
      image     = "${var.app_image}:${var.env_sufix}"
      cpu       = var.app_cpu_usage
      memory    = var.app_memory_usage
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.internal_app_container_port
          hostPort      = var.internal_app_container_port
        },
        {
          protocol      = "tcp"
          containerPort = var.external_app_container_port
          hostPort      = var.external_app_container_port
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "main" {
  for_each                           = toset(var.nodes_name)
  name                               = "${var.project_name}-${each.key}-service-${upper(var.env_sufix)}"
  cluster                            = length(data.aws_ecs_cluster.cluster_exist.arn) > 0 ? data.aws_ecs_cluster.cluster_exist.arn : local.aws_ecs_cluster_main
  desired_count                      = 1
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = 200
  task_definition                    = aws_ecs_task_definition.main[each.key].arn
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  propagate_tags                     = "TASK_DEFINITION"
  enable_ecs_managed_tags            = true

  service_registries {
    registry_arn   = aws_service_discovery_service.ecs-service-discovery[each.key].arn
    container_name = "${var.project_name}-${each.key}-container-${upper(var.env_sufix)}"
  }
  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnets.ec2_private_subnets.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tcp[each.key].arn
    container_name   = "${var.project_name}-${each.key}-container-${upper(var.env_sufix)}"
    container_port   = var.internal_app_container_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.http[each.key].arn
    container_name   = "${var.project_name}-${each.key}-container-${upper(var.env_sufix)}"
    container_port   = var.external_app_container_port
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  timeouts {}
}

resource "aws_service_discovery_private_dns_namespace" "ecs-service-namespace" {
  name        = var.project_name
  description = "Namespace for relayers"
  vpc         = data.aws_vpc.vpc.id
  tags = {
    "Env"     = "${var.env_sufix}"
    "Project" = "${var.project_name}"
  }
}
resource "aws_service_discovery_service" "ecs-service-discovery" {
  for_each = toset(var.nodes_name)
  name     = "${var.project_name}-${each.key}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs-service-namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "WEIGHTED"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
  tags = {
    "Env"     = "${var.env_sufix}"
    "Project" = "${var.project_name}"
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  for_each           = toset(var.nodes_name)
  max_capacity       = var.app_max_capacity
  min_capacity       = 1
  resource_id        = "service/${length(data.aws_ecs_cluster.cluster_exist.arn) > 0 ? data.aws_ecs_cluster.cluster_exist.arn : local.aws_ecs_cluster_main}/${aws_ecs_service.main[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  for_each           = toset(var.nodes_name)
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  for_each           = toset(var.nodes_name)
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}