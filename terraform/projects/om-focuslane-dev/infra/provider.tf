provider "google" {
  project = local.gcp_project_id
  region  = var.region # Choose the appropriate region for your bucket
}

provider "google-beta" {
  project = local.gcp_project_id
  region  = var.region # Choose the appropriate region for your bucket
}
