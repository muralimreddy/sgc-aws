provider "aws" {
  region = "us-east-1"
  profile  = "sgc"
}

resource "aws_iam_role" "snow_organization_account_access_role" {
  name = "SnowOrganizationAccountAccessRole"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          AWS : "arn:${data.aws_partition.current.partition}:iam::${var.acnnbr}:user/${var.servicenow_user_name}"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })

  path = "/"
}

resource "aws_iam_role_policy" "snow_account_access_policy" {
  name = "SnowOrganizationAccountAccessPolicy"
  role = aws_iam_role.snow_organization_account_access_role.id

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid    : "ServiceNowUserReadOnlyAccessOrg",
        Effect : "Allow",
        Action : [
          "organizations:DescribeOrganization",
          "organizations:ListAccounts",
          "organizations:ListRoots",
          "organizations:ListAccountsForParent",
          "organizations:ListOrganizationalUnitsForParent",
          "organizations:DescribeOrganizationalUnit",
          "organizations:ListTagsForResource"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessConfig",
        Effect : "Allow",
        Action : [
          "config:ListDiscoveredResources",
          "config:SelectResourceConfig",
          "config:BatchGetResourceConfig"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessConfigAgg",
        Effect : "Allow",
        Action : [
          "config:DescribeConfigurationAggregators",
          "config:SelectAggregateResourceConfig",
          "config:BatchGetAggregateResourceConfig"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessEC2",
        Effect : "Allow",
        Action : [
          "ec2:DescribeRegions",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessSSM",
        Effect : "Allow",
        Action : [
          "ssm:DescribeInstanceInformation",
          "ssm:ListInventoryEntries",
          "ssm:GetInventory"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessTag",
        Effect : "Allow",
        Action : [
          "tag:GetResources"
        ],
        Resource : "*"
      },
      {
        Sid    : "ServiceNowUserReadOnlyAccessIAM",
        Effect : "Allow",
        Action : [
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey"
        ],
        Resource : "arn:${data.aws_partition.current.partition}:iam::${var.acnnbr}:user/${var.servicenow_user_name}"
      },
      {
        Sid    : "ServiceNowSendCommandAccess",
        Effect : "Allow",
        Action : [
          "ssm:SendCommand"
        ],
        Resource : [
          "arn:${data.aws_partition.current.partition}:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
          "arn:${data.aws_partition.current.partition}:ssm:*:${data.aws_caller_identity.current.account_id}:document/SG-AWS*"
        ]
      },
      {
        Sid    : "ServiceNowS3BucketAccess",
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource : [
          "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket}/*",
          "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket}"
        ]
      }
    ]
  })
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

output "servicenow_user_role_arn" {
  description = "ARN of ServiceNow Designated Account Access Role"
  value       = aws_iam_role.snow_organization_account_access_role.arn
}
