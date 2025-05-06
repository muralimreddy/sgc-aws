provider "aws" {
  region = "us-east-1"
  profile  = "sgc"
}
resource "aws_iam_role" "snow_organization_account_access_role" {
  name = "SnowOrganizationAccountAccessRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          AWS = var.MEMBERACTNBR
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "SnowOrganizationAccountAccessPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = [
            "ec2:DescribeImages",
            "ec2:DescribeRegions",
            "ec2:DescribeInstances",
            "organizations:DescribeOrganization",
            "organizations:ListAccounts",
            "organizations:ListRoots",
            "organizations:ListAccountsForParent",
            "organizations:ListOrganizationalUnitsForParent",
            "organizations:DescribeOrganizationalUnit",
            "organizations:ListTagsForResource"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

output "ServiceNowUserRoleARN" {
  description = "ARN of ServiceNow OrganizationAccountAccessRole Role"
  value       = aws_iam_role.snow_organization_account_access_role.arn
}
