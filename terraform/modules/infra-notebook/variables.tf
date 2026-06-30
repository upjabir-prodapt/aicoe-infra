variable "gcp_project_id" {
  type = string
}

variable "project" {
  type = string
}

variable "envname" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "boot_disk_size_gb" {
  type = number
}

variable "boot_disk_type" {
  type = string
}

variable "data_disk_size_gb" {
  type = number
}

variable "data_disk_type" {
  type = string
}

variable "network_self_link" {
  type = string
}

variable "subnet_self_link" {
  type = string
}
