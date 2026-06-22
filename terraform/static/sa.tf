resource "google_service_account" "aicoe_app_sa" {
  account_id   = "${var.project}${var.envname}-app-sa"
  display_name = "Service Account for Application"
}

resource "google_project_iam_member" "aicoe_app_sa_iam" {
  for_each = toset([
    "roles/aiplatform.admin",
    "roles/aiplatform.user",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/run.admin" ,
    "roles/cloudtrace.agent" ,
    "roles/iap.httpsResourceAccessor" ,
    "roles/secretmanager.secretAccessor" ,


  ])
  project = "${var.project}${var.envname}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}

#Service account for UI service
resource "google_service_account" "aicoe_ui_sa" {
  account_id   = "${var.project}${var.envname}-ui-sa"
  display_name = "Service Account for UI"
}

resource "google_project_iam_member" "aicoe_ui_sa_iam" {
  for_each = toset([
    "roles/run.invoker",
  ])
  project = "${var.project}${var.envname}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}
 