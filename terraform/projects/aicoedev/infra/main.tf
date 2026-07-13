###data "terraform_remote_state" "static" {
###  backend = "gcs"
###  config = {
###    bucket = local.state_bucket
###    #prefix = "tfstate-static"
###    prefix = "${var.project_name}/tfstate-static"
###  }
###}###

###data "terraform_remote_state" "network" {
###  backend = "gcs"
###  config = {
###    bucket = local.state_bucket
###    #prefix = "tfstate-network"
###    prefix = "${var.project_name}/tfstate-network"
###  }
###}###

#### NOTE: no module "notebook" block here on purpose. In the old code the
#### workbench instance was gated by `count = var.envname == "sandox" ? 1 : 0`,
#### so dev has never actually created one. Adding `module "notebook" {...}`
#### unconditionally (as aicoesandox does) would show up as "1 to add" in
#### `terraform plan`. Uncomment/add it later if/when dev is meant to get a
#### notebook too - see modules/infra-notebook for the interface.###

###module "load_balancer" {
###  source = "../../../modules/infra-serverless-ilb"###

###  gcp_project_id    = local.gcp_project_id
###  region            = var.region
###  resource_prefix   = local.resource_prefix
###  network_self_link = local.network_self_link
###  subnet_self_link  = local.subnet_self_link
###  services          = local.ilb_services
###  labels            = local.default_labels
###}###

###module "vector_search" {
###  source = "../../../modules/infra-vector-search"###

###  gcp_project_id                 = local.gcp_project_id
###  region                         = var.region
###  resource_prefix                = local.resource_prefix
###  network_id                     = local.network_id
###  vector_search_psc_ip_self_link = data.terraform_remote_state.network.outputs.vector_search_psc_ip_self_link
###  index_display_name             = "${local.resource_prefix}_salesagent_index"
###  endpoint_display_name          = "${local.resource_prefix}-salesagent-endpoint"
###  deployed_index_id              = "${local.resource_prefix}_vector_index"
###  deployed_index_display_name    = "AICOE salesagent Deployed Index"
###  labels                         = local.default_labels
###}###

###module "bigquery" {
###  source = "../../../modules/infra-bigquery"###

###  gcp_project_id = local.gcp_project_id
###  region         = var.region
###  labels         = local.default_labels
###  datasets       = local.bigquery_datasets
###}###

###module "notebook" {
#### NOTE: no module "notebook" block here on purpose. In the old code the
###  source = "../../../modules/infra-notebook"
#### workbench instance was gated by `count = var.envname == "sandox" ? 1 : 0`,
#### so dev has never actually created one. Adding `module "notebook" {...}`
###  gcp_project_id    = local.gcp_project_id
#### unconditionally (as aicoesandox does) would show up as "1 to add" in
###  region            = var.region
#### `terraform plan`. Uncomment/add it later if/when dev is meant to get a
###  resource_prefix   = local.resource_prefix
#### notebook too - see modules/infra-notebook for the interface.
###  machine_type      = var.machine_type
###  boot_disk_size_gb = var.boot_disk_size_gb
###  boot_disk_type    = var.boot_disk_type
###  data_disk_size_gb = var.data_disk_size_gb
###  data_disk_type    = var.data_disk_type
###  network_self_link = local.network_self_link
###  subnet_self_link  = local.subnet_self_link
###  labels            = local.default_labels
###}

data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    #prefix = "tfstate-static"
    prefix = "${var.project_name}/tfstate-static"
  }
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    #prefix = "tfstate-network"
    prefix = "${var.project_name}/tfstate-network"
  }
}

# NOTE: no module "notebook" block here on purpose. In the old code the
# workbench instance was gated by `count = var.envname == "sandox" ? 1 : 0`,
# so dev has never actually created one. Adding `module "notebook" {...}`
# unconditionally (as aicoesandox does) would show up as "1 to add" in
# `terraform plan`. Uncomment/add it later if/when dev is meant to get a
# notebook too - see modules/infra-notebook for the interface.

module "load_balancer" {
  source = "../../../modules/infra-serverless-ilb"

  gcp_project_id    = local.gcp_project_id
  region            = var.region
  resource_prefix   = local.resource_prefix
  network_self_link = local.network_self_link
  subnet_self_link  = local.subnet_self_link
  services          = local.ilb_services
  labels            = local.default_labels
}

module "vector_search" {
  source = "../../../modules/infra-vector-search"

  gcp_project_id                 = local.gcp_project_id
  region                         = var.region
  resource_prefix                = local.resource_prefix
  network_id                     = local.network_id
  vector_search_psc_ip_self_link = data.terraform_remote_state.network.outputs.vector_search_psc_ip_self_link
  index_display_name             = "${local.resource_prefix}_salesagent_index"
  endpoint_display_name          = "${local.resource_prefix}-salesagent-endpoint"
  deployed_index_id              = "${local.resource_prefix}_vector_index"
  deployed_index_display_name    = "AICOE salesagent Deployed Index"
  labels                         = local.default_labels
}

module "bigquery" {
  source = "../../../modules/infra-bigquery"

  gcp_project_id = local.gcp_project_id
  region         = var.region
  labels         = local.default_labels
  datasets       = local.bigquery_datasets
}