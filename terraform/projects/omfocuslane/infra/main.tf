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

module "firestore" {
  source = "../../../modules/infra-firestore"

  gcp_project_id = local.gcp_project_id
  project        = var.project
  envname        = var.envname
  region         = var.region
  firestore_name = "om-focus-lane-firestore"
}
