variable "project" {}
variable "region" {}
variable "envname" {}
variable "aicoe_subnet_cidr_range" {}
variable "aicoe_proxy_subnet_cidr_range" {}
variable "aicoe_static_ilb_ip" {}

# Required by modules/network-base. ingress_https_source_ranges and
# internal_ilb_destination_ranges are currently unused (their matching
# enable_* flags are off in main.tf) but the module still requires values.
variable "ingress_https_source_ranges" {
  type = list(string)
}

variable "internal_ilb_destination_ranges" {
  type    = list(string)
  default = []
}

variable "psc_egress_destination_ranges" {
  type = list(string)
}
