provider "google" {
  project     = "${var.project}"
  region      = var.region # Choose the appropriate region for your bucket
}

provider "google-beta" {
  project     = "${var.project}"
  region      = var.region # Choose the appropriate region for your bucket
}
