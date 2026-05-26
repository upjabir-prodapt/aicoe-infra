resource "google_bigquery_dataset" "svcmgmt_dataset" {
  dataset_id               = "${var.project}_${var.envname}_dataset"
  location                 = var.region
  project                  = "${var.project}-${var.envname}"

  # Optional safety flag: defaults to false if not set
  delete_contents_on_destroy = true

  labels = {
      env    = var.envname
      system = "${var.project}-${var.envname}"
    }
}



