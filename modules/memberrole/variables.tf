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