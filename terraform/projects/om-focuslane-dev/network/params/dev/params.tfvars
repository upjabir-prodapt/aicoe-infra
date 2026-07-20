project = "om-focus-lane"
envname = "dev"
region  = "europe-west1"
aicoe_subnet_cidr_range = "10.110.73.0/24"
aicoe_proxy_subnet_cidr_range = "192.168.5.0/24"
aicoe_static_ilb_ip = "10.110.73.30"

# Required by modules/network-base. Only psc_egress_destination_ranges is
# actually enforced today (enable_google_apis_psc_egress = true); the other
# two are unused while their enable_* flags are off, but kept here matching
# the source values from the pre-module firewall.tf for documentation.
ingress_https_source_ranges = [
  "130.211.0.0/22",
  "35.191.0.0/16",
  "10.110.73.30",
]
internal_ilb_destination_ranges = []
psc_egress_destination_ranges = [
  "192.168.2.3",
]
