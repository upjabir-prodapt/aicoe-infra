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

variable "network_id" {
  type = string
}

variable "network_self_link" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "aicoe_static_vxaiwb_ip" {
  type    = string
  default = ""
}

variable "aicoe_static_ilb_ip" {
  type    = string
  default = ""
}

variable "aicoe_static_ilb_salesagent_ip" {
  type    = string
  default = ""
}

variable "aicoe_static_ilb_frontend_ip" {
  type    = string
  default = ""
}

variable "psc_google_apis_address" {
  type    = string
  default = "192.168.2.3"
}

variable "psc_vector_index_address" {
  type    = string
  default = "192.168.1.5"
}

variable "internal_dns_zone" {
  type    = string
  default = ""
}

variable "internal_dns_records" {
  type = map(object({
    name    = string
    address = string
  }))
  default = {}
}

variable "enable_cloud_nat" {
  type    = bool
  default = true
}

variable "enable_cloud_dns" {
  type    = bool
  default = true
}

variable "enable_psc" {
  type    = bool
  default = true
}
