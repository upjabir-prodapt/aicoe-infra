variable "project" {}
variable "envname" {}
variable "region" {}
variable "gcp_apis_required" {}
variable "artifact_format" {}

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

# Required by the shared static-base module's tag-binding resources, but
# unused here since enable_env_tag = false in main.tf. Kept optional so
# params.tfvars doesn't need to define it.
variable "project_number" {
  type    = string
  default = ""
}
