output "aicoe_app_bucket_key_id" {
  value = google_kms_crypto_key.aicoe_app_bucket_key.id
}
output "aicoe_vxai_wkb_key_id" {
  value = try(google_kms_crypto_key.aicoe_vxai_wkb_key[0].id, null)
}

output "vector_search_bucket_name" {
  value       = google_storage_bucket.vector_search.name
  description = "GCS bucket for catalog embeddings and vector search artifacts"
}

output "aicoe_app_sa_email" {
  value       = google_service_account.aicoe_app_sa.email
  description = "Application service account used by Cloud Run and vector search APIs"
}

output "vertex_ai_service_agent_email" {
  value       = "service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
  description = "Google-managed Vertex AI service agent that ingests embeddings from GCS"
}