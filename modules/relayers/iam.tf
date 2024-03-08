resource "aws_iam_role" "ecs_task_role" {
  for_each = toset(var.nodes_name)
  name     = "${var.project_name}-${each.key}-ecsTaskRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags = {
    Project   = "${var.project_name}-${each.key}"
    Terraform = "true"

  }
}

resource "aws_iam_policy" "task_policy" {
  for_each    = toset(var.nodes_name)
  name        = "${var.project_name}-${each.key}-task-policy"
  path        = "/"
  description = "Task App policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameter*",
          "kms:Decrypt",
          "ssm:DescribeParameters",
          "s3:*",
          "firehose:PutRecordBatch",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ecs:ExecuteCommand",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : "*"
      },
    ]
  })

  tags = {
    Project   = "${var.project_name}-${each.key}"
    Terraform = "true"

  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  for_each   = toset(var.nodes_name)
  role       = aws_iam_role.ecs_task_role[each.key].name
  policy_arn = aws_iam_policy.task_policy[each.key].arn
}

###
# ECS Service Role
###

resource "aws_iam_role" "ecs_task_execution_role" {
  for_each = toset(var.nodes_name)
  name     = "${var.project_name}-${each.key}-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags = {
    Project   = "${var.project_name}-${each.key}"
    Terraform = "true"

  }
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  for_each   = toset(var.nodes_name)
  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-ssm-role-policy-attachment" {
  for_each   = toset(var.nodes_name)
  role       = aws_iam_role.ecs_task_execution_role[each.key].name
  policy_arn = aws_iam_policy.task_policy[each.key].arn
}