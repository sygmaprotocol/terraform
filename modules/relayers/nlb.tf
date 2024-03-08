resource "aws_lb" "main" {
  for_each                         = toset(var.relayers_name)
  name                             = "${var.project_name}-${each.key}-lb-${var.env_sufix}"
  internal                         = var.is_lb_internal
  load_balancer_type               = "network"
  subnets                          = data.aws_subnets.ec2_public_subnets.ids
  enable_cross_zone_load_balancing = false
  enable_deletion_protection       = var.lb_delete_protection
  tags = {
    Project = "${var.project_name}"
  }
}

resource "aws_lb_target_group" "http" {
  for_each = toset(var.relayers_name)
  name     = "${var.project_name}-${each.key}-http"
  depends_on = [
    aws_lb.main
  ]
  port        = 9001
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = var.tg_target_type

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Project = "${each.key}-http"
  }
}

resource "aws_lb_target_group" "tcp" {
  for_each = toset(var.relayers_name)
  name     = "${var.project_name}-${each.key}-tcp"
  depends_on = [
    aws_lb.main
  ]
  port        = var.internal_app_container_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.vpc.id
  target_type = var.tg_target_type

  health_check {
    path                = "/health"
    port                = var.external_app_container_port
    protocol            = "HTTP"
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Project = "${var.project_name}-${each.key}-tcp"
  }
}


resource "aws_lb_listener" "http" {
  for_each          = toset(var.relayers_name)
  load_balancer_arn = aws_lb.main[each.key].id
  port              = 9001
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.http[each.key].id
    type             = "forward"
  }
}

resource "aws_lb_listener" "tcp" {
  for_each          = toset(var.relayers_name)
  load_balancer_arn = aws_lb.main[each.key].id
  port              = var.internal_app_container_port
  protocol          = "TCP"
  ssl_policy        = ""
  default_action {
    target_group_arn = aws_lb_target_group.tcp[each.key].id
    type             = "forward"
  }
}

resource "aws_lb_listener" "tls" {
  for_each          = toset(var.relayers_name)
  load_balancer_arn = aws_lb.main[each.key].id
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.chainsafe_io.arn
  default_action {
    target_group_arn = aws_lb_target_group.http[each.key].id
    type             = "forward"
  }
}