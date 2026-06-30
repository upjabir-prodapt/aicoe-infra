module "network_base" {
  source = "../../../modules/network-base"

  gcp_project_id                = local.gcp_project_id
  project                       = var.project
  envname                       = var.envname
  region                        = var.region
  resource_prefix               = local.resource_prefix
  aicoe_subnet_cidr_range       = var.aicoe_subnet_cidr_range
  aicoe_proxy_subnet_cidr_range = var.aicoe_proxy_subnet_cidr_range
  ingress_https_source_ranges = [
    "10.110.73.0/24",
    "192.168.5.0/24",
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
  internal_ilb_destination_ranges = ["10.110.73.0/24"]
}

module "network_connectivity" {
  source = "../../../modules/network-connectivity"

  gcp_project_id         = local.gcp_project_id
  project                = var.project
  envname                = var.envname
  region                 = var.region
  resource_prefix        = local.resource_prefix
  network_id             = module.network_base.aicoe_network_id
  network_self_link      = module.network_base.aicoe_network
  subnet_id              = module.network_base.aicoe_subnet_id
  aicoe_static_ilb_ip    = var.aicoe_static_ilb_ip
  enable_cloud_nat       = false
  internal_dns_zone      = ""
  internal_dns_records   = {}
}
