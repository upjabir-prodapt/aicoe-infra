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
# NOTE: enable_psc and enable_cloud_dns are both off here - see psc.tf and
# cloud_dns.tf for why the PSC address/forwarding-rule and the DNS zone
# stay as plain resources instead of going through this module.
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

  # Unused - enable_psc is false below, but the variable is required.
  psc_google_apis_address = "192.168.2.3"

  enable_cloud_nat = false
  enable_cloud_dns = false
  enable_psc       = false

  labels = local.default_labels
}
