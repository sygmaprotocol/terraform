data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc}-${lower(var.env)}-vpc"
  }
}

data "aws_subnets" "ec2_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.vpc}-private-subnet"]
  }
}

data "aws_subnets" "ec2_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.vpc}-public-subnet"]
  }
}

data "aws_availability_zones" "availabile_zones" {
  state = "available"
}



