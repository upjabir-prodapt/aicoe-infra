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

variable "project_number" {}
variable "gcp_apis_required" {}
variable "artifact_format" {}

variable "pam_enabled" {
  type = bool
  default =false
}
 
variable "pam_entitlement_id" {
  type = string
  default = ""
}
 
variable "pam_max_request_duration" {
  type = string
  default = "3600s"
}
 
variable "pam_requester_principals" {
  type = list(string)
  default = [ ]
}
 
variable "pam_approver_principals" {
  type = list(string)
   default = [ ]
}
 
variable "pam_elevated_roles" {
  type = list(string)
  default = [ ]
}
 
variable "pam_require_approval" {
  type    = bool
  default = true
}

variable "group_access" {
  type = map(list(string))
}
