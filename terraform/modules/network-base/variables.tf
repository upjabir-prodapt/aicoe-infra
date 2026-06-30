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

variable "aicoe_subnet_cidr_range" {
  type = string
}

variable "aicoe_proxy_subnet_cidr_range" {
  type = string
}

variable "ingress_https_source_ranges" {
  type = list(string)
  default = [
    "192.168.1.0/24",
    "192.168.3.0/24",
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}

variable "internal_ilb_destination_ranges" {
  type    = list(string)
  default = ["192.168.1.0/24"]
}
