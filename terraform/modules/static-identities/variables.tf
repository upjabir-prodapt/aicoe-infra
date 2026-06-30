variable "gcp_project_id" {
  type = string
}

variable "project" {
  type = string
}

variable "envname" {
  type = string
}

variable "resource_prefix" {
  type        = string
  description = "Prefix used for resource names, typically project+envname or project-envname"
}
