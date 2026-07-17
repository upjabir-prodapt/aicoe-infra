# NOTE: original had project = "aicoe" (stale copy-paste, see static/sandox
# params.tfvars). Fixed to "om-focus-lane". Also dropped
# aicoe_static_vxaiwb_ip - it isn't declared in variables.tf and was unused.
project = "om-focus-lane"
envname = "sandox"
region  = "europe-west1"
aicoe_subnet_cidr_range = "192.168.1.0/24"
aicoe_proxy_subnet_cidr_range = "192.168.3.0/24"
aicoe_static_ilb_ip = "192.168.1.6"

# TODO: confirm these against sandox's real firewall requirements - they
# weren't parameterized before (om-focus-lane's firewall.tf hardcoded the
# dev source ranges for every environment).
ingress_https_source_ranges = [
  "130.211.0.0/22",
  "35.191.0.0/16",
  "192.168.1.6",
]
internal_ilb_destination_ranges = []
psc_egress_destination_ranges = [
  "192.168.2.3",
]
