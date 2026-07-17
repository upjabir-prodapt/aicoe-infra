locals {
  # var.project already holds the full GCP project id (e.g. "vegadev-499613")
  # rather than a prefix combined with envname.
  gcp_project_id = var.project
}
