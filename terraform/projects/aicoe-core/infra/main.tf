data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-static"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-network"
  }
}

module "notebook" {
  source = "../../../modules/infra-notebook"

  gcp_project_id     = local.gcp_project_id
  project            = var.project
  envname            = var.envname
  region             = var.region
  resource_prefix    = local.resource_prefix
  machine_type       = var.machine_type
  boot_disk_size_gb  = var.boot_disk_size_gb
  boot_disk_type     = var.boot_disk_type
  data_disk_size_gb  = var.data_disk_size_gb
  data_disk_type     = var.data_disk_type
  network_self_link  = data.terraform_remote_state.network.outputs.aicoe_network
  subnet_self_link   = data.terraform_remote_state.network.outputs.aicoe_subnet_name
}

module "load_balancer" {
  source = "../../../modules/infra-lb"

  gcp_project_id            = local.gcp_project_id
  project                   = var.project
  envname                   = var.envname
  region                    = var.region
  resource_prefix           = local.resource_prefix
  network_self_link         = data.terraform_remote_state.network.outputs.aicoe_network
  subnet_self_link          = data.terraform_remote_state.network.outputs.aicoe_subnet_name
  cloud_run_service_name    = var.cloud_run_service_name
  cloud_run_service_name2   = var.cloud_run_service_name2
  cloud_run_service_name3   = var.cloud_run_service_name3
  ilb_ip_address            = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb
  ilb_salesagent_ip_address = data.terraform_remote_state.network.outputs.aicoe_staticip_ilb_salesagent
  ilb_frontend_ip_address   = data.terraform_remote_state.network.outputs.aicoe_static_ilb_frontend_ip
}

module "vector_search" {
  source = "../../../modules/infra-vector-search"

  gcp_project_id                 = local.gcp_project_id
  project                        = var.project
  envname                        = var.envname
  region                         = var.region
  resource_prefix                = local.resource_prefix
  network_id                     = data.terraform_remote_state.network.outputs.aicoe_network_id
  vector_search_psc_ip_self_link = data.terraform_remote_state.network.outputs.vector_search_psc_ip_self_link
}

module "bq" {
  source = "../../../modules/infra-bq"

  gcp_project_id  = local.gcp_project_id
  project         = var.project
  envname         = var.envname
  region          = var.region
  resource_prefix = local.resource_prefix
}
