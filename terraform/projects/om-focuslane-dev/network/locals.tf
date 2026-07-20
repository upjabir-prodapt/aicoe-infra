locals {
  gcp_project_id  = var.project
  resource_prefix = "${var.project}-${var.envname}"

  default_labels = {
    env    = var.envname
    system = var.project
  }
}
