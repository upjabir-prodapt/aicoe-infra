###variable "gcp_project_id" {
###  type = string
###}
###
###variable "region" {
###  type = string
###}
###
###variable "resource_prefix" {
###  type = string
###}
###
###variable "network_id" {
###  type = string
###}
###
###variable "network_self_link" {
###  type = string
###}
###
###variable "subnet_id" {
###  type = string
###}
###
###variable "reserved_internal_addresses" {
###  type = map(object({
###    name_suffix = string
###    address     = string
###  }))
###  default     = {}
###  description = "Project-specific regional internal IP reservations keyed by project-owned names"
###}
###
###variable "psc_google_apis_address" {
###  type        = string
###  description = "Internal IP address for Google APIs Private Service Connect"
###}
###
###variable "regional_psc_addresses" {
###  type = map(object({
###    name_suffix = string
###    address     = string
###    purpose     = optional(string, "GCE_ENDPOINT")
###  }))
###  default     = {}
###  description = "Project-specific regional PSC endpoint IP reservations keyed by project-owned names"
###}
###
###variable "internal_dns_zone" {
###  type    = string
###  default = ""
###}
###
###variable "internal_dns_records" {
###  type = map(object({
###    name    = string
###    address = string
###  }))
###  default = {}
###}
###
###variable "enable_cloud_nat" {
###  type    = bool
###  default = true
###}
###
###variable "enable_cloud_dns" {
###  type    = bool
###  default = true
###}
###
###variable "enable_psc" {
###  type    = bool
###  default = true
###}
###
###variable "cloud_nat_ip_name_suffixes" {
###  type        = list(string)
###  default     = ["staticip-nat-1", "staticip-nat-2"]
###  description = "Name suffixes for regional static IPs used by Cloud NAT"
###}
###
###variable "labels" {
###  type        = map(string)
###  description = "Canonical labels applied to label-capable resources"
###}
###

variable "gcp_project_id" {
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

variable "reserved_internal_addresses" {
  type = map(object({
    name_suffix = string
    address     = string
  }))
  default     = {}
  description = "Project-specific regional internal IP reservations keyed by project-owned names"
}

variable "psc_google_apis_address" {
  type        = string
  description = "Internal IP address for Google APIs Private Service Connect"
}

variable "psc_google_apis_address_name" {
  type        = string
  default     = ""
  description = "Override for the PSC Google APIs address resource name; falls back to a computed name when empty"
}

variable "psc_google_apis_forwarding_rule_name" {
  type        = string
  default     = ""
  description = "Override for the PSC Google APIs forwarding rule name; falls back to a computed name when empty"
}

variable "regional_psc_addresses" {
  type = map(object({
    name_suffix = string
    address     = string
    purpose     = optional(string, "GCE_ENDPOINT")
  }))
  default     = {}
  description = "Project-specific regional PSC endpoint IP reservations keyed by project-owned names"
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

variable "cloud_nat_ip_name_suffixes" {
  type        = list(string)
  default     = ["staticip-nat-1", "staticip-nat-2"]
  description = "Name suffixes for regional static IPs used by Cloud NAT"
}

variable "labels" {
  type        = map(string)
  description = "Canonical labels applied to label-capable resources"
}
 