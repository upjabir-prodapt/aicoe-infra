module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
}

# Group IAM disabled — matches pricingagent-sandbox branch (group not provisioned in Workspace).
# module "group_iam" {
#   source = "../../../modules/static-group-iam"
#
#   gcp_project_id = local.gcp_project_id
#   group_email    = var.group_email
# }

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id                  = local.gcp_project_id
  region                          = var.region
  resource_prefix                 = local.resource_prefix
  enable_kms                      = true
  enable_workbench_kms            = false
  bucket_suffixes                 = ["billing-bucket"]
  bucket_kms_key_ring_name_suffix = "app-bucket-key-ring"
  bucket_kms_key_name_suffix      = "app-bucket-key"
  labels                          = local.default_labels
}
