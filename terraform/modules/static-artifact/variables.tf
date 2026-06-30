variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "artifact_format" {
  type    = string
  default = "docker"
}

variable "bucket_iam_members" {
  type = map(object({
    bucket = string
    role   = string
    member = string
  }))
  default     = {}
  description = "Optional project-owned bucket IAM member bindings to create alongside the repository"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
