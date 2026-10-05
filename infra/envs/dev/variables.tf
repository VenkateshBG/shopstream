variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "eastus"
}

variable "project" {
  type        = string
  description = "Short project name used in resource names and tags"
  default     = "shopstream"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "budget_amount" {
  type        = number
  description = "Monthly budget in billing currency"
  default     = 6000
}

variable "budget_start_date" {
  type        = string
  description = "First day of a month, RFC3339"
  default     = "2026-10-01T00:00:00Z"
}

variable "alert_emails" {
  type        = list(string)
  description = "Emails for budget alerts"
}