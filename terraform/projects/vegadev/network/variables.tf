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

variable "aicoe_subnet_cidr_range" {}
variable "aicoe_proxy_subnet_cidr_range" {}
variable "aicoe_static_vxaiwb_ip" {}
variable "aicoe_static_ilb_ip" {}
variable "aicoe_static_ilb_salesagent_ip" {}
variable "aicoe_static_ilb_frontend_ip" {}

variable "internal_dns_zone" {
  type    = string
  default = "aicoesandox-int.colt.net."
}
