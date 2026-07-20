# -----------------------------------------------------------------------------
# Firewall Rules - HTTPS ILB ingress
# -----------------------------------------------------------------------------
# Kept as a plain resource: modules/network-base's ingress_allow_https only
# opens port 443, but om-focus-lane needs 443 AND 8000. Routing this
# through the module (enable_https_ilb_ingress = true) would show a
# permanent "ports" diff on every plan. See module block in main.tf.
resource "google_compute_firewall" "aicoe_ingress_allow_https" {
  name        = "ingress-allow-https-ilb"
  network     = module.network_base.network_id
  description = "Allow HTTPS traffic for Internal Load Balancer - Ingress"
  direction   = "INGRESS"
  priority    = 65534
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "10.110.73.30"
  ]
  source_tags              = null
  source_service_accounts  = null
  target_tags               = null
  target_service_accounts   = null
  allow {
    protocol = "tcp"
    ports    = ["443", "8000"]
  }


  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Blanket egress-deny-all and egress-allow-google-apis-psc rules now come
# from modules/network-base (see main.tf). All other rules below were
# already commented out / unused in the pre-module version and are kept
# that way for reference.

# #Allow Colt On-prem IP
# import {
#   to = google_compute_firewall.aicoe_egress_allow_onprem_ip
#   id = "projects/aicoedev/global/firewalls/allow-onprem-ip"
# }
# resource "google_compute_firewall" "aicoe_egress_allow_onprem_ip" {
#       name        = "allow-onprem-ip"
#       network     = module.network_base.network_id
#       description = "Allow traffic from Colt On-prem IP"
#       direction   = "EGRESS"
#       priority    = 65534
#       source_ranges = [
#        "10.100.254.206", 
#        "10.100.209.0/29", 
#        "10.100.4.66"
#       ]
#       source_tags             = null
#       source_service_accounts = null
#       target_tags             = null
#       target_service_accounts = null
#       allow {
#         protocol = "icmp"
#       }
      
      
#       log_config  {
#         metadata = "INCLUDE_ALL_METADATA"
#       }
#     }

# #Allow Zscaler IP
# import {
#   to = google_compute_firewall.aicoe_ingress_allow_zscaler_ip
#   id = "projects/aicoedev/global/firewalls/allow-zscalerapp"
# }
# resource "google_compute_firewall" "aicoe_ingress_allow_zscaler_ip" {
#       name        = "allow-zscalerapp"
#       network     = module.network_base.network_id
#       description = "Allow traffic for Zscaler IP"
#       direction   = "INGRESS"
#       priority    = 65534
#       source_ranges = [
#        "10.100.209.0/29"
#       ]
#       source_tags             = null
#       source_service_accounts = null
#       target_tags             = null
#       target_service_accounts = null
#       allow {
#         protocol = "tcp"
#         ports    = ["443"]
#       }
      
      
#       log_config  {
#         metadata = "INCLUDE_ALL_METADATA"
#       }
#     }
