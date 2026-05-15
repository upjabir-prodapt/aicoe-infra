# -----------------------------------------------------------------------------
# Private DNS Zone for Google APIs
# -----------------------------------------------------------------------------
resource "google_dns_managed_zone" "aicoe_googleapis_private" {
  name        = "${var.project}${var.envname}-googleapis-private"
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs via PSC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.aicoe_network.id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleapis" {
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.aicoe_googleapis_private.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.aicoe_psc_address.address]
}

resource "google_dns_managed_zone" "aicoe_internal" {
  name        = "${var.project}${var.envname}-internal"
  dns_name    = "aicoesandox-int.colt.net."
  description = "Private DNS zone for internal ILB"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.aicoe_network.id
    }
  }
}


resource "google_dns_record_set" "aicoe_translation_dns" {
  name         = "translation.aicoesandox-int.colt.net."
  project      = "${var.project}${var.envname}"
  managed_zone = google_dns_managed_zone.aicoe_internal.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.aicoe_staticip_ilb.address]
}

resource "google_dns_record_set" "aicoe_salesagent_dns" {
  name         = "salesagent.aicoesandox-int.colt.net."
  project      = "${var.project}${var.envname}"
  managed_zone = google_dns_managed_zone.aicoe_internal.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.aicoe_staticip_ilb_salesagent.address]
}

resource "google_dns_record_set" "aicoe_aihub" {
  name         = "aihub.aicoesandox-int.colt.net."
  project      = "${var.project}${var.envname}"
  managed_zone = google_dns_managed_zone.aicoe_internal.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.aicoe_staticip_ilb_frontend.address]
}

# -----------------------------------------------------------------------------
# Private DNS Zone for Google User content to enable Deny-all firewall
# -----------------------------------------------------------------------------
resource "google_dns_managed_zone" "aicoe_googleusercontent_private" {
  name        = "${var.project}${var.envname}-googleusercontent-private"
  dns_name    = "googleusercontent.com."
  description = "Private DNS zone for Google user content.com - Routes workbench kernel and proxy traffic via PSC. Required for JupyterLab to work with deny-all egress enabled."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.aicoe_network.id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleusercontent" {
  name         = "*.googleusercontent.com."
  managed_zone = google_dns_managed_zone.aicoe_googleusercontent_private.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.aicoe_psc_address.address]
}