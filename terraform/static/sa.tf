resource "google_service_account" "aicoe_app_sa" {
  account_id   = "${var.project}-${var.envname}"
  display_name = "Service Account for Application WIF"
}

resource "google_project_iam_member" "aicoe_app_sa_iam" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/datastore.user",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/run.admin" ,
    "roles/cloudtrace.agent" ,
    "roles/iap.httpsResourceAccessor" ,
    "roles/secretmanager.secretAccessor" ,

  ])
  project = "${var.project}-${var.envname}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}
