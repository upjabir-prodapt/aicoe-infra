# Kept as plain resources. modules/network-connectivity's PSC forwarding
# rule name is derived as replace(resource_prefix, "-", "") + "pscapis",
# which for om-focus-lane would be "omfocuslanedevpscapis" (22 chars) -
# that's both a different name than the existing "omfocuslanepscapis" AND
# over GCP's 20-character limit for all-apis-bundle PSC forwarding rule
# names, so it isn't usable here without editing the module. Use
# enable_psc = true on module.network_connectivity once/if the module gets
# an overridable name.
resource "google_compute_global_address" "aicoe_psc_address" {
  name         = "${local.resource_prefix}-psc-google-apis-ip"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = module.network_base.network_id
  address      = "192.168.2.3"
}

# IMPORTANT: PSC forwarding rule names for Google API bundles (all-apis,
# vpc-sc) must be 1-20 characters, lowercase letters and numbers only,
# starting with a letter. Hyphens are NOT allowed.
resource "google_compute_global_forwarding_rule" "aicoe_psc_google_apis" {
  name                  = "omfocuslanepscapis"
  network                = module.network_base.network_id
  ip_address              = google_compute_global_address.aicoe_psc_address.id
  target                  = "all-apis"
  load_balancing_scheme   = ""
}
