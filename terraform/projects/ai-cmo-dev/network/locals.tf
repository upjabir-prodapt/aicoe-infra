locals {
  gcp_project_id  = var.gcp_project_id != "" ? var.gcp_project_id : "${var.project}"
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.project}"
  state_bucket    = var.state_bucket != "" ? var.state_bucket : "${var.project}-bucket-tf-state"

  default_labels = {
    env    = var.envname
    system = local.resource_prefix
  }
}
 