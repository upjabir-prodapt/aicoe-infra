variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "network_self_link" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

variable "services" {
  type = map(object({
    cloud_run_service_name = string
    ip_address             = string
    certificate_secret     = string
    private_key_secret     = string
  }))
  description = "Map of internal HTTPS load balancer services keyed by service name"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
