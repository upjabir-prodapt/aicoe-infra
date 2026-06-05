resource "google_service_account" "aicoe_app_sa" {
  account_id   = "${var.project}${var.envname}-app-sa"
  display_name = "Service Account for Application WIF"
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
 
# -----------------------------------------------------------------------------
# KMS IAM
# -----------------------------------------------------------------------------

data "google_project" "current" {
  project_id = "${var.project}${var.envname}"
}

# resource "google_project_service_identity" "vertex_ai" {
#   provider = google-beta
#   project = "${var.project}${var.envname}"
#   service = "aiplatform.googleapis.com"
# }

locals {
  vertex_ai_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "app_sa_bucket_key" {
  crypto_key_id = google_kms_crypto_key.aicoe_app_bucket_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.aicoe_app_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "vertex_sa_bucket_key" {
  crypto_key_id = google_kms_crypto_key.aicoe_app_bucket_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.vertex_ai_service_agent
}

# -----------------------------------------------------------------------------
# Vector search IAM
# -----------------------------------------------------------------------------
resource "google_storage_bucket_iam_member" "vector_search_vertex_sa" {
  bucket = google_storage_bucket.vector_search.name
  role   = "roles/storage.objectViewer"
  member = local.vertex_ai_service_agent
}
