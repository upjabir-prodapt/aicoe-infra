locals {
  gcp_project_id  = var.project
  resource_prefix = "${var.project}-${var.envname}"
}
