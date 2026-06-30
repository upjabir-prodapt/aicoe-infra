# ILB for primary region
resource "google_compute_region_backend_service" "aicoe_ilb_translation_be" {
  name   = "${var.resource_prefix}-ilb-translation-be"
  region = var.region
  project = var.gcp_project_id 
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.aicoe_serverless_neg_translation.id
    balancing_mode = "UTILIZATION"
  }
}
 


resource "google_compute_region_network_endpoint_group" "aicoe_serverless_neg_translation" {
  name                  = "${var.resource_prefix}-serverless-neg-translation"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name
  }
}

resource "google_compute_region_url_map" "aicoe_ilb_url_map" {
  name    = "${var.resource_prefix}-ilb-url-map"
  project = var.gcp_project_id
  region  = var.region
  default_service = google_compute_region_backend_service.aicoe_ilb_translation_be.id
}

resource "google_compute_region_target_https_proxy" "aicoe_ilb_https_proxy" {
  name    = "${var.resource_prefix}-ilb-https-proxy"
  project = var.gcp_project_id
  region  = var.region
  url_map = google_compute_region_url_map.aicoe_ilb_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.aicoe_translation_ssl.id]
}
 
resource "google_compute_forwarding_rule" "aicoe_ilb_forwarding_rule" {
  name                  = "${var.resource_prefix}-ilb-fe"
  project               = var.gcp_project_id
  region                = var.region
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
  target                = google_compute_region_target_https_proxy.aicoe_ilb_https_proxy.id
  port_range            = 443
  ip_address            = var.ilb_ip_address
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels = {
      env    = var.envname
      system = "${var.resource_prefix}"
    }
  
}


data "google_secret_manager_secret_version" "ssl_certificate" {
  secret  = "${var.resource_prefix}-ssl-certificate"
  project = var.gcp_project_id
}

# Read private key from Secret Manager
data "google_secret_manager_secret_version" "ssl_private_key" {
  secret  = "${var.resource_prefix}-ssl-private-key"
  project = var.gcp_project_id
}

# SSL Certificate
resource "google_compute_region_ssl_certificate" "aicoe_translation_ssl" {
  name    = "${var.resource_prefix}-translation-ssl"
  project = var.gcp_project_id
  region  = var.region

  certificate = data.google_secret_manager_secret_version.ssl_certificate.secret_data
  private_key = data.google_secret_manager_secret_version.ssl_private_key.secret_data

  lifecycle {
    create_before_destroy = true
  }
}

################## Sales Agent ILB ##################
# Backend service
resource "google_compute_region_backend_service" "aicoe_ilb_salesagent_be" {
  name   = "${var.resource_prefix}-ilb-salesagent-be"
  region = var.region
  project = var.gcp_project_id 
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.aicoe_serverless_neg_salesagent.id
    balancing_mode = "UTILIZATION"
  }
}
 

resource "google_compute_region_network_endpoint_group" "aicoe_serverless_neg_salesagent" {
  name                  = "${var.resource_prefix}-serverless-neg-salesagent"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name2
  }
}

resource "google_compute_region_url_map" "aicoe_ilb_salesagent_url_map" {
  name    = "${var.resource_prefix}-ilb-salesagent-url-map"
  project = var.gcp_project_id
  region  = var.region
  default_service = google_compute_region_backend_service.aicoe_ilb_salesagent_be.id
}

resource "google_compute_region_target_https_proxy" "aicoe_ilb_salesagent_https_proxy" {
  name    = "${var.resource_prefix}-ilb-salesagent-https-proxy"
  project = var.gcp_project_id
  region  = var.region
  url_map = google_compute_region_url_map.aicoe_ilb_salesagent_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.aicoe_salesagent_ssl.id]
}
 
