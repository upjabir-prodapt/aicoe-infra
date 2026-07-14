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

import {
  to = module.vector_search.google_compute_forwarding_rule.psc_vector_index_fr
  id = "projects/aicoedev/regions/europe-west1/forwardingRules/aicoedev-psc-vector-index-fr"
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