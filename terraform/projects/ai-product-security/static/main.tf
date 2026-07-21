module "base" {
  source = "../../../modules/static-base"
  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
  audit_services    = [ "aiplatform.googleapis.com" ]
  audit_log_types = ["ADMIN_READ", "DATA_READ", "DATA_WRITE"]
  tag_binding_parent = "//cloudresourcemanager.googleapis.com/projects/${local.gcp_project_id}"
}