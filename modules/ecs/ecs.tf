# resource "aws_ecs_cluster" "main" {
#   name = data.aws_ecs_cluster.cluster_name
#   tags = {
#     Name = var.project_name
#   }
# }

resource "aws_ecs_task_definition" "main" {
  network_mode             = "awsvpc"
  family                   = "service"
  requires_compatibilities = ["FARGATE", "EC2"]
  cpu                      = var.app_cpu_usage
  memory                   = var.app_memory_usage
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container-${var.env_sufix}"
      image     = "${var.env_sufix}"
      cpu       = var.app_cpu_usage
      memory    = var.app_memory_usage
      essential = true
      portMappings = [
        {
          containerPort = var.app_container_port
          hostPort      = var.app_container_port
        }
      ]
    }
  ])

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_ecs_service" "main" {
  name                               = "${var.project_name}-service-${var.env_sufix}"
  cluster                            = data.aws_ecs_cluster.cluster_name.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_healthy_percent
  task_definition                    = aws_ecs_task_definition.main.arn
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnets.ec2_private_subnets.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = "${var.project_name}-container-${var.env_sufix}"
    container_port   = var.app_container_port
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.app_max_capacity
  min_capacity       = var.app_min_capacity
  resource_id        = "service/${data.aws_ecs_cluster.cluster_name.arn}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 60
  }
}
