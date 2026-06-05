data "google_project" "current" {
  project_id = "${var.project}${var.envname}"
}

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
