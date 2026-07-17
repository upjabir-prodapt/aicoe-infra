module "base" {
  source = "../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required

  # vegadev's original audit.tf only audited aiplatform (unlike
  # static-base's aicoedev-derived default of storage/aiplatform/bigquery).
  # Its audit log types (DATA_READ + DATA_WRITE) and its tag_binding_parent
  # (project_number-based) already match the module's defaults, so no
  # overrides are needed for those.
  audit_services = ["aiplatform.googleapis.com"]
}
