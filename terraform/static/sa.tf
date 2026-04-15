resource "google_service_account" "aicoe_app_wif_sa" {
  account_id   = "${var.project}${var.region}-app-wif-sa"
  display_name = "Service Account for Application WIF"
}

resource "google_project_iam_member" "aicoe_app_wif_sa_iam" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/serviceusage.serviceUsageConsumer",
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountUser",

  ])
  project = "${var.project}${var.envname}"
  role    = each.value
  member  = "serviceAccount:${google_service_account.aicoe_app_wif_sa.email}"
}
 
resource "google_service_account_iam_binding" "aicoe_app_wif_sa_iam_binding" {
  for_each = toset([
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.aiplatform.user",

  ])
  service_account_id = google_service_account.aicoe_app_wif_sa.name
  role = each.value
   members = [
    "principalSet://iam.googleapis.com/projects/297743845367/locations/global/workloadIdentityPools/aicoesandox-ado-wip/*"
  ]
}

