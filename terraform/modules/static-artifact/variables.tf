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

variable "artifact_format" {
  type    = string
  default = "docker"
}

variable "vector_search_bucket_name" {
  type        = string
  default     = ""
  description = "Bucket name for vector search IAM binding"
}

variable "vertex_ai_service_agent" {
  type        = string
  default     = ""
  description = "Vertex AI service agent member string (serviceAccount:...)"
}
