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


# -----------------------------------------------------------------------------
# Firewall Rules - Google APIs PSC (Vertex management + embeddings APIs)
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "aicoe_egress_allow_google_apis_psc" {
  name               = "egress-allow-google-apis-psc"
  network            = google_compute_network.aicoe_network.id
  description        = "Allow egress to Google APIs Private Service Connect endpoint"
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = ["192.168.2.3", "10.110.73.5/32"]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

