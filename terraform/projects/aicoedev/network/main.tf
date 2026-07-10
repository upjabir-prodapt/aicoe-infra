###########################################
### Static Layer Remote TF State file   ##
###########################################

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    #prefix = "tfstate-static"
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

  # These 3 flags reproduce today's dev environment exactly (all currently
  # false/absent in dev, unlike sandox where they are enabled).
  enable_fastly_pypi_egress     = false
  enable_azure_devops_rules     = false
  enable_internal_ilb_egress    = false
  enable_google_apis_psc_egress = true

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
  internal_dns_zone           = var.internal_dns_zone

  # dev has no Cloud NAT today (sandox-only in the old code) - keep it that way.
  enable_cloud_nat = false

  labels = local.default_labels

  internal_dns_records = {
    translation = {
      name    = "translation.aicoedev-int.colt.net."
      address = var.reserved_internal_addresses["translation-ilb"].address
    }
    salesagent = {
      name    = "salesagent.aicoedev-int.colt.net."
      address = var.reserved_internal_addresses["salesagent-ilb"].address
    }
    aihub = {
      name    = "aihub.aicoedev-int.colt.net."
      address = var.reserved_internal_addresses["frontend-ilb"].address
    }
  }
}

###########################################
### Dev-only firewall rules (Colt on-prem / Zscaler) ###
### These have no equivalent flag in network-base,   ###
### so they stay as plain resources here, unchanged. ###
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
  target_tags             = null
  target_service_accounts = null

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
  target_tags             = null
  target_service_accounts = null

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
 