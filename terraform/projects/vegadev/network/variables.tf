variable "project" {}
variable "region" {}
variable "envname" {}

variable "psc_google_apis_address" {
  type        = string
  description = "Internal IP address for the Google APIs Private Service Connect endpoint"
}

variable "psc_egress_destination_ranges" {
  type        = list(string)
  description = "Destination CIDR ranges allowed for Private Service Connect egress"
}

