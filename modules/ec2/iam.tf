resource "aws_iam_policy" "ec2_instance_policy" {
  name        = "${var.project_name}-ec2-policy"
  path        = "/"
  description = "ec2 App policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ec2:*",
            "ssm:*",
            "ec2messages:*",
            "ssmmessages:*",
            "autoscaling:*",
            "cloudwatch:*",
            "elasticloadbalancing:*",
            "ds:CreateComputer",
            "ds:DescribeDirectories",
            "logs:*",
            "s3:*"
          ]
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "iam:CreateServiceLinkedRole",
          "Resource" : "*",
          "Condition" : {
            "StringEquals" : {
              "iam:AWSServiceName" : [
                "autoscaling.amazonaws.com",
                "ec2scheduled.amazonaws.com",
                "elasticloadbalancing.amazonaws.com",
                "spot.amazonaws.com",
                "spotfleet.amazonaws.com",
                "transitgateway.amazonaws.com"
              ]
            }
          }
        }
      ]
  })

}

resource "aws_iam_role" "ec2_instance_role" {
  name               = "${var.project_name}-ec2Role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ec2.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_instance" {
  policy_arn = aws_iam_policy.ec2_instance_policy.arn
  role       = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_instance_profile" "ec2_instance" {
  name = var.instance_profile
  role = aws_iam_role.ec2_instance_role.name
}
