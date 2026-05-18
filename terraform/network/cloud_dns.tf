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
  count   = var.envname == "sandox" ? 1 : 0
  name        = "${var.project}${var.envname}-internal"
  dns_name    = "aicoeprod-int.colt.net."
  description = "Private DNS zone for internal ILB"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.aicoe_network.id
    }
  }
}


resource "google_dns_record_set" "aicoe_translation_dns" {
  count   = var.envname == "sandox" ? 1 : 0
  name         = "translation.aicoeprod-int.colt.net."
  project      = "${var.project}${var.envname}"
  managed_zone = google_dns_managed_zone.aicoe_internal[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.aicoe_staticip_ilb[0].address]
}

resource "google_dns_record_set" "aicoe_salesagent_dns" {
  count   = var.envname == "sandox" ? 1 : 0
  name         = "salesagent.aicoeprod-int.colt.net."
  project      = "${var.project}${var.envname}"
  managed_zone = google_dns_managed_zone.aicoe_internal[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.aicoe_staticip_ilb_salesagent[0].address]
}