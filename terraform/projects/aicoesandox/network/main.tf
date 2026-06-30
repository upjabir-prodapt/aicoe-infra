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
  region                          = var.region
  resource_prefix                 = local.resource_prefix
  subnet_cidr_range               = var.subnet_cidr_range
  proxy_subnet_cidr_range         = var.proxy_subnet_cidr_range
  ingress_https_source_ranges     = var.ingress_https_source_ranges
  internal_ilb_destination_ranges = var.internal_ilb_destination_ranges
  psc_egress_destination_ranges   = var.psc_egress_destination_ranges
  enable_fastly_pypi_egress       = true
  enable_azure_devops_rules       = true
  enable_google_apis_psc_egress   = true
  labels                          = local.default_labels
}

module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id                 = local.gcp_project_id
  region                         = var.region
  resource_prefix                = local.resource_prefix
  network_id                     = module.network_base.network_id
  network_self_link              = module.network_base.network_self_link
  subnet_id                      = module.network_base.subnet_id
  psc_google_apis_address        = var.psc_google_apis_address
  reserved_internal_addresses    = var.reserved_internal_addresses
  regional_psc_addresses         = var.regional_psc_addresses
  internal_dns_zone              = var.internal_dns_zone
  labels                         = local.default_labels
  internal_dns_records = {
    translation = {
      name    = "translation.aicoesandox-int.colt.net."
      address = var.reserved_internal_addresses["translation-ilb"].address
    }
    salesagent = {
      name    = "salesagent.aicoesandox-int.colt.net."
      address = var.reserved_internal_addresses["salesagent-ilb"].address
    }
    aihub = {
      name    = "aihub.aicoesandox-int.colt.net."
      address = var.reserved_internal_addresses["frontend-ilb"].address
    }
  }
}
