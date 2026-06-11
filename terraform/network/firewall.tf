# -----------------------------------------------------------------------------
# Firewall Rules - DENY ALL
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "aicoe_egress_deny_all" {
    name                    = "egress-deny-all"
    network                 = google_compute_network.aicoe_network.id
    description             = "Blanket default deny rule for egress"
    direction               = "EGRESS"
    priority                = 65535
    destination_ranges      = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    deny  {
        protocol = "all"
        ports    = null # All ports
    }
    log_config  {
        metadata = "INCLUDE_ALL_METADATA"
    }
}

# # -----------------------------------------------------------------------------
# # Firewall Rules - IAP SSH
# # -----------------------------------------------------------------------------

# resource "google_compute_firewall" "aicoe_ingress_allow_iap" {
#   name                    = "ingress-allow-iap-ssh"
#   network                 = google_compute_network.aicoe_network.id
#   description             = "FW rules required to ssh into instances via IAP - useful for diagnosing faulty notebooks/instances"
#   direction               = "INGRESS"
#   source_tags             = null
#   source_service_accounts = null
#   target_tags             = null
#   target_service_accounts = null
#   priority                = 65534

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["35.235.240.0/20"]
# }

#Allow HTTPS port 443 for ILB
resource "google_compute_firewall" "aicoe_ingress_allow_https" {
      name        = "ingress-allow-https-ilb"
      network     = google_compute_network.aicoe_network.id
      description = "Allow HTTPS traffic for Internal Load Balancer - Ingress"
      direction   = "INGRESS"
      priority    = 65534
      source_ranges = [
       "130.211.0.0/22",
       "35.191.0.0/16",
       "10.110.73.30"
      ]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow {
        protocol = "tcp"
        ports    = ["443" ,"8000"]
      }
      
      
      log_config  {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }

# #Allow Colt On-prem IP
# import {
#   to = google_compute_firewall.aicoe_egress_allow_onprem_ip
#   id = "projects/aicoedev/global/firewalls/allow-onprem-ip"
# }
# resource "google_compute_firewall" "aicoe_egress_allow_onprem_ip" {
#       name        = "allow-onprem-ip"
#       network     = google_compute_network.aicoe_network.id
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
#       network     = google_compute_network.aicoe_network.id
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

# -----------------------------------------------------------------------------
# Firewall Rules - Google APIs PSC (Vertex management + embeddings APIs)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "aicoe_egress_allow_google_apis_psc" {
  name               = "egress-allow-google-apis-psc"
  network            = google_compute_network.aicoe_network.id
  description        = "Allow egress to Google APIs Private Service Connect endpoint"
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = ["192.168.2.3"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

