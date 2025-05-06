provider "aws" {
  region = "us-east-1"
  profile  = "sgc"
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "automation_execution_role" {
  name = "AWS-SystemsManager-AutomationExecutionRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:${data.aws_partition.current.partition}:iam::${var.admin_account_id}:role/AWS-SystemsManager-AutomationAdministrationRole"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "ssm.amazonaws.com"
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          },
          ArnLike = {
            "aws:SourceArn" = "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:automation-execution/*"
          }
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonSSMAutomationRole"
  ]

  inline_policy {
    name = "ExecutionPolicy"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "resource-groups:ListGroupResources",
            "tag:GetResources",
            "ec2:DescribeInstances"
          ],
          Resource = "*"
        },
        {
          Effect = "Allow",
          Action = [
            "iam:PassRole"
          ],
          Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/AWS-SystemsManager-AutomationExecutionRole"
        }
      ]
    })
  }
}
