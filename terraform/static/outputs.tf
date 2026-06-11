output "aicoe_app_bucket_key_id" {
  value = google_kms_crypto_key.aicoe_app_bucket_key.id
}

output "aicoe_app_sa_email" {
  value       = google_service_account.aicoe_app_sa.email
  description = "Application service account used by Cloud Run and vector search APIs"
}
