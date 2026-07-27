# -----------------------------------------------------------------------------
# egress-deny-all and egress-allow-google-apis-psc now come from
# module.network_base (see main.tf) - see moved.tf for the state migration.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Firewall Rules - IAP SSH (kept commented, matches the old code - never
# actually created; module.network_base's enable_iap_ssh_ingress is false
# to match)
# -----------------------------------------------------------------------------

# resource "google_compute_firewall" "aicoe_ingress_allow_iap" {
#   name                    = "ingress-allow-iap-ssh"
#   network                 = module.network_base.network_id
#   description             = "FW rules required to ssh into instances via IAP - useful for diagnosing faulty notebooks/instances"
#   direction               = "INGRESS"
#   source_tags             = null
#   source_service_accounts = null
#   target_tags             = null
#   target_service_accounts = null
#   priority                = 65534
#
#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#
#   source_ranges = ["35.235.240.0/20"]
# }

#Allow HTTPS port 443 AND 8000 for ILB - kept as a plain resource, see the
# enable_https_ilb_ingress comment in main.tf for why this isn't in the module.
###resource "google_compute_firewall" "aicoe_ingress_allow_https" {
###  name        = "ingress-allow-https-ilb"
###  network     = module.network_base.network_id
###  description = "Allow HTTPS traffic for Internal Load Balancer - Ingress"
###  direction   = "INGRESS"
###  priority    = 65534
###  source_ranges = var.ingress_https_source_ranges
###  source_tags             = null
###  source_service_accounts = null
###  target_tags             = null
###  target_service_accounts = null
###  allow {
###    protocol = "tcp"
###    ports    = ["443", "8000"]
###  }
###
###
###  log_config {
###    metadata = "INCLUDE_ALL_METADATA"
###  }
###}

# #Allow Colt On-prem IP (kept commented, matches the old code - never actually created)
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
#
#
#       log_config  {
#         metadata = "INCLUDE_ALL_METADATA"
#       }
#     }

# #Allow Zscaler IP (kept commented, matches the old code - never actually created)
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
#
#
#       log_config  {
#         metadata = "INCLUDE_ALL_METADATA"
#       }
#     }
