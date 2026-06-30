resource "google_bigquery_dataset" "dataset" {
  dataset_id                 = "${var.resource_prefix}_${var.dataset_id_suffix}"
  location                   = var.region
  project                    = var.gcp_project_id
  delete_contents_on_destroy = true

  labels = var.labels
}
