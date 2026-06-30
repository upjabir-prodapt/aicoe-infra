variable "gcp_project_id" {
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

variable "dataset_id_suffix" {
  type    = string
  default = "dataset"
}
