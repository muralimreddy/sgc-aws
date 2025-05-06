variable "sn_user_name" {
  description = "User name for ServiceNow user"
  type        = string
}

variable "mbr_act_role_name" {
  description = "Member Account Access Role Name"
  type        = string
  default     = "SnowOrganizationAccountAccessRole"
}