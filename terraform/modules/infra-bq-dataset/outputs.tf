output "dataset_id" {
  value = google_bigquery_dataset.dataset.dataset_id
}

output "dataset_self_link" {
  value = google_bigquery_dataset.dataset.id
}
