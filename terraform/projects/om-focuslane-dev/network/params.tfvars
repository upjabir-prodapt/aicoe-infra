project = "om-focus-lane"
envname = "dev"
region  = "europe-west1"
aicoe_subnet_cidr_range = "10.110.73.0/24"
aicoe_proxy_subnet_cidr_range = "192.168.5.0/24"
aicoe_static_ilb_ip = "10.110.73.30"

# All of the below match the module defaults already baked into
# network/variables.tf - listed here for visibility only, override if dev's
# real requirements diverge from what the old flat code hardcoded.
# psc_google_apis_address         = "192.168.2.3"
# ingress_https_source_ranges     = ["130.211.0.0/22", "35.191.0.0/16", "10.110.73.30"]
# internal_ilb_destination_ranges = []
# psc_egress_destination_ranges   = ["192.168.2.3"]
