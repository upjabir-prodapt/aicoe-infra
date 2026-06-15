provider "google" {
  project     = "${var.project}-${var.envname}-${var.project_num}}"
  region      = var.region # Choose the appropriate region for your bucket
}

provider "google-beta" {
  project     = "${var.project}-${var.envname}-${var.project_num}"
  region      = var.region # Choose the appropriate region for your bucket
}
