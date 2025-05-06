variable "MEMBERACTNBR" {
  description = "Enter Member Account Id where ServiceNow user is created"
  type        = string
  validation {
    condition     = length(var.MEMBERACTNBR) == 12
    error_message = "The Member Account Id must be 12 characters long."
  }
}