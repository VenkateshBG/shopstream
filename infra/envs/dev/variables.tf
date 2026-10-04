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