locals {
  vector_search_service_attachment = try(
    "https://www.googleapis.com/compute/v1/${google_vertex_ai_index_endpoint_deployed_index.vector_deployed_index.private_endpoints[0].service_attachment}",
    null,
  )
}

import {
  to = google_compute_forwarding_rule.psc_vector_index_fr
  id = "projects/aicoedev/regions/europe-west1/forwardingRules/aicoedev-psc-vector-index-fr"
} 
resource "google_compute_forwarding_rule" "psc_vector_index_fr" {
  name                  = "${var.resource_prefix}-${var.psc_forwarding_rule_name_suffix}"
  region                = var.region
  project               = var.gcp_project_id
  network               = var.network_id
  ip_address            = var.vector_search_psc_ip_self_link
  target                = local.vector_search_service_attachment
  load_balancing_scheme = ""
  labels                = var.labels

  depends_on = [
    google_vertex_ai_index_endpoint_deployed_index.vector_deployed_index,
  ]
}
