###########################################
### VPC, subnets, base firewall rules   ###
###########################################
module "network_base" {
  source = "../../../modules/network-base"

  gcp_project_id           = local.gcp_project_id
  region                   = var.region
  resource_prefix          = local.resource_prefix
  subnet_cidr_range        = var.aicoe_subnet_cidr_range
  proxy_subnet_cidr_range  = var.aicoe_proxy_subnet_cidr_range

  # om-focus-lane doesn't have an IAP-SSH rule, a Fastly/PyPI egress rule,
  # Azure DevOps rules, or an internal-ILB egress rule today - all off to
  # match current state exactly.
  enable_iap_ssh_ingress      = false
  enable_fastly_pypi_egress   = false
  enable_azure_devops_rules   = false
  enable_internal_ilb_egress  = false

  # Kept off and recreated as a plain resource in firewall.tf: the module's
  # ingress_allow_https only opens port 443, but om-focus-lane needs 443
  # AND 8000 open. Routing this through the module would show a permanent
  # ports diff.
  enable_https_ilb_ingress = false

  enable_egress_deny_all        = true
  enable_google_apis_psc_egress = true

  # These two vars are required by the module but unused while the
  # corresponding enable_* flags above are false.
  ingress_https_source_ranges     = var.ingress_https_source_ranges
  internal_ilb_destination_ranges = var.internal_ilb_destination_ranges

  # Matches the existing egress-allow-google-apis-psc rule's destination.
  psc_egress_destination_ranges = var.psc_egress_destination_ranges

  labels = local.default_labels
}

###########################################
### Reserved internal IP (ILB)          ###
###########################################
# NOTE: enable_cloud_dns stays off here - see cloud_dns.tf for why the DNS
# zone stays a plain resource (the module still bundles an unrequested
# *.googleusercontent.com zone into every enable_cloud_dns = true call,
# with no flag to create just the googleapis zone).
#
# enable_psc is now ON: modules/network-connectivity gained
# psc_google_apis_address_name / psc_google_apis_forwarding_rule_name
# overrides, which removes the naming blocker that used to keep the PSC
# address and forwarding rule as plain resources in psc.tf. See moved.tf
# for the state migration.
module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id     = local.gcp_project_id
  region             = var.region
  resource_prefix    = local.resource_prefix
  network_id         = module.network_base.network_id
  network_self_link  = module.network_base.network_self_link
  subnet_id          = module.network_base.subnet_id

  reserved_internal_addresses = {
    ilb = {
      name_suffix = "ilb"
      address     = var.aicoe_static_ilb_ip
    }
  }

  psc_google_apis_address = "192.168.2.3"

  # Default module name would be "omfocuslanedevpscapis" (22 chars) - over
  # GCP's 20-char limit for all-apis-bundle forwarding rule names, and
  # different from the existing "omfocuslanepscapis". Pin the legacy name
  # so terraform doesn't try to destroy/recreate it.
  psc_google_apis_forwarding_rule_name = "omfocuslanepscapis"

  enable_cloud_nat = false
  enable_cloud_dns = false
  enable_psc       = true

  labels = local.default_labels
}
