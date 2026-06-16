resource "google_service_account" "aicoe_app_sa" {
  account_id   = "${var.project}-${var.envname}-app-sa"
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
  project = "${var.project}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}

# Vertex AI Service Account
resource "google_service_account" "aicoe_vertex_sa" {
  account_id   = "${var.project}-${var.envname}-vertex-sa"
  display_name = "Service Account for Vertex AI"
}
resource "google_project_iam_member" "aicoe_vertex_sa_iam" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/bigquery.dataViewer",
    "roles/bigquery.jobUser",
    "roles/datastore.user",
    "roles/storage.objectAdmin",
  ])
  project = "${var.project}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_vertex_sa.email}"
}

# Need to add binding for Vertex AI SA for Cross project Bigquery access
