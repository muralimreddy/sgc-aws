variable "aws_region" {
  default = "us-east-1"
}

variable "role_arn" {
  description = "Assume Role ARN defined in Member Account. eg.arn:aws:iam::123456789012:role/SnowCrossAccountAccessPolicy"
}
variable "acnnbr" {
  description = "Management or Designated Member Account ID"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name to store SendCommand output"
  type        = string
}

variable "servicenow_user_name" {
  description = "ServiceNow User Name"
  type        = string
}
