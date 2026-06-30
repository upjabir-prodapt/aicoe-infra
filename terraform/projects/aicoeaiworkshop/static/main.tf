module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  envname           = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
}

module "group_iam" {
  source = "../../../modules/static-group-iam"

  gcp_project_id = local.gcp_project_id
  group_email    = var.group_email
}
