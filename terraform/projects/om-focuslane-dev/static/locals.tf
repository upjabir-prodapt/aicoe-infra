locals {
  # NOTE: unlike aicoedev/ai-cmo-dev (whose var.project is a short name and
  ## gcp_project_id = "${var.project}${var.envname}"), om-focus-lane's
  # var.project already IS the full GCP project id ("om-focus-lane") - same
  # pattern as vegadev. gcp_project_id just passes it through unchanged.
  gcp_project_id  = var.gcp_project_id != "" ? var.gcp_project_id : var.project
  resource_prefix = var.resource_prefix != "" ? var.resource_prefix : "${var.project}-${var.envname}"
  state_bucket    = var.state_bucket != "" ? var.state_bucket : "${var.project}-${var.envname}-bucket-tf-state"

  # Matches the original hardcoded labels exactly: system was always
  # var.project (not project+envname), so use gcp_project_id here rather
  # than resource_prefix to keep a zero-diff migration.
  default_labels = {
    env    = var.envname
    system = local.gcp_project_id
  }
}
