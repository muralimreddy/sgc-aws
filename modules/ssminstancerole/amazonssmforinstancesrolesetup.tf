data "aws_partition" "current" {}

# IAM Role for EC2 to use with SSM
resource "aws_iam_role" "ssm_instance_role" {
  name = "AmazonSSMForInstancesRole"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policy {
    name = "SSMSendCommand"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:PutObjectAcl"
          ],
          Resource = [
            "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/*"
          ]
        }
      ]
    })
  }
}

# Instance Profile
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "AmazonSSMForInstancesProfile"
  path = "/"
  role = aws_iam_role.ssm_instance_role.name
}
