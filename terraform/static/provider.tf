provider "google" {
  project     = "${var.project}-${var.envname}"
  region      = var.region # Choose the appropriate region for your bucket

  default_labels = {
    environment = var.envname
    managed_by = "terraform"
  }
}

provider "google-beta" {
  project     = "${var.project}-${var.envname}"
  region      = var.region # Choose the appropriate region for your bucket

  default_labels = {
    environment = var.envname
    managed_by = "terraform"
  }
}