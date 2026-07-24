output "aicoe_app_bucket_key_id" {
  value = module.storage.bucket_key_id
}

output "aicoe_app_sa_email" {
  value       = module.identities.service_account_emails["app"]
  description = "Application service account used by Cloud Run and vector search APIs"
}

output "aicoe_vertex_sa_email" {
  value       = module.identities.service_account_emails["vertex"]
  description = "Service account used by Vertex AI"
}
