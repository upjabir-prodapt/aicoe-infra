resource "google_service_account" "aicoe_app_sa" {
  account_id   = "${var.resource_prefix}-app-sa"
  display_name = "Service Account for Application"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "aicoe_app_sa_iam" {
  for_each = toset([
    "roles/aiplatform.admin",
    "roles/aiplatform.user",
    "roles/storage.admin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/run.admin",
    "roles/cloudtrace.agent",
    "roles/iap.httpsResourceAccessor",
    "roles/secretmanager.secretAccessor",
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}

resource "google_service_account" "aicoe_ui_sa" {
  account_id   = "${var.resource_prefix}-ui-sa"
  display_name = "Service Account for UI"
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "aicoe_ui_sa_iam" {
  for_each = toset([
    "roles/run.invoker",
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}
