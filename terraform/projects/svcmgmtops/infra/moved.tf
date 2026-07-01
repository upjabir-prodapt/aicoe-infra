# State migration from pre-module layout to modular layout.

moved {
  from = google_bigquery_dataset.svcmgmt_dataset
  to   = module.bq_dataset.google_bigquery_dataset.dataset
}
