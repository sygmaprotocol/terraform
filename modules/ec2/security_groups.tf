
## EC2 Task Security Group
resource "aws_security_group" "ec2_instance" {
  name        = "${var.project_name}-sg-node-${upper(var.env)}"
  description = "Allow http traffic into the ${var.project_name} instance"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Datadog"
    protocol    = "tcp"
    from_port   = 10516
    to_port     = 10516
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name    = "${var.project_name}-sg-node-${var.env}"
    Project = "${var.project_name}"
  }
}
