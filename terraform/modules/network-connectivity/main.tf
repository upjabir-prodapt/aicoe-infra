###resource "google_compute_address" "nat_ip" {
###  for_each = var.enable_cloud_nat ? toset(var.cloud_nat_ip_name_suffixes) : toset([])
###
###  name    = "${var.resource_prefix}-${each.value}"
###  region  = var.region
###  project = var.gcp_project_id
###  labels  = var.labels
###}
###
###resource "google_compute_router" "cloud_nat_router" {
###  count   = var.enable_cloud_nat ? 1 : 0
###  project = var.gcp_project_id
###  name    = "${var.resource_prefix}-router-cloudnat"
###  network = var.network_self_link
###  region  = var.region
###}
###
###resource "google_compute_router_nat" "cloud_nat" {
###  count                              = var.enable_cloud_nat ? 1 : 0
###  name                               = "${var.resource_prefix}-cloudnat"
###  router                             = google_compute_router.cloud_nat_router[0].name
###  region                             = var.region
###  project                            = var.gcp_project_id
###  nat_ip_allocate_option             = "MANUAL_ONLY"
###  nat_ips                            = [for ip in google_compute_address.nat_ip : ip.self_link]
###  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
###
###  log_config {
###    enable = true
###    filter = "ERRORS_ONLY"
###  }
###}
###
###resource "google_compute_global_address" "psc_google_apis_address" {
###  count         = var.enable_psc ? 1 : 0
###  name          = "${var.resource_prefix}-psc-google-apis-ip"
###  address_type  = "INTERNAL"
###  purpose       = "PRIVATE_SERVICE_CONNECT"
###  network       = var.network_id
###  address       = var.psc_google_apis_address
###  project       = var.gcp_project_id
###}
###
###resource "google_compute_global_forwarding_rule" "psc_google_apis" {
###  count                 = var.enable_psc ? 1 : 0
###  name                  = "${replace(var.resource_prefix, "-", "")}pscapis"
###  network               = var.network_id
###  ip_address            = google_compute_global_address.psc_google_apis_address[0].id
###  target                = "all-apis"
###  load_balancing_scheme = ""
###  project               = var.gcp_project_id
###}
###
###resource "google_compute_address" "regional_psc_address" {
###  for_each = var.enable_psc ? var.regional_psc_addresses : {}
###
###  name          = "${var.resource_prefix}-${each.value.name_suffix}"
###  address_type  = "INTERNAL"
###  purpose       = each.value.purpose
###  subnetwork    = var.subnet_id
###  address       = each.value.address
###  region        = var.region
###  project       = var.gcp_project_id
###}
###
###resource "google_dns_managed_zone" "googleapis_private" {
###  count       = var.enable_cloud_dns ? 1 : 0
###  name        = "${var.resource_prefix}-googleapis-private"
###  dns_name    = "googleapis.com."
###  description = "Private DNS zone for Google APIs via PSC"
###  visibility  = "private"
###  project     = var.gcp_project_id
###
###  private_visibility_config {
###    networks {
###      network_url = var.network_id
###    }
###  }
###}
###
###resource "google_dns_record_set" "wildcard_googleapis" {
###  count        = var.enable_cloud_dns ? 1 : 0
###  name         = "*.googleapis.com."
###  managed_zone = google_dns_managed_zone.googleapis_private[0].name
###  type         = "A"
###  ttl          = 300
###  rrdatas      = [google_compute_global_address.psc_google_apis_address[0].address]
###  project      = var.gcp_project_id
###}
###
###resource "google_dns_managed_zone" "internal" {
###  count       = var.enable_cloud_dns && var.internal_dns_zone != "" ? 1 : 0
###  name        = "${var.resource_prefix}-internal"
###  dns_name    = var.internal_dns_zone
###  description = "Private DNS zone for internal ILB"
###  visibility  = "private"
###  project     = var.gcp_project_id
###
###  private_visibility_config {
###    networks {
###      network_url = var.network_id
###    }
###  }
###}
###
###resource "google_dns_record_set" "internal_records" {
###  for_each     = var.enable_cloud_dns && var.internal_dns_zone != "" ? var.internal_dns_records : {}
###  name         = each.value.name
###  managed_zone = google_dns_managed_zone.internal[0].name
###  type         = "A"
###  ttl          = 300
###  rrdatas      = [each.value.address]
###  project      = var.gcp_project_id
###}
###
###resource "google_dns_managed_zone" "googleusercontent_private" {
###  count       = var.enable_cloud_dns ? 1 : 0
###  name        = "${var.resource_prefix}-googleusercontent-private"
###  dns_name    = "googleusercontent.com."
###  description = "Private DNS zone for Google user content via PSC"
###  visibility  = "private"
###  project     = var.gcp_project_id
###
###  private_visibility_config {
###    networks {
###      network_url = var.network_id
###    }
###  }
###}
###
###resource "google_dns_record_set" "wildcard_googleusercontent" {
###  count        = var.enable_cloud_dns ? 1 : 0
###  name         = "*.googleusercontent.com."
###  managed_zone = google_dns_managed_zone.googleusercontent_private[0].name
###  type         = "A"
###  ttl          = 300
###  rrdatas      = [google_compute_global_address.psc_google_apis_address[0].address]
###  project      = var.gcp_project_id
###}
###
###resource "google_compute_address" "reserved_internal_address" {
###  for_each = var.reserved_internal_addresses
###
###  name         = "${var.resource_prefix}-${each.value.name_suffix}"
###  subnetwork   = var.subnet_id
###  address_type = "INTERNAL"
###  address      = each.value.address
###  region       = var.region
###  project      = var.gcp_project_id
###  labels       = var.labels
###}
###

