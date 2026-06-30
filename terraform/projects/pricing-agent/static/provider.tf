provider "google" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = local.default_labels
}

provider "google-beta" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = local.default_labels
}
