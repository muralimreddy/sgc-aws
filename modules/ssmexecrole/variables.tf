variable "admin_account_id" {
  description = "The ID of the primary account from which automations will be initiated."
  type        = string
  validation {
    condition     = length(var.admin_account_id) == 12
    error_message = "AdminAccountId must be exactly 12 characters."
  }
}