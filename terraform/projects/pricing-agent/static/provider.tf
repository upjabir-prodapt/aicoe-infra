provider "google" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = {
    environment = var.envname
    managed_by  = "terraform"
    project     = var.project_name
  }
}

provider "google-beta" {
  project = local.gcp_project_id
  region  = var.region

  default_labels = {
    environment = var.envname
    team        = "ai-coe"
    managed_by  = "terraform"
    project     = var.project_name
  }
}
