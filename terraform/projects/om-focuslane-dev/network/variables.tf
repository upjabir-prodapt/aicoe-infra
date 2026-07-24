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
variable "aicoe_static_ilb_ip" {}

variable "psc_google_apis_address" {
  type    = string
  default = "192.168.2.3"
}

# TODO: confirm this list against dev's real requirements - it was not
# parameterized in the old dev code (ingress_allow_https had this exact
# fixed source_ranges list hardcoded).
variable "ingress_https_source_ranges" {
  type    = list(string)
  default = ["130.211.0.0/22", "35.191.0.0/16", "10.110.73.30"]
}

# Not used by any active rule today (enable_internal_ilb_egress = false in
# main.tf) but required by the network-base module's interface.
variable "internal_ilb_destination_ranges" {
  type    = list(string)
  default = []
}

# Matches the old hardcoded egress_allow_google_apis_psc destination_ranges.
variable "psc_egress_destination_ranges" {
  type    = list(string)
  default = ["192.168.2.3"]
}
