locals {
  gcp_project_id = var.project

  # Matches the original flat resource naming ("${var.project}-vpc" etc.)#
  resource_prefix = var.project

  default_labels = {
    env    = var.envname
    system = local.resource_prefix
  }
}