resource "google_compute_forwarding_rule" "aicoe_ilb_salesagent_forwarding_rule" {
  name                  = "${var.resource_prefix}-ilb-salesagent-fe"
  project               = var.gcp_project_id
  region                = var.region
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
  target                = google_compute_region_target_https_proxy.aicoe_ilb_salesagent_https_proxy.id
  port_range            = 443
  ip_address            = var.ilb_ip_address_salesagent
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels = {
      env    = var.envname
      system = "${var.resource_prefix}"
    }
  
}


data "google_secret_manager_secret_version" "salesagent_ssl_cert" {
  secret  = "${var.resource_prefix}-salesagent-ssl-cert"
  project = var.gcp_project_id
}

# Read private key from Secret Manager
data "google_secret_manager_secret_version" "salesagent_private_key" {
  secret  = "${var.resource_prefix}-salesagent-ssl-private-key"
  project = var.gcp_project_id
}

# SSL Certificate
resource "google_compute_region_ssl_certificate" "aicoe_salesagent_ssl" {
  name    = "${var.resource_prefix}-salesagent-ssl"
  project = var.gcp_project_id
  region  = var.region

  certificate = data.google_secret_manager_secret_version.salesagent_ssl_cert.secret_data
  private_key = data.google_secret_manager_secret_version.salesagent_private_key.secret_data

  lifecycle {
    create_before_destroy = true
  }
}


################## AI Hub ILB ##################
# Backend service
resource "google_compute_region_backend_service" "aicoe_ilb_aihub_be" {
  name   = "${var.resource_prefix}-ilb-aihub-be"
  region = var.region
  project = var.gcp_project_id 
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.aicoe_serverless_neg_aihub.id
    balancing_mode = "UTILIZATION"
  }
}
 

resource "google_compute_region_network_endpoint_group" "aicoe_serverless_neg_aihub" {
  name                  = "${var.resource_prefix}-serverless-neg-aihub"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.cloud_run_service_name3
  }
}

resource "google_compute_region_url_map" "aicoe_ilb_aihub_url_map" {
  name    = "${var.resource_prefix}-ilb-aihub-url-map"
  project = var.gcp_project_id
  region  = var.region
  default_service = google_compute_region_backend_service.aicoe_ilb_aihub_be.id
}

resource "google_compute_region_target_https_proxy" "aicoe_ilb_aihub_https_proxy" {
  name    = "${var.resource_prefix}-ilb-aihub-https-proxy"
  project = var.gcp_project_id
  region  = var.region
  url_map = google_compute_region_url_map.aicoe_ilb_aihub_url_map.id
  ssl_certificates = [google_compute_region_ssl_certificate.aicoe_aihub_ssl.id]
}
 
resource "google_compute_forwarding_rule" "aicoe_ilb_aihub_forwarding_rule" {
  name                  = "${var.resource_prefix}-ilb-aihub-fe"
  project               = var.gcp_project_id
  region                = var.region
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
  target                = google_compute_region_target_https_proxy.aicoe_ilb_aihub_https_proxy.id
  port_range            = 443
  ip_address            = var.ilb_frontend_ip_address
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels = {
      env    = var.envname
      system = "${var.resource_prefix}"
    }
  
}


data "google_secret_manager_secret_version" "aihub_ssl_cert" {
  secret  = "${var.resource_prefix}-aihub-ssl-certificate"
  project = var.gcp_project_id
}

# Read private key from Secret Manager
data "google_secret_manager_secret_version" "aihub_private_key" {
  secret  = "${var.resource_prefix}-aihub-ssl-private-key"
  project = var.gcp_project_id
}

# SSL Certificate
resource "google_compute_region_ssl_certificate" "aicoe_aihub_ssl" {
  name    = "${var.resource_prefix}-aihub-ssl"
  project = var.gcp_project_id
  region  = var.region

  certificate = data.google_secret_manager_secret_version.aihub_ssl_cert.secret_data
  private_key = data.google_secret_manager_secret_version.aihub_private_key.secret_data

  lifecycle {
    create_before_destroy = true
  }
}





