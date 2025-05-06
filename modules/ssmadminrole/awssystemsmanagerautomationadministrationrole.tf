provider "aws" {
  region = "us-east-1"
  profile  = "sgc"
}
data "aws_partition" "current" {}

resource "aws_iam_role" "ssm_automation_admin_role" {
  name = "AWS-SystemsManager-AutomationAdministrationRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ssm.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "AssumeRole-AWSSystemsManagerAutomationExecutionRole"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "sts:AssumeRole"
          ],
          Resource = "arn:${data.aws_partition.current.partition}:iam::*:role/AWS-SystemsManager-AutomationExecutionRole"
        },
        {
          Effect = "Allow",
          Action = [
            "organizations:ListAccountsForParent"
          ],
          Resource = "*"
        }
      ]
    })
  }
}
