module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
}

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id       = local.gcp_project_id
  region               = var.region
  resource_prefix      = local.resource_prefix
  enable_kms           = true
  enable_workbench_kms = false
  bucket_suffixes      = ["storage-bucket"]
  labels               = local.default_labels
}
