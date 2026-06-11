resource "google_compute_global_address" "aicoe_psc_address" {
  name          = "${var.project}-${var.envname}-psc-google-apis-ip"
  address_type  = "INTERNAL"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = google_compute_network.aicoe_network.id
  address       = "192.168.2.3"
}

# IMPORTANT: PSC forwarding rule names for Google API bundles (all-apis, vpc-sc)
# must be 1-20 characters, lowercase letters and numbers only, starting with a letter.
# Hyphens are NOT allowed.
resource "google_compute_global_forwarding_rule" "aicoe_psc_google_apis" {
  name                  = "omfocuslanepscapis"
  network               = google_compute_network.aicoe_network.id
  ip_address            = google_compute_global_address.aicoe_psc_address.id
  target                = "all-apis"
  load_balancing_scheme = ""
}
