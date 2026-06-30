variable "gcp_project_id" {
  type = string
}

variable "project" {
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

variable "minimal_dataset_only" {
  type        = bool
  description = "When true, only create a single empty dataset (svcmgmtops pattern)"
  default     = false
}

variable "minimal_dataset_id_suffix" {
  type    = string
  default = "dataset"
}
