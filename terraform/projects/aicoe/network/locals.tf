locals {
  gcp_project_id  = var.gcp_project_id != "" ? var.gcp_project_id : "${var.project}${var.envname}"
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.project}${var.envname}"
  state_bucket    = var.state_bucket != "" ? var.state_bucket : "${var.project}${var.envname}-bucket-tf-state"

  default_labels = {
    env    = var.envname
    system = local.resource_prefix
  }
}
 