locals {
  gcp_project_id = var.project

  resource_prefix = var.project

  default_labels = {
    env    = var.envname
    system = local.resource_prefix
  }
}
