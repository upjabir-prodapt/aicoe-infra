resource "google_bigquery_dataset" "aicoe_translation_dataset" {
  dataset_id               = "${var.project}${var.envname}_translation_dataset"
  location                 = var.region
  project                  = "${var.project}${var.envname}"

  # Optional safety flag: defaults to false if not set
  delete_contents_on_destroy = true

  labels = {
      env    = var.envname
      system = "${var.project}${var.envname}"
    }
}
