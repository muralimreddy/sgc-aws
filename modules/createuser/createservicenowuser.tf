# Terraform equivalent of the provided AWS CloudFormation template

resource "aws_iam_policy" "snow_member_account_access_policy" {
  name   = "SnowMemberAccountAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = "arn:${data.aws_partition.current.partition}:iam::*:role/${var.mbr_act_role_name}"
      }
    ]
  })
}

data "aws_partition" "current" {}

resource "aws_iam_group" "snow_member_account_access_group" {
  name = "SnowMemberAccountAccessGroup"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "attach_snow_member_policy" {
  group      = aws_iam_group.snow_member_account_access_group.name
  policy_arn = aws_iam_policy.snow_member_account_access_policy.arn
}

resource "aws_iam_user" "servicenow_user" {
  name = var.sn_user_name
  path = "/"
}

resource "aws_iam_user_group_membership" "snow_user_group_membership" {
  user = aws_iam_user.servicenow_user.name
  groups = [
    aws_iam_group.snow_member_account_access_group.name
  ]
}

resource "aws_iam_group_policy" "snow_account_access_policy" {
  name   = "SnowAccountAccessPolicy"
  group  = aws_iam_group.snow_member_account_access_group.name
  policy = jsonencode({
    Statement = [
      {
        Sid    = "ServiceNowUserReadOnlyAccessOrg"
        Effect = "Allow"
        Action = [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListRoots",
          "organizations:ListAccountsForParent",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:DescribeOrganizationalUnit",
          "organizations:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "ServiceNowUserReadOnlyAccessEC2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages",
          "ec2:DescribeRegions",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes"
        ]
        Resource = "*"
      }
    ]
  })
}

output "servicenow_user_arn" {
  description = "ARN of ServiceNow user"
  value       = aws_iam_user.servicenow_user.arn
}

output "servicenow_user_name" {
  description = "ServiceNow user"
  value       = aws_iam_user.servicenow_user.name
}
