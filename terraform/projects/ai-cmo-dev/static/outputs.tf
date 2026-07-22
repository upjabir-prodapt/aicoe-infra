output "aicoe_app_bucket_key_id" {
  value = module.storage.bucket_key_id
}

output "vector_search_bucket_name" {
  value       = module.storage.bucket_names["vector-search"]
  description = "GCS bucket for catalog embeddings and vector search artifacts"
}

output "aicoe_app_sa_email" {
  value       = module.identities.service_account_emails["app"]
  description = "Application service account used by Cloud Run and vector search APIs"
}

output "vertex_ai_service_agent_email" {
  value       = module.storage.vertex_ai_service_agent_email
  description = "Google-managed Vertex AI service agent that ingests embeddings from GCS"
}
 