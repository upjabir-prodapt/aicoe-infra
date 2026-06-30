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

variable "app_sa_email" {
  type        = string
  description = "Application service account email for KMS IAM binding"
  default     = ""
}

variable "enable_kms" {
  type        = bool
  description = "Create KMS keys and encrypt buckets"
  default     = true
}

variable "enable_workbench_kms" {
  type    = bool
  default = true
}

variable "bucket_suffixes" {
  type = list(string)
  default = [
    "vx-app-001",
    "vxai-bs",
    "vxai-translation-app-001",
    "vxai-sales-app-001",
    "vector-search",
    "vxai-cont-mgmt-app-001",
  ]
  description = "Bucket name suffixes appended to resource_prefix"
}
