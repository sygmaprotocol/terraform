data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc_name}-${lower(var.vpc_env)}-vpc"
  }
}

data "aws_subnets" "ec2_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-private-subnet"]
  }
}

data "aws_subnets" "ec2_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}-public-subnet"]
  }
}

data "aws_acm_certificate" "chainsafe_io" {
  domain    = var.certificate_domain
  statuses  = ["ISSUED"]
  key_types = ["EC_secp384r1"]
}

data "aws_ecs_cluster" "sygma-explorer" {
  cluster_name = var.cluster_name
}
