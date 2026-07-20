module "network_base" {
  source = "../modules/network-base"

  gcp_project_id  = local.gcp_project_id
  region          = var.region
  resource_prefix = local.resource_prefix

  # vegadev currently has no subnet or proxy-only subnet at all - only a
  # VPC and two firewall rules exist today.
  create_subnet            = false
  create_proxy_only_subnet = false

  # Unused while the corresponding subnets/firewalls are disabled below,
  # but the module still requires values of these types.
  subnet_cidr_range                = ""
  proxy_subnet_cidr_range          = ""
  ingress_https_source_ranges      = []
  internal_ilb_destination_ranges  = []
  psc_egress_destination_ranges    = var.psc_egress_destination_ranges

  # Reproduces vegadev's current network exactly - today only the deny-all
  # egress rule and the Google APIs PSC egress rule exist.
  enable_egress_deny_all        = true
  enable_iap_ssh_ingress        = false
  enable_fastly_pypi_egress     = false
  enable_azure_devops_rules     = false
  enable_https_ilb_ingress      = false
  enable_internal_ilb_egress    = false
  enable_google_apis_psc_egress = true

  labels = local.default_labels
}

module "network_connectivity" {
  source = "../modules/network-connectivity"

  gcp_project_id           = local.gcp_project_id
  region                   = var.region
  resource_prefix          = local.resource_prefix
  network_id               = module.network_base.network_id
  network_self_link        = module.network_base.network_self_link
  subnet_id                = module.network_base.subnet_id
  psc_google_apis_address  = var.psc_google_apis_address

  # vegadev's original PSC address/forwarding-rule names are literal
  # strings, not derived from the (longer) project id - reproduce them
  # exactly so this migration doesn't force a rename/recreate.
  psc_google_apis_address_name         = "vegadev-psc-google-apis-ip"
  psc_google_apis_forwarding_rule_name = "vegadevpscapis"

  # vegadev has no Cloud NAT, and no reserved/regional PSC IP reservations
  # today.
  enable_cloud_nat = false

  # Disabled here and recreated as a plain resource below - the module
  # bundles an unrequested internal DNS zone and a *.googleusercontent.com
  # zone into every enable_cloud_dns=true call, with no flag to skip just
  # those pieces. vegadev only wants the googleapis zone it already has.
  enable_cloud_dns = false

  labels = local.default_labels
}

###########################################
### Existing Google APIs private DNS zone ###
### Kept as a plain resource - see the enable_cloud_dns comment above. ###
###########################################

resource "google_dns_managed_zone" "aicoe_googleapis_private" {
  name        = "${var.project}-googleapis-private"
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
