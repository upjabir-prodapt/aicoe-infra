variable "gcp_project_id" {
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


variable "bucket_kms_key_ring_name_suffix" {
  type        = string
  default     = "bucket-key-ring"
  description = "Suffix appended to resource_prefix for the bucket KMS key ring"
}

variable "bucket_kms_key_name_suffix" {
  type        = string
  default     = "bucket-key"
  description = "Suffix appended to resource_prefix for the bucket KMS key"
}


variable "bucket_suffixes" {
  type        = list(string)
  default     = []
  description = "Bucket name suffixes appended to resource_prefix"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
