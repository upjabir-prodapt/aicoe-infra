variable "gcp_project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "subnet_cidr_range" {
  type = string
}

variable "proxy_subnet_cidr_range" {
  type = string
}

variable "ingress_https_source_ranges" {
  type        = list(string)
  description = "Source CIDR ranges allowed to reach HTTPS internal load balancers"
}

variable "internal_ilb_destination_ranges" {
  type        = list(string)
  description = "Destination CIDR ranges allowed for internal load balancer egress"
}

variable "psc_egress_destination_ranges" {
  type        = list(string)
  description = "Destination CIDR ranges allowed for Private Service Connect egress"
}

variable "enable_egress_deny_all" {
  type    = bool
  default = true
}

variable "enable_iap_ssh_ingress" {
  type    = bool
  default = true
}

variable "enable_fastly_pypi_egress" {
  type    = bool
  default = false
}

variable "enable_azure_devops_rules" {
  type    = bool
  default = false
}

variable "enable_https_ilb_ingress" {
  type    = bool
  default = true
}

variable "enable_internal_ilb_egress" {
  type    = bool
  default = true
}

variable "enable_google_apis_psc_egress" {
  type    = bool
  default = false
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
