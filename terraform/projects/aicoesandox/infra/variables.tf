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
  type = number
}

variable "data_disk_type" {}
variable "machine_type" {}
variable "boot_disk_size_gb" {
  type = number
}

variable "boot_disk_type" {}
variable "cloud_run_service_name" {}
variable "cloud_run_service_name2" {}
variable "cloud_run_service_name3" {}
