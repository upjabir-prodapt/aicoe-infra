variable "project_name" {
  type = string
}

variable "project" {}
variable "envname" {}
variable "region" {}
variable "gcp_project_id" {
  type    = string
  default = ""
}

variable "resource_prefix" {
  type    = string
  default = ""
}

variable "state_bucket" {
  type    = string
  default = ""
}

variable "data_disk_size_gb" {
  type    = number
  default = null
}

variable "data_disk_type" {
  default = null
}

variable "machine_type" {
  default = null
}

variable "boot_disk_size_gb" {
  type    = number
  default = null
}

variable "boot_disk_type" {
  default = null
}

variable "cloud_run_service_name" {}
variable "cloud_run_service_name2" {}
variable "cloud_run_service_name3" {}