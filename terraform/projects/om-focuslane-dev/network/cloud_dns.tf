# -----------------------------------------------------------------------------
# Private DNS Zone for Google APIs
# -----------------------------------------------------------------------------
# Kept as a plain resource: modules/network-connectivity bundles an
# unrequested *.googleusercontent.com private zone into every
# enable_cloud_dns = true call, with no flag to create just the googleapis
# zone. om-focus-lane only wants the googleapis zone it already has.
resource "google_dns_managed_zone" "aicoe_googleapis_private" {
  name        = "${local.resource_prefix}-googleapis-private"
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs via PSC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.network_base.network_id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleapis" {
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.aicoe_googleapis_private.name
  type         = "A"
  ttl          = 300
  # PSC address now comes from module.network_connectivity (see psc.tf, main.tf)
  rrdatas      = [module.network_connectivity.psc_google_apis_ip]
}

# resource "google_dns_managed_zone" "aicoe_internal" {
#   name        = "${var.project}${var.envname}-internal"
#   dns_name    = "aicoedev-int.colt.net."
#   description = "Private DNS zone for internal ILB"
#   visibility  = "private"

#   private_visibility_config {
#     networks {
#       network_url = module.network_base.network_id
#     }
#   }
# }


# resource "google_dns_record_set" "aicoe_translation_dns" {
#   name         = "translation.aicoedev-int.colt.net."
#   project      = "${var.project}${var.envname}"
#   managed_zone = google_dns_managed_zone.aicoe_internal.name
#   type         = "A"
#   ttl          = 300
#   rrdatas      = [google_compute_address.aicoe_staticip_ilb.address]
# }
