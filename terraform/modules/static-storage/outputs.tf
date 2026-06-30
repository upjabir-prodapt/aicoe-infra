output "bucket_key_id" {
  value = try(google_kms_crypto_key.bucket_key[0].id, null)
}

output "workbench_key_id" {
  value = try(google_kms_crypto_key.workbench_key[0].id, null)
}

output "vertex_ai_service_agent_email" {
  value       = "service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
  description = "Google-managed Vertex AI service agent"
}

output "bucket_names" {
  value = { for k, v in google_storage_bucket.buckets : k => v.name }
}
