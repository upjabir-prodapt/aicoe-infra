# ILB for primary region
resource "google_compute_region_backend_service" "aicoe_ilb_translation_be" {
  name   = "${var.project}${var.envname}-ilb-translation-be"
  region = var.region
  project = "${var.project}${var.envname}" 
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.aicoe_serverless_neg_translation.id
    balancing_mode = "UTILIZATION"
  }
}
 


resource "google_compute_region_network_endpoint_group" "aicoe_serverless_neg_translation" {
  name                  = "${var.project}${var.envname}-serverless-neg-translation"
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
  default_service = google_compute_region_backend_service.aicoe_ilb_translation_be.id
}

resource "google_compute_region_target_https_proxy" "aicoe_ilb_https_proxy" {
  name    = "${var.project}${var.envname}-ilb-https-proxy"
  project = "${var.project}${var.envname}"
  region  = var.region
  url_map = google_compute_region_url_map.aicoe_ilb_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.aicoe_translation_ssl.id]
}
 
resource "google_compute_forwarding_rule" "aicoe_ilb_forwarding_rule" {
  name                  = "${var.project}${var.envname}-ilb-fe"
  project               = "${var.project}${var.envname}"
  region                = var.region
  network               = data.terraform_remote_state.network.outputs.aicoe_network
  subnetwork            = data.terraform_remote_state.network.outputs.aicoe_subnet_name
  target                = google_compute_region_target_https_proxy.aicoe_ilb_https_proxy.id
  port_range            = 443
  ip_address            = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
  
}


data "google_secret_manager_secret_version" "ssl_certificate" {
  secret  = "${var.project}${var.envname}-ssl-certificate"
  project = "${var.project}${var.envname}"
}

# Read private key from Secret Manager
data "google_secret_manager_secret_version" "ssl_private_key" {
  secret  = "${var.project}${var.envname}-ssl-private-key"
  project = "${var.project}${var.envname}"
}

# SSL Certificate
resource "google_compute_region_ssl_certificate" "aicoe_translation_ssl" {
  name    = "${var.project}${var.envname}-translation-ssl"
  project = "${var.project}${var.envname}"
  region  = var.region

  certificate = data.google_secret_manager_secret_version.ssl_certificate.secret_data
  private_key = data.google_secret_manager_secret_version.ssl_private_key.secret_data

  lifecycle {
    create_before_destroy = true
  }
}



