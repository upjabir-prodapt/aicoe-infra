###resource "google_compute_region_network_endpoint_group" "serverless_neg" {
###  for_each = var.services
###
###  name                  = "${var.resource_prefix}-serverless-neg-${each.key}"
###  network_endpoint_type = "SERVERLESS"
###  region                = var.region
###  project               = var.gcp_project_id
###
###  cloud_run {
###    service = each.value.cloud_run_service_name
###  }
###}
###
###resource "google_compute_region_backend_service" "backend" {
###  for_each = var.services
###
###  name                  = "${var.resource_prefix}-ilb-${each.key}-be"
###  region                = var.region
###  project               = var.gcp_project_id
###  load_balancing_scheme = "INTERNAL_MANAGED"
###  protocol              = "HTTPS"
###
###  backend {
###    group          = google_compute_region_network_endpoint_group.serverless_neg[each.key].id
###    balancing_mode = "UTILIZATION"
###  }
###}
###
###resource "google_compute_region_url_map" "url_map" {
###  for_each = var.services
###
###  name            = "${var.resource_prefix}-ilb-${each.key}-url-map"
###  project         = var.gcp_project_id
###  region          = var.region
###  default_service = google_compute_region_backend_service.backend[each.key].id
###}
###
###data "google_secret_manager_secret_version" "certificate" {
###  for_each = var.services
###
###  secret  = each.value.certificate_secret
###  project = var.gcp_project_id
###}
###
###data "google_secret_manager_secret_version" "private_key" {
###  for_each = var.services
###
###  secret  = each.value.private_key_secret
###  project = var.gcp_project_id
###}
###
###resource "google_compute_region_ssl_certificate" "ssl" {
###  for_each = var.services
###
###  name        = "${var.resource_prefix}-${each.key}-ssl"
###  project     = var.gcp_project_id
###  region      = var.region
###  certificate = data.google_secret_manager_secret_version.certificate[each.key].secret_data
###  private_key = data.google_secret_manager_secret_version.private_key[each.key].secret_data
###
###  lifecycle {
###    create_before_destroy = true
###  }
###}
###
###resource "google_compute_region_target_https_proxy" "https_proxy" {
###  for_each = var.services
###
###  name             = "${var.resource_prefix}-ilb-${each.key}-https-proxy"
###  project          = var.gcp_project_id
###  region           = var.region
###  url_map          = google_compute_region_url_map.url_map[each.key].id
###  ssl_certificates = [google_compute_region_ssl_certificate.ssl[each.key].id]
###}
###
###resource "google_compute_forwarding_rule" "forwarding_rule" {
###  for_each = var.services
###
###  name                  = "${var.resource_prefix}-ilb-${each.key}-fe"
###  project               = var.gcp_project_id
###  region                = var.region
###  network               = var.network_self_link
###  subnetwork            = var.subnet_self_link
###  target                = google_compute_region_target_https_proxy.https_proxy[each.key].id
###  port_range            = 443
###  ip_address            = each.value.ip_address
###  load_balancing_scheme = "INTERNAL_MANAGED"
###  allow_global_access   = false
###  labels                = var.labels
###}
resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each = var.services

  name                  = "${var.resource_prefix}-serverless-neg-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  project               = var.gcp_project_id

  cloud_run {
    service = each.value.cloud_run_service_name
  }
}

resource "google_compute_region_backend_service" "backend" {
  for_each = var.services

  name                  = "${var.resource_prefix}-ilb-${each.key}-be"
  region                = var.region
  project               = var.gcp_project_id
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTPS"

  backend {
    group          = google_compute_region_network_endpoint_group.serverless_neg[each.key].id
    balancing_mode = "UTILIZATION"
  }
}

resource "google_compute_region_url_map" "url_map" {
  for_each = var.services

  name            = "${var.resource_prefix}-ilb-${each.key}-url-map"
  project         = var.gcp_project_id
  region          = var.region
  default_service = google_compute_region_backend_service.backend[each.key].id

  dynamic "host_rule" {
    for_each = length(each.value.path_rules) > 0 ? [1] : []
    content {
      hosts        = ["*"]
      path_matcher = "${each.key}-routes"
    }
  }

  dynamic "path_matcher" {
    for_each = length(each.value.path_rules) > 0 ? [1] : []
    content {
      name            = "${each.key}-routes"
      default_service = google_compute_region_backend_service.backend[each.key].id

      dynamic "path_rule" {
        for_each = each.value.path_rules
        content {
          paths   = path_rule.value.paths
          service = google_compute_region_backend_service.backend[path_rule.value.backend_service_key].id

          dynamic "route_action" {
            for_each = path_rule.value.path_prefix_rewrite != null ? [1] : []
            content {
              url_rewrite {
                path_prefix_rewrite = path_rule.value.path_prefix_rewrite
              }
            }
          }
        }
      }
    }
  }
}

data "google_secret_manager_secret_version" "certificate" {
  for_each = var.services

  secret  = each.value.certificate_secret
  project = var.gcp_project_id
}

data "google_secret_manager_secret_version" "private_key" {
  for_each = var.services

  secret  = each.value.private_key_secret
  project = var.gcp_project_id
}

resource "google_compute_region_ssl_certificate" "ssl" {
  for_each = var.services

  name        = "${var.resource_prefix}-${each.key}-ssl"
  project     = var.gcp_project_id
  region      = var.region
  certificate = data.google_secret_manager_secret_version.certificate[each.key].secret_data
  private_key = data.google_secret_manager_secret_version.private_key[each.key].secret_data

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_target_https_proxy" "https_proxy" {
  for_each = var.services

  name             = coalesce(each.value.https_proxy_name, "${var.resource_prefix}-ilb-${each.key}-https-proxy")
  project          = var.gcp_project_id
  region           = var.region
  url_map          = google_compute_region_url_map.url_map[each.key].id
  ssl_certificates = [google_compute_region_ssl_certificate.ssl[each.key].id]
}

resource "google_compute_forwarding_rule" "forwarding_rule" {
  for_each = var.services

  name                  = "${var.resource_prefix}-ilb-${each.key}-fe"
  project               = var.gcp_project_id
  region                = var.region
  network               = var.network_self_link
  subnetwork            = var.subnet_self_link
  target                = google_compute_region_target_https_proxy.https_proxy[each.key].id
  port_range            = 443
  ip_address            = each.value.ip_address
  load_balancing_scheme = "INTERNAL_MANAGED"
  allow_global_access   = false
  labels                = var.labels
}