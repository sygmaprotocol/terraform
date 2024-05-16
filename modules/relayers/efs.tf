resource "aws_efs_file_system" "efs" {
  tags = {
    Name    = "${var.project_name}-efs-${var.env_sufix}"
    Project = "${var.project_name}"
  }
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }
}

resource "aws_efs_mount_target" "main" {
  for_each = toset(data.aws_subnets.ec2_private_subnets.ids)

  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = "${each.key}"

  security_groups = [
    aws_security_group.efs.id,
  ]

}

resource "aws_security_group" "efs" {
  name        = "${var.project_name}-efs-${var.env_sufix}"
  description = "efs volume in ${var.env_sufix}"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description = "Allow EFS to connect to the ${var.env_sufix} VPC"
    from_port   = var.efs_port
    to_port     = var.efs_port
    protocol    = "tcp"

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block
    ]
  }

  egress {
    from_port = var.efs_port
    to_port   = var.efs_port
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.vpc.cidr_block,
    ]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name    = "${var.project_name}-efs-${var.env_sufix}"
    Project = "${var.project_name}"
  }
  timeouts {}
}