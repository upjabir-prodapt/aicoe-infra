output "bucket_key_id" {
  value = module.storage.bucket_key_id
}

output "workbench_key_id" {
  value = module.storage.workbench_key_id
}

output "vector_search_bucket_name" {
  value = module.storage.bucket_names["vector-search"]
}

output "app_service_account_email" {
  value = module.identities.service_account_emails["app"]
}

output "vertex_ai_service_agent_email" {
  value = module.storage.vertex_ai_service_agent_email
}

output "env_tag_value_id" {
  value = module.base.env_tag_value_id
}
