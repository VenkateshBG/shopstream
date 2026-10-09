variable "name" {
  type        = string
  description = "Base name, e.g. shopstream-dev"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group for the cluster"
}

variable "subnet_id" {
  type        = string
  description = "Subnet the nodes join"
}

variable "node_count" {
  type        = number
  description = "Number of worker nodes (2 vCPU each)"

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 2
    error_message = "Keep node_count at 1 or 2: the subscription has only 4 vCPUs in total."
  }
}

variable "vm_size" {
  type        = string
  description = "VM size of the nodes"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources"
}