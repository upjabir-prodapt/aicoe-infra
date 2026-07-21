variable "gcp_project_id" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "project_number" {
  type = string
}

variable "gcp_apis_required" {
  type = list(string)
}

variable "audit_services" {
  type    = list(string)
  default = ["storage.googleapis.com", "aiplatform.googleapis.com", "bigquery.googleapis.com"]
}