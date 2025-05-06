provider "aws" {
  region  = "us-east-1"
  profile = "sgc"
}

# Random ID for bucket name
resource "random_id" "bucket_id" {
  byte_length = 4
}

# Data source for AWS Caller Identity to fetch account ID
data "aws_caller_identity" "current" {}

# S3 Bucket for AWS Config
resource "aws_s3_bucket" "config_bucket" {
  bucket = "aws-config-bucket-${random_id.bucket_id.hex}"

  tags = {
    Name = "AWS Config Bucket"
  }

  # Removed ACL - it's not needed when we use bucket policy
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSConfigBucketPermissionsCheck",
        Effect    = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid       = "AWSConfigBucketDelivery",
        Effect    = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "config_role_attachment" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

# SNS Topic (optional)
resource "aws_sns_topic" "config_topic" {
  count = var.create_sns_topic ? 1 : 0

  name         = "aws-config-topic"
  display_name = "AWS Config Notifications"
}

# SNS Subscription (optional)
resource "aws_sns_topic_subscription" "config_subscription" {
  count = var.create_sns_topic && var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.config_topic[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# AWS Config Recorder
resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported              = var.all_supported
    include_global_resource_types = var.include_global_resource_types
    resource_types             = var.all_supported ? null : var.resource_types
  }
}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = var.delivery_channel_name != "" ? var.delivery_channel_name : null
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  sns_topic_arn  = var.create_sns_topic ? aws_sns_topic.config_topic[0].arn : null

  depends_on = [aws_s3_bucket_policy.config_bucket_policy]  # Ensure policy is applied before channel creation
}

# Start the Configuration Recorder
resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}
