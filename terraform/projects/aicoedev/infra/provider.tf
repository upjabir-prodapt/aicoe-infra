provider "google" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = {
    environment = var.envname
    managed_by  = "terraform"
  }
}

provider "google-beta" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = {
    environment = var.envname
    managed_by  = "terraform"
  }
}
 