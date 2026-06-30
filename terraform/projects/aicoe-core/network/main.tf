data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-static"
  }
}

module "network_base" {
  source = "../../../modules/network-base"

  gcp_project_id                = local.gcp_project_id
  project                       = var.project
  envname                       = var.envname
  region                        = var.region
  resource_prefix               = local.resource_prefix
  aicoe_subnet_cidr_range       = var.aicoe_subnet_cidr_range
  aicoe_proxy_subnet_cidr_range = var.aicoe_proxy_subnet_cidr_range
}

module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id                 = local.gcp_project_id
  project                        = var.project
  envname                        = var.envname
  region                         = var.region
  resource_prefix                = local.resource_prefix
  network_id                     = module.network_base.aicoe_network_id
  network_self_link              = module.network_base.aicoe_network
  subnet_id                      = module.network_base.aicoe_subnet_id
  aicoe_static_vxaiwb_ip         = var.aicoe_static_vxaiwb_ip
  aicoe_static_ilb_ip            = var.aicoe_static_ilb_ip
  aicoe_static_ilb_salesagent_ip = var.aicoe_static_ilb_salesagent_ip
  aicoe_static_ilb_frontend_ip   = var.aicoe_static_ilb_frontend_ip
  internal_dns_zone              = var.internal_dns_zone
  internal_dns_records = {
    translation = {
      name    = "translation.aicoesandox-int.colt.net."
      address = var.aicoe_static_ilb_ip
    }
    salesagent = {
      name    = "salesagent.aicoesandox-int.colt.net."
      address = var.aicoe_static_ilb_salesagent_ip
    }
    aihub = {
      name    = "aihub.aicoesandox-int.colt.net."
      address = var.aicoe_static_ilb_frontend_ip
    }
  }
}
