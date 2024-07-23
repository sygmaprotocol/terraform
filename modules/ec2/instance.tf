# Luanch Template
# Luanch Template
resource "aws_launch_template" "ec2_instance" {
  name_prefix             = var.project_name
  image_id                = var.image_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  disable_api_termination = true

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.ec2_instance.id}"]
    subnet_id                   = element(data.aws_subnets.ec2_public_subnets.ids, 1)
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance.name
  }
}


resource "aws_autoscaling_group" "ec2_instance" {
  name                = "${var.project_name}-${var.env}"
  vpc_zone_identifier = [data.aws_subnets.ec2_public_subnets.ids[0], data.aws_subnets.ec2_public_subnets.ids[1], data.aws_subnets.ec2_public_subnets.ids[2]]
  desired_capacity          = var.app_desired_capacity
  max_size                  = var.app_max_capacity
  min_size                  = var.app_min_capacity
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  #target_group_arns         = [aws_alb_target_group.main.arn]
  #auto_rollback             = true

  launch_template {
    id      = aws_launch_template.ec2_instance.id
    version = aws_launch_template.ec2_instance.latest_version # "$Latest"
  }

  tag {
    key = "Name"
    value = "${var.project_name}"
    propagate_at_launch = true
  }
}