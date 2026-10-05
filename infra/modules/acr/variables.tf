variable "project" {
  type        = string
  description = "Project name, used to build the registry name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create the registry in"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources"
}