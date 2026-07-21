project_name             = "ai-cmo-dev"
project                  = "ai-cmo-dev"
envname                  = "dev"
region                   = "europe-west1"
subnet_cidr_range        = "10.110.73.0/24"
proxy_subnet_cidr_range  = "192.168.5.0/24"
psc_google_apis_address  = "192.168.2.3"
internal_dns_zone        = "aicoedev-int.colt.net."
 
# TODO: confirm these two lists against dev's real requirements - they were
# not parameterized in the old dev code (ingress_allow_https had a fixed
# 5-entry source_ranges list; there was no egress_allow_google_apis_psc
# destination var, it was hardcoded to 192.168.2.3/10.110.73.5).
ingress_https_source_ranges     = ["192.168.1.0/24", "192.168.3.0/24", "130.211.0.0/22", "35.191.0.0/16", "10.110.73.0/24"]
internal_ilb_destination_ranges = ["10.110.73.0/24"]
# kept exactly as currently applied in dev state (first entry has no /32)
psc_egress_destination_ranges   = ["192.168.2.3", "10.110.73.5/32"]
 
reserved_internal_addresses = {
  salesagent-ilb = {
    name_suffix = "ilb-salesagent"
    address     = "10.110.73.18"
  }
  frontend-ilb = {
    name_suffix = "ilb-aihub"
    address     = "10.110.73.20"
  }
}
 
regional_psc_addresses = {
  vector-index = {
    name_suffix = "psc-vector-index-ip"
    address     = "10.110.73.5"
  }
}
 
 