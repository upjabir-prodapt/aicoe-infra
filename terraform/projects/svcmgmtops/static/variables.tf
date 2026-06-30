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

variable "gcp_apis_required" {
  type = list(string)
}

variable "project_number" {
  type = string
}