resource "google_compute_address" "nat_ip" {
  for_each = var.enable_cloud_nat ? toset(var.cloud_nat_ip_name_suffixes) : toset([])

  name    = "${var.resource_prefix}-${each.value}"
  region  = var.region
  project = var.gcp_project_id
  labels  = var.labels
}

resource "google_compute_router" "cloud_nat_router" {
  count   = var.enable_cloud_nat ? 1 : 0
  project = var.gcp_project_id
  name    = "${var.resource_prefix}-router-cloudnat"
  network = var.network_self_link
  region  = var.region
}

resource "google_compute_router_nat" "cloud_nat" {
  count                              = var.enable_cloud_nat ? 1 : 0
  name                               = "${var.resource_prefix}-cloudnat"
  router                             = google_compute_router.cloud_nat_router[0].name
  region                             = var.region
  project                            = var.gcp_project_id
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [for ip in google_compute_address.nat_ip : ip.self_link]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_global_address" "psc_google_apis_address" {
  count        = var.enable_psc ? 1 : 0
  name         = var.psc_google_apis_address_name != "" ? var.psc_google_apis_address_name : "${var.resource_prefix}-psc-google-apis-ip"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = var.network_id
  address      = var.psc_google_apis_address
  project      = var.gcp_project_id
}

resource "google_compute_global_forwarding_rule" "psc_google_apis" {
  count                 = var.enable_psc ? 1 : 0
  name                  = var.psc_google_apis_forwarding_rule_name != "" ? var.psc_google_apis_forwarding_rule_name : "${replace(var.resource_prefix, "-", "")}pscapis"
  network               = var.network_id
  ip_address            = google_compute_global_address.psc_google_apis_address[0].id
  target                = "all-apis"
  load_balancing_scheme = ""
  project               = var.gcp_project_id
}

resource "google_compute_address" "regional_psc_address" {
  for_each = var.enable_psc ? var.regional_psc_addresses : {}

  name          = "${var.resource_prefix}-${each.value.name_suffix}"
  address_type  = "INTERNAL"
  purpose       = each.value.purpose
  subnetwork    = var.subnet_id
  address       = each.value.address
  region        = var.region
  project       = var.gcp_project_id
}

resource "google_dns_managed_zone" "googleapis_private" {
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

resource "google_dns_record_set" "wildcard_googleapis" {
  count        = var.enable_cloud_dns ? 1 : 0
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.googleapis_private[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.psc_google_apis_address[0].address]
  project      = var.gcp_project_id
}

resource "google_dns_managed_zone" "internal" {
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

resource "google_dns_record_set" "internal_records" {
  for_each     = var.enable_cloud_dns && var.internal_dns_zone != "" ? var.internal_dns_records : {}
  name         = each.value.name
  managed_zone = google_dns_managed_zone.internal[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [each.value.address]
  project      = var.gcp_project_id
}

resource "google_dns_managed_zone" "googleusercontent_private" {
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

resource "google_dns_record_set" "wildcard_googleusercontent" {
  count        = var.enable_cloud_dns ? 1 : 0
  name         = "*.googleusercontent.com."
  managed_zone = google_dns_managed_zone.googleusercontent_private[0].name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.psc_google_apis_address[0].address]
  project      = var.gcp_project_id
}

resource "google_compute_address" "reserved_internal_address" {
  for_each = var.reserved_internal_addresses

  name         = "${var.resource_prefix}-${each.value.name_suffix}"
  subnetwork   = var.subnet_id
  address_type = "INTERNAL"
  address      = each.value.address
  region       = var.region
  project      = var.gcp_project_id
  labels       = var.labels
}
 