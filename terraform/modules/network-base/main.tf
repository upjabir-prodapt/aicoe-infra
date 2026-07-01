resource "google_compute_network" "network" {
  name                    = "${var.resource_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.resource_prefix}-subnet"
  region        = var.region
  network       = google_compute_network.network.self_link
  ip_cidr_range = var.subnet_cidr_range
  project       = var.gcp_project_id
}

resource "google_compute_subnetwork" "proxy_only_subnet" {
  name          = "${var.resource_prefix}-proxy-subnet"
  region        = var.region
  network       = google_compute_network.network.self_link
  ip_cidr_range = var.proxy_subnet_cidr_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  project       = var.gcp_project_id
}

resource "google_compute_firewall" "egress_deny_all" {
  count = var.enable_egress_deny_all ? 1 : 0

  name               = "egress-deny-all"
  network            = google_compute_network.network.id
  description        = "Blanket default deny rule for egress"
  direction          = "EGRESS"
  priority           = 65535
  destination_ranges = ["0.0.0.0/0"]
  project            = var.gcp_project_id

  deny {
    protocol = "all"
    ports    = null
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ingress_allow_iap" {
  count = var.enable_iap_ssh_ingress ? 1 : 0

  name        = "ingress-allow-iap-ssh"
  network     = google_compute_network.network.id
  description = "FW rules required to ssh into instances via IAP"
  direction   = "INGRESS"
  priority    = 65534
  project     = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "egress_allow_fastly_pypi" {
  count = var.enable_fastly_pypi_egress ? 1 : 0

  name               = "egress-allow-fastly-cdn-for-pypi"
  network            = google_compute_network.network.id
  description        = "Allow egress to Fastly CDN IP Ranges used by PyPi"
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = ["23.235.32.0/20", "43.249.72.0/22", "103.244.50.0/24", "103.245.222.0/23", "103.245.224.0/24", "104.156.80.0/20", "140.248.64.0/18", "140.248.128.0/17", "146.75.0.0/17", "151.101.0.0/16", "157.52.64.0/18", "167.82.0.0/17", "167.82.128.0/20", "167.82.160.0/20", "167.82.224.0/20", "172.111.64.0/18", "185.31.16.0/22", "199.27.72.0/21", "199.232.0.0/16"]
  project            = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["443", "3128"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ingress_allow_azure_devops" {
  count = var.enable_azure_devops_rules ? 1 : 0

  name        = "ingress-allow-tcp-azure-devops"
  network     = google_compute_network.network.id
  description = "Allow inbound connection from Azure DevOps outbound IP ranges"
  direction   = "INGRESS"
  priority    = 65534
  project     = var.gcp_project_id
  source_ranges = [
    "150.171.22.0/24",
    "150.171.23.0/24",
    "150.171.73.0/24",
    "150.171.74.0/24",
    "150.171.75.0/24",
    "150.171.76.0/24",
    "13.107.6.183/32",
    "13.107.9.183/32",
  ]

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "egress_allow_azure_devops" {
  count = var.enable_azure_devops_rules ? 1 : 0

  name        = "egress-allow-tcp-azure-devops"
  network     = google_compute_network.network.id
  description = "Allow outbound connection to Azure DevOps IP ranges"
  direction   = "EGRESS"
  priority    = 65534
  project     = var.gcp_project_id
  destination_ranges = [
    "150.171.22.0/24",
    "150.171.23.0/24",
    "150.171.73.0/24",
    "150.171.74.0/24",
    "150.171.75.0/24",
    "150.171.76.0/24",
    "13.107.6.183/32",
    "13.107.9.183/32",
  ]

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "ingress_allow_https" {
  count = var.enable_https_ilb_ingress ? 1 : 0

  name          = "ingress-allow-https-ilb"
  network       = google_compute_network.network.id
  description   = "Allow HTTPS traffic for Internal Load Balancer"
  direction     = "INGRESS"
  priority      = 65534
  project       = var.gcp_project_id
  source_ranges = var.ingress_https_source_ranges

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal_ilb" {
  count = var.enable_internal_ilb_egress ? 1 : 0

  name               = "egress-allow-internal-ilb"
  network            = google_compute_network.network.id
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = var.internal_ilb_destination_ranges
  project            = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "egress_allow_google_apis_psc" {
  count = var.enable_google_apis_psc_egress ? 1 : 0

  name               = "egress-allow-google-apis-psc"
  network            = google_compute_network.network.id
  description        = "Allow egress to Google APIs Private Service Connect endpoint"
  direction          = "EGRESS"
  priority           = 65534
  destination_ranges = var.psc_egress_destination_ranges
  project            = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
