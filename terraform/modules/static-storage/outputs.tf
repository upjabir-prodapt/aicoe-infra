output "aicoe_app_bucket_key_id" {
  value = try(google_kms_crypto_key.aicoe_app_bucket_key[0].id, null)
}

output "aicoe_vxai_wkb_key_id" {
  value = try(google_kms_crypto_key.aicoe_vxai_wkb_key[0].id, null)
}

output "vector_search_bucket_name" {
  value       = try(google_storage_bucket.buckets["vector-search"].name, null)
  description = "GCS bucket for catalog embeddings and vector search artifacts"
}

output "vertex_ai_service_agent_email" {
  value       = "service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
  description = "Google-managed Vertex AI service agent"
}

output "bucket_names" {
  value = { for k, v in google_storage_bucket.buckets : k => v.name }
}
