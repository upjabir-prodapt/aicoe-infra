variable "project_name" {
  type = string
}

variable "project" {}
variable "envname" {}
variable "region" {}
variable "gcp_project_id" {
  type    = string
  default = ""
}

variable "resource_prefix" {
  type    = string
  default = ""
}

variable "state_bucket" {
  type    = string
  default = ""
}

variable "subnet_cidr_range" {
  type = string
}

variable "proxy_subnet_cidr_range" {
  type = string
}

variable "ingress_https_source_ranges" {
  type = list(string)
}

variable "internal_ilb_destination_ranges" {
  type = list(string)
}

variable "psc_egress_destination_ranges" {
  type = list(string)
}

variable "psc_google_apis_address" {
  type = string
}

variable "reserved_internal_addresses" {
  type = map(object({
    name_suffix = string
    address     = string
  }))
}

variable "regional_psc_addresses" {
  type = map(object({
    name_suffix = string
    address     = string
  }))
}

variable "internal_dns_zone" {
  type    = string
  default = "aicoesandox-int.colt.net."
}
