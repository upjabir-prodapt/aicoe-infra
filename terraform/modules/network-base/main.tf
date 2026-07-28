####VPC
###resource "google_compute_network" "network" {
###  name                    = "${var.resource_prefix}-vpc"
###  auto_create_subnetworks = false
###  project                 = var.gcp_project_id
###}
###
####Subnet
###resource "google_compute_subnetwork" "subnet" {
###  count = var.create_subnet ? 1 : 0
###
###  name          = "${var.resource_prefix}-subnet"
###  region        = var.region
###  network       = google_compute_network.network.self_link
###  ip_cidr_range = var.subnet_cidr_range
###  project       = var.gcp_project_id
###}
###
###resource "google_compute_subnetwork" "proxy_only_subnet" {
###  count = var.create_proxy_only_subnet ? 1 : 0
###
###  name          = "${var.resource_prefix}-proxy-subnet"
###  region        = var.region
###  network       = google_compute_network.network.self_link
###  ip_cidr_range = var.proxy_subnet_cidr_range
###  purpose       = "REGIONAL_MANAGED_PROXY"
###  role          = "ACTIVE"
###  project       = var.gcp_project_id
###}
###
####Firewall
###resource "google_compute_firewall" "egress_deny_all" {
###  count = var.enable_egress_deny_all ? 1 : 0
###
###  name               = "egress-deny-all"
###  network            = google_compute_network.network.id
###  description        = "Blanket default deny rule for egress"
###  direction          = "EGRESS"
###  priority           = 65535
###  destination_ranges = ["0.0.0.0/0"]
###  project            = var.gcp_project_id
###
###  deny {
###    protocol = "all"
###    ports    = null
###  }
###
###  log_config {
###    metadata = "INCLUDE_ALL_METADATA"
###  }
###}
###
###resource "google_compute_firewall" "ingress_allow_iap" {
###  count = var.enable_iap_ssh_ingress ? 1 : 0
###
###  name        = "ingress-allow-iap-ssh"
###  network     = google_compute_network.network.id
###  description = "FW rules required to ssh into instances via IAP"
###  direction   = "INGRESS"
###  priority    = 65534
###  project     = var.gcp_project_id
###
###  allow {
###    protocol = "tcp"
###    ports    = ["22"]
###  }
###
###  source_ranges = ["35.235.240.0/20"]
###}
###
###
###resource "google_compute_firewall" "ingress_allow_https" {
###  count = var.enable_https_ilb_ingress ? 1 : 0
###
###  name          = "ingress-allow-https-ilb"
###  network       = google_compute_network.network.id
###  description   = "Allow HTTPS traffic for Internal Load Balancer"
###  direction     = "INGRESS"
###  priority      = 65534
###  project       = var.gcp_project_id
###  source_ranges = var.ingress_https_source_ranges
###
###  allow {
###    protocol = "tcp"
###    ports    = ["443"]
###  }
###
###  log_config {
###    metadata = "INCLUDE_ALL_METADATA"
###  }
###}
###
###resource "google_compute_firewall" "allow_internal_ilb" {
###  count = var.enable_internal_ilb_egress ? 1 : 0
###
###  name               = "egress-allow-internal-ilb"
###  network            = google_compute_network.network.id
###  direction          = "EGRESS"
###  priority           = 65534
###  destination_ranges = var.internal_ilb_destination_ranges
###  project            = var.gcp_project_id
###
###  allow {
###    protocol = "tcp"
###    ports    = ["443"]
###  }
###
###  log_config {
###    metadata = "INCLUDE_ALL_METADATA"
###  }
###}
###
###resource "google_compute_firewall" "egress_allow_google_apis_psc" {
###  count = var.enable_google_apis_psc_egress ? 1 : 0
###
###  name               = "egress-allow-google-apis-psc"
###  network            = google_compute_network.network.id
###  description        = "Allow egress to Google APIs Private Service Connect endpoint"
###  direction          = "EGRESS"
###  priority           = 65534
###  destination_ranges = var.psc_egress_destination_ranges
###  project            = var.gcp_project_id
###
###  allow {
###    protocol = "tcp"
###    ports    = ["443"]
###  }
###
###  log_config {
###    metadata = "INCLUDE_ALL_METADATA"
###  }
###}
### 

#VPC
resource "google_compute_network" "network" {
  name                    = "${var.resource_prefix}-vpc"
  auto_create_subnetworks = false
  project                 = var.gcp_project_id
}

#Subnet
resource "google_compute_subnetwork" "subnet" {
  count = var.create_subnet ? 1 : 0

  name          = "${var.resource_prefix}-subnet"
  region        = var.region
  network       = google_compute_network.network.self_link
  ip_cidr_range = var.subnet_cidr_range
  project       = var.gcp_project_id
}

resource "google_compute_subnetwork" "proxy_only_subnet" {
  count = var.create_proxy_only_subnet ? 1 : 0

  name          = "${var.resource_prefix}-proxy-subnet"
  region        = var.region
  network       = google_compute_network.network.self_link
  ip_cidr_range = var.proxy_subnet_cidr_range
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  project       = var.gcp_project_id
}

#Firewall
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
  description = var.iap_ssh_ingress_description
  direction   = "INGRESS"
  priority    = 65534
  project     = var.gcp_project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}


resource "google_compute_firewall" "ingress_allow_https" {
  count = var.enable_https_ilb_ingress ? 1 : 0

  name          = "ingress-allow-https-ilb"
  network       = google_compute_network.network.id
  description   = var.https_ilb_ingress_description
  direction     = "INGRESS"
  priority      = 65534
  project       = var.gcp_project_id
  source_ranges = var.ingress_https_source_ranges

  allow {
    protocol = "tcp"
    ports    = var.https_ilb_ingress_ports
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

  dynamic "allow" {
    for_each = var.google_apis_psc_egress_allow_rules
    content {
      protocol = allow.value.protocol
      ports    = allow.value.ports
    }
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
 