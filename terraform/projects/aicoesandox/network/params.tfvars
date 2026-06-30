project_name                    = "aicoesandox"
project                         = "aicoe"
envname                         = "sandox"
region                          = "europe-west1"
subnet_cidr_range               = "192.168.1.0/24"
proxy_subnet_cidr_range         = "192.168.3.0/24"
psc_google_apis_address         = "192.168.2.3"
ingress_https_source_ranges     = ["192.168.1.0/24", "192.168.3.0/24", "130.211.0.0/22", "35.191.0.0/16"]
internal_ilb_destination_ranges = ["192.168.1.0/24"]
psc_egress_destination_ranges   = ["192.168.2.3/32", "192.168.1.5/32"]

reserved_internal_addresses = {
  workbench = {
    name_suffix = "vxaiwb"
    address     = "192.168.1.2"
  }
  translation-ilb = {
    name_suffix = "ilb"
    address     = "192.168.1.6"
  }
  salesagent-ilb = {
    name_suffix = "ilb-salesagent"
    address     = "192.168.1.7"
  }
  frontend-ilb = {
    name_suffix = "ilb-frontend"
    address     = "192.168.1.8"
  }
}

regional_psc_addresses = {
  vector-index = {
    name_suffix = "psc-vector-index-ip"
    address     = "192.168.1.5"
  }
}
