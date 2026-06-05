locals {
  vector_search_service_attachment = try(
    "https://www.googleapis.com/compute/v1/${google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index.private_endpoints[0].service_attachment}",
    null,
  )
}

resource "google_compute_forwarding_rule" "aicoe_psc_vector_index_fr" {
  name        = "${var.project}${var.envname}-psc-vector-index-fr"
  region      = var.region
  project     = "${var.project}${var.envname}"
  network     = data.terraform_remote_state.network.outputs.aicoe_network_id
  ip_address  = data.terraform_remote_state.network.outputs.vector_search_psc_ip_self_link
  target      = local.vector_search_service_attachment
  load_balancing_scheme = ""

  depends_on = [
    google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index,
  ]
}
