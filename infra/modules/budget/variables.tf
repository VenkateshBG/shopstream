variable "name" {
  type        = string
  description = "Budget name"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID to apply the budget to"
}

variable "amount" {
  type        = number
  description = "Budget amount in the subscription's billing currency"
}

variable "start_date" {
  type        = string
  description = "First day of a month, RFC3339, e.g. 2026-10-01T00:00:00Z"
}

variable "contact_emails" {
  type        = list(string)
  description = "Emails that receive budget alerts"
}