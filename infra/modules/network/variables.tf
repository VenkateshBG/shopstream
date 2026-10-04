variable "name" {
  type        = string
  description = "Base name used in resource names, e.g. shopstream-dev"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the network in"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources"
}