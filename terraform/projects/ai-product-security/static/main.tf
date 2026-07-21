module "base" {
  source = "../../../modules/static-base"
  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  gcp_apis_required = var.gcp_apis_required
  # ai-product-security's original audit.tf only audited aiplatform, and
  # included ADMIN_READ (unlike static-base's aicoedev-derived defaults of
  # storage/aiplatform/bigquery with DATA_READ+DATA_WRITE only).
  audit_services  = ["aiplatform.googleapis.com"]
  audit_log_types = ["ADMIN_READ", "DATA_READ", "DATA_WRITE"]
  # ai-product-security's original tags.tf bound the env tag using the
  # project id string, not a project_number (unlike aicoedev/vegadev).
  # Reproduce that exact parent path so this migration is a pure state
  # move with no resource diff.
  #tag_binding_parent = "//cloudresourcemanager.googleapis.com/projects/${local.gcp_project_id}"
  tag_binding_parent = "//cloudresourcemanager.googleapis.com/projects/${var.project_number}"
}