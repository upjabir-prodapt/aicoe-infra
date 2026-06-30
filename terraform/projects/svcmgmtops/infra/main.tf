data "terraform_remote_state" "static" {
  backend = "gcs"
  config = {
    bucket = local.state_bucket
    prefix = "${var.project_name}/tfstate-static"
  }
}

module "bq_dataset" {
  source = "../../../modules/infra-bq-dataset"

  gcp_project_id  = local.gcp_project_id
  region          = var.region
  resource_prefix = local.resource_prefix
  labels          = local.default_labels
}
