resource "google_compute_global_address" "aicoe_psc_address" {
  name          = "${var.project}${var.envname}-psc-google-apis-ip"
  address_type  = "INTERNAL"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = google_compute_network.aicoe_network.id
  address       = "192.168.2.3"
}

# IMPORTANT: PSC forwarding rule names for Google API bundles (all-apis, vpc-sc)
# must be 1-20 characters, lowercase letters and numbers only, starting with a letter.
# Hyphens are NOT allowed.
resource "google_compute_global_forwarding_rule" "aicoe_psc_google_apis" {
  name                  = "${var.project}${var.envname}pscapis"
  network               = google_compute_network.aicoe_network.id
  ip_address            = google_compute_global_address.aicoe_psc_address.id
  target                = "all-apis"
  load_balancing_scheme = ""
}


###########################################
### PSC for Vector Search Index ###########
###########################################
import {
  id = "projects/${var.project}${var.envname}/regions/${var.region}/addresses/aicoe-psc-vector-index-ip"
  to = google_compute_address.aicoe_psc_vector_index_ip
}
resource "google_compute_address" "aicoe_psc_vector_index_ip" {
  name          = "${var.project}${var.envname}-psc-vector-index-ip"
  address_type  = "INTERNAL"
  purpose       = "GCE_ENDPOINT"
  network       = google_compute_network.aicoe_network.id
  address       = "192.168.1.5"
}

### Forwarding rule for Vector Search PSC ###
import {
  id = "projects/${var.project}${var.envname}/regions/${var.region}/forwardingRules/aicoe-psc-vector-index-fr"
  to = google_compute_forwarding_rule.aicoe_psc_vector_index_fr
}
resource "google_compute_forwarding_rule" "aicoe_psc_vector_index_fr" {
  name                  = "${var.project}${var.envname}-psc-vector-index-fr"
  network               = google_compute_network.aicoe_network.id
  ip_address            = google_global_address.aicoe_psc_vector_index_ip.id
  target                = "SERVICE_ATTACHMENT_URI"
  load_balancing_scheme = ""
}