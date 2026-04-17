# ILB for primary region
resource "google_compute_region_backend_service" "aicoe_ilb_be" {
  name   = "${var.project}${var.envname}-ilb-be"
  region = var.region
  project = "${var.project}${var.envname}" 
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.aicoe_serverless_neg.id
    balancing_mode = "UTILIZATION"
  }
}
 
resource "google_compute_region_network_endpoint_group" "aicoe_serverless_neg" {
  name                  = "${var.project}${var.envname}-serverless-neg"
  network               = data.terraform_remote_state.network.outputs.aicoe_network
  subnetwork            = data.terraform_remote_state.network.outputs.aicoe_proxy_only_subnet_name
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_region_url_map" "aicoe_ilb_url_map" {
    name    = "${var.project}${var.envname}-ilb-url-map"
    project = "${var.project}${var.envname}"
    region  = var.region
    default_service = google_compute_region_backend_service.aicoe_ilb_be.id
}
 
resource "google_compute_forwarding_rule" "aicoe_ilb_forwarding_rule" {
  name                  = "${var.project}${var.envname}-ilb-fe"
  project               = "${var.project}${var.envname}"
  region                = var.region
  network               = data.terraform_remote_state.network.outputs.aicoe_network
  subnetwork            = data.terraform_remote_state.network.outputs.aicoe_subnet_name
  target                = google_compute_region_backend_service.aicoe_ilb_be.id
  port_range            = 443
  ip_address            = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
  
}