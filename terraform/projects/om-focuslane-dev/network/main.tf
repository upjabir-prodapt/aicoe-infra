###########################################
### Static Layer Remote TF State file   ###
###########################################
# NOTE: prefixes below are kept exactly as they were in the flat layout
# ("tfstate-static"/"tfstate-infra", no project-name subfolder) - do NOT
# change these to match ai-cmo-dev's "${var.project_name}/tfstate-..."
# convention, that would point at a different (empty) GCS state path.

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "tfstate-static"
  }
}

###########################################
### Infra Layer Remote TF State file   ###
###########################################

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "tfstate-infra"
  }
}

module "network_base" {
  source = "../../../modules/network-base"

  gcp_project_id                  = local.gcp_project_id
  region                           = var.region
  resource_prefix                  = local.resource_prefix
  subnet_cidr_range                = var.aicoe_subnet_cidr_range
  proxy_subnet_cidr_range          = var.aicoe_proxy_subnet_cidr_range
  ingress_https_source_ranges      = var.ingress_https_source_ranges
  internal_ilb_destination_ranges  = var.internal_ilb_destination_ranges
  psc_egress_destination_ranges    = var.psc_egress_destination_ranges

  # Reproduces today's dev environment exactly.
  enable_internal_ilb_egress    = false
  enable_google_apis_psc_egress = true
  enable_iap_ssh_ingress        = false # commented out in the old code, never created

  # Disabled here and recreated as a plain resource below - the module
  # hardcodes ports=["443"], but dev needs 443 AND 8000. Routing this
  # through the module would show as a permanent plan diff.
  enable_https_ilb_ingress = false

  labels = local.default_labels
}

module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id           = local.gcp_project_id
  region                   = var.region
  resource_prefix          = local.resource_prefix
  network_id               = module.network_base.network_id
  network_self_link        = module.network_base.network_self_link
  subnet_id                = module.network_base.subnet_id
  psc_google_apis_address  = var.psc_google_apis_address

  # The old forwarding rule name ("omfocuslanepscapis") predates the
  # "-dev" suffix now baked into resource_prefix, and PSC forwarding rule
  # names for Google API bundles can't contain hyphens anyway - override
  # so this doesn't force a replacement.
  psc_google_apis_forwarding_rule_name = "omfocuslanepscapis"

  reserved_internal_addresses = {
    ilb = {
      name_suffix = "ilb"
      address     = var.aicoe_static_ilb_ip
    }
  }

  # Disabled here and recreated as a plain resource below - the module
  # bundles an unrequested *.googleusercontent.com private DNS zone into
  # every enable_cloud_dns=true call, with no flag to skip just that piece.
  enable_cloud_dns = false

  labels = local.default_labels
}

# NOTE: the port-8000-and-443 HTTPS ingress firewall rule lives in
# firewall.tf, not here - see the enable_https_ilb_ingress comment above.

###########################################
### Dev-only DNS zone/record              ###
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
 