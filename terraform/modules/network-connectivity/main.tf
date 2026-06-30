resource "google_compute_address" "aicoe_staticip_nat_1" {
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.resource_prefix}-staticip-nat-1"
  region  = var.region
  project = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}

resource "google_compute_address" "aicoe_staticip_nat_2" {
  count   = var.enable_cloud_nat ? 1 : 0
  name    = "${var.resource_prefix}-staticip-nat-2"
  region  = var.region
  project = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}

resource "google_compute_router" "aicoe_router_cloudnat" {
  count   = var.enable_cloud_nat ? 1 : 0
  project = var.gcp_project_id
  name    = "${var.resource_prefix}-router-cloudnat"
  network = var.network_self_link
  region  = var.region
}

resource "google_compute_router_nat" "aicoe_cloudnat" {
  count                              = var.enable_cloud_nat ? 1 : 0
  name                               = "${var.resource_prefix}-cloudnat"
  router                             = google_compute_router.aicoe_router_cloudnat[0].name
  region                             = var.region
  project                            = var.gcp_project_id
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.aicoe_staticip_nat_1[0].self_link, google_compute_address.aicoe_staticip_nat_2[0].self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_global_address" "aicoe_psc_address" {
  count         = var.enable_psc ? 1 : 0
  name          = "${var.resource_prefix}-psc-google-apis-ip"
  address_type  = "INTERNAL"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = var.network_id
  address       = var.psc_google_apis_address
  project       = var.gcp_project_id
}

resource "google_compute_global_forwarding_rule" "aicoe_psc_google_apis" {
  count                 = var.enable_psc ? 1 : 0
  name                  = "${replace(var.resource_prefix, "-", "")}pscapis"
  network               = var.network_id
  ip_address            = google_compute_global_address.aicoe_psc_address[0].id
  target                = "all-apis"
  load_balancing_scheme = ""
  project               = var.gcp_project_id
}

resource "google_compute_address" "aicoe_psc_vector_index_ip" {
  count         = var.enable_psc ? 1 : 0
  name          = "${var.resource_prefix}-psc-vector-index-ip"
  address_type  = "INTERNAL"
  purpose       = "GCE_ENDPOINT"
  subnetwork    = var.subnet_id
  address       = var.psc_vector_index_address
  region        = var.region
  project       = var.gcp_project_id
}

resource "google_dns_managed_zone" "aicoe_googleapis_private" {
  count       = var.enable_cloud_dns ? 1 : 0
  name        = "${var.resource_prefix}-googleapis-private"
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs via PSC"
  visibility  = "private"
  project     = var.gcp_project_id

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleapis" {
  count        = var.enable_cloud_dns ? 1 : 0
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.aicoe_googleapis_private[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.aicoe_psc_address[0].address]
  project      = var.gcp_project_id
}

resource "google_dns_managed_zone" "aicoe_internal" {
  count       = var.enable_cloud_dns && var.internal_dns_zone != "" ? 1 : 0
  name        = "${var.resource_prefix}-internal"
  dns_name    = var.internal_dns_zone
  description = "Private DNS zone for internal ILB"
  visibility  = "private"
  project     = var.gcp_project_id

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "aicoe_internal_records" {
  for_each     = var.enable_cloud_dns && var.internal_dns_zone != "" ? var.internal_dns_records : {}
  name         = each.value.name
  managed_zone = google_dns_managed_zone.aicoe_internal[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value.address]
  project      = var.gcp_project_id
}

resource "google_dns_managed_zone" "aicoe_googleusercontent_private" {
  count       = var.enable_cloud_dns ? 1 : 0
  name        = "${var.resource_prefix}-googleusercontent-private"
  dns_name    = "googleusercontent.com."
  description = "Private DNS zone for Google user content via PSC"
  visibility  = "private"
  project     = var.gcp_project_id

  private_visibility_config {
    networks {
      network_url = var.network_id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleusercontent" {
  count        = var.enable_cloud_dns ? 1 : 0
  name         = "*.googleusercontent.com."
  managed_zone = google_dns_managed_zone.aicoe_googleusercontent_private[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.aicoe_psc_address[0].address]
  project      = var.gcp_project_id
}

resource "google_compute_address" "aicoe_staticip_vxaiwb" {
  count        = var.aicoe_static_vxaiwb_ip != "" ? 1 : 0
  name         = "${var.resource_prefix}-vxaiwb"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  address      = var.aicoe_static_vxaiwb_ip
  region       = var.region
  project      = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}

resource "google_compute_address" "aicoe_staticip_ilb" {
  count        = var.aicoe_static_ilb_ip != "" ? 1 : 0
  name         = "${var.resource_prefix}-ilb"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  address      = var.aicoe_static_ilb_ip
  region       = var.region
  project      = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}

resource "google_compute_address" "aicoe_staticip_ilb_salesagent" {
  count        = var.aicoe_static_ilb_salesagent_ip != "" ? 1 : 0
  name         = "${var.resource_prefix}-ilb-salesagent"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  address      = var.aicoe_static_ilb_salesagent_ip
  region       = var.region
  project      = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}

resource "google_compute_address" "aicoe_staticip_ilb_frontend" {
  count        = var.aicoe_static_ilb_frontend_ip != "" ? 1 : 0
  name         = "${var.resource_prefix}-ilb-frontend"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  address      = var.aicoe_static_ilb_frontend_ip
  region       = var.region
  project      = var.gcp_project_id
  labels = {
    env    = var.envname
    system = var.resource_prefix
  }
}
