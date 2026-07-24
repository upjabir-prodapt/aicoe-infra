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

variable "project_number" {}
variable "gcp_apis_required" {}
variable "artifact_format" {}

variable "group_access" {
  type = map(list(string))
}

 