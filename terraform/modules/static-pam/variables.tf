variable "gcp_project_id" {
  type = string
}
 
variable "entitlement_id" {
  type = string
}
 
variable "max_request_duration" {
  type = string
}
 
variable "requester_principals" {
  type = list(string)
}
 
variable "approver_principals" {
  type = list(string)
}
 
variable "elevated_roles" {
  type = list(string)
}
 
variable "require_approval" {
  type    = bool
  default = true
}
 