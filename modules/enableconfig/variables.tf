variable "create_sns_topic" {
  description = "Whether to create an SNS topic for Config notifications"
  type        = bool
  default     = false
}

variable "notification_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = ""
}

variable "all_supported" {
  description = "Record all supported resource types"
  type        = bool
  default     = true
}

variable "include_global_resource_types" {
  description = "Include global resource types"
  type        = bool
  default     = true
}

variable "resource_types" {
  description = "Specific resource types to record"
  type        = list(string)
  default     = []
}

variable "delivery_channel_name" {
  description = "Optional delivery channel name"
  type        = string
  default     = ""
}

variable "frequency" {
  description = "Snapshot delivery frequency (e.g., One_Hour, Three_Hours)"
  type        = string
  default     = "One_Hour"
}
