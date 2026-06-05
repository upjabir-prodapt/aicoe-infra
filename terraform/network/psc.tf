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

# -----------------------------------------------------------------------------
# PSC Forwarding rule for Vector search
# -----------------------------------------------------------------------------
resource "google_compute_address" "aicoe_psc_vector_index_ip" {
  name          = "${var.project}${var.envname}-psc-vector-index-ip"
  address_type  = "INTERNAL"
  purpose       = "GCE_ENDPOINT"
  subnetwork    = google_compute_subnetwork.aicoe_subnet.id
  address       = "10.110.74.5"
  region        = var.region
  project = "${var.project}${var.envname}"
}

locals {
  vector_search_service_attachment = try(data.terraform_remote_state.infra.outputs.vector_search_service_attachment, null)
}

# resource "google_compute_forwarding_rule" "aicoe_psc_vector_index_fr" {
#   name        = "${var.project}${var.envname}-psc-vector-index-fr"
#   region      = var.region
#   project     = "${var.project}${var.envname}"
#   network     = google_compute_network.aicoe_network.id
#   ip_address  = google_compute_address.aicoe_psc_vector_index_ip.id
#   target      = local.vector_search_service_attachment
#   load_balancing_scheme = ""

#   # depends_on = [
#   #   google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index,
#   # ]
# }