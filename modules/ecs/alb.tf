resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.env_sufix}"
  internal           = var.is_lb_internal
  load_balancer_type = var.load_balancer_type
  subnets            = data.aws_subnets.ec2_public_subnets.ids
  security_groups    = [aws_security_group.alb.id]

  enable_deletion_protection = var.lb_delete_protection
}

resource "aws_alb_target_group" "main" {
  name = "${var.project_name}-${var.env_sufix}"
  port        = var.app_container_port
  protocol    = var.tg_protocol
  vpc_id      = data.aws_vpc.vpc.id
  target_type = var.tg_target_type

  health_check {
    healthy_threshold   = var.tg_healthy_threshold
    interval            = var.tg_interval
    protocol            = var.tg_protocol
    matcher             = var.tg_matcher
    timeout             = var.tg_timeout
    path                = var.tg_health_check_path
    unhealthy_threshold = "3"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = data.aws_acm_certificate.chainsafe_io.arn

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}
