###########################################
### Static Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-static"
  }
}

module "network_base" {
  source = "../../../modules/network-base"

  gcp_project_id                  = local.gcp_project_id
  region                           = var.region
  resource_prefix                  = local.resource_prefix
  subnet_cidr_range                = var.subnet_cidr_range
  proxy_subnet_cidr_range          = var.proxy_subnet_cidr_range
  ingress_https_source_ranges      = var.ingress_https_source_ranges
  internal_ilb_destination_ranges  = var.internal_ilb_destination_ranges
  psc_egress_destination_ranges    = var.psc_egress_destination_ranges

  # These flags reproduce today's dev environment exactly (all currently
  # false/absent in dev, unlike sandox where they are enabled).
  enable_internal_ilb_egress    = true
  enable_google_apis_psc_egress = true
  enable_egress_deny_all = true

  # Disabled here and recreated as plain resources below - the module
  # hardcodes a shorter description, and (for https) a fixed ports=["443"]
  # list. Dev needs 443 AND 8000, plus the original descriptions, so
  # routing these through the module would show as a permanent plan diff.
  enable_https_ilb_ingress = true
  enable_iap_ssh_ingress   = true

  labels = local.default_labels
}

module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id              = local.gcp_project_id
  region                      = var.region
  resource_prefix             = local.resource_prefix
  network_id                  = module.network_base.network_id
  network_self_link           = module.network_base.network_self_link
  subnet_id                   = module.network_base.subnet_id
  psc_google_apis_address     = var.psc_google_apis_address
  reserved_internal_addresses = var.reserved_internal_addresses
  regional_psc_addresses      = var.regional_psc_addresses


  enable_cloud_dns = true

  labels = local.default_labels
}

###########################################
### Dev-only firewall rules              ###
### (Colt on-prem / Zscaler / HTTPS ILB / IAP SSH) ###
### Kept as plain resources - see comments above for why. ###
###########################################

resource "google_compute_firewall" "aicoe_egress_allow_onprem_ip" {
  name        = "allow-onprem-ip"
  network     = module.network_base.network_id
  description = "Allow traffic from Colt On-prem IP"
  direction   = "EGRESS"
  priority    = 65534
  source_ranges = [
    "10.100.254.206",
    "10.100.209.0/29",
    "10.100.4.66"
  ]
  source_tags             = null
  source_service_accounts = null
  target_tags              = null
  target_service_accounts  = null

  allow {
    protocol = "icmp"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "aicoe_ingress_allow_zscaler_ip" {
  name        = "allow-zscalerapp"
  network     = module.network_base.network_id
  description = "Allow traffic for Zscaler IP"
  direction   = "INGRESS"
  priority    = 65534
  source_ranges = [
    "10.100.209.0/29"
  ]
  source_tags             = null
  source_service_accounts = null
  target_tags              = null
  target_service_accounts  = null

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}


###########################################
### Dev-only DNS zones/records            ###
### Kept as plain resources - see enable_cloud_dns comment above. ###
###########################################

resource "google_dns_managed_zone" "aicoe_googleapis_private" {
  name        = "${local.resource_prefix}-googleapis-private"
  dns_name    = "googleapis.com."
  description = "Private DNS zone for Google APIs via PSC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.network_base.network_id
    }
  }
}

resource "google_dns_record_set" "aicoe_wildcard_googleapis" {
  name         = "*.googleapis.com."
  managed_zone = google_dns_managed_zone.aicoe_googleapis_private.name
  type         = "A"
  ttl          = 300
  rrdatas      = [module.network_connectivity.psc_google_apis_ip]
}

resource "google_dns_managed_zone" "aicoe_internal" {
  name        = "${local.resource_prefix}-internal"
  dns_name    = var.internal_dns_zone
  description = "Private DNS zone for internal ILB"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.network_base.network_id
    }
  }
}


resource "google_dns_record_set" "aicoe_salesagent_dns" {
  name         = "salesagent.aicmodev-int.colt.net."
  project      = local.gcp_project_id
  managed_zone = google_dns_managed_zone.aicoe_internal.name
  type         = "A"
  ttl          = 300
  rrdatas      = [var.reserved_internal_addresses["salesagent-ilb"].address]
}

 