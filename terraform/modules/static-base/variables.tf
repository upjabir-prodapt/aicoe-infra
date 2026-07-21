##variable "gcp_project_id" {
##  type = string
##}
##
##variable "environment_name" {
##  type = string
##}
##
##variable "project_number" {
##  type = string
##}
##
##variable "gcp_apis_required" {
##  type = list(string)
##}
##
##variable "audit_services" {
##  type    = list(string)
##  default = ["storage.googleapis.com", "aiplatform.googleapis.com", "bigquery.googleapis.com"]
##}


variable "gcp_project_id" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "project_number" {
  type    = string
  #default = null
  # Only required when tag_binding_parent is not set (see env_project binding
  # below) -- aicoedev/vegadev derive the tag-binding parent from this,
  # ai-product-security passes tag_binding_parent directly instead.
}

variable "gcp_apis_required" {
  type = list(string)
}

variable "audit_services" {
  type    = list(string)
  default = ["storage.googleapis.com", "aiplatform.googleapis.com", "bigquery.googleapis.com"]
}

variable "audit_log_types" {
  type    = list(string)
  default = ["DATA_READ", "DATA_WRITE"]
}

variable "tag_binding_parent" {
  type    = string
  default = null
}
 