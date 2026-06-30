output "aicoe_app_bucket_key_id" {
  value = module.storage.aicoe_app_bucket_key_id
}

output "aicoe_vxai_wkb_key_id" {
  value = module.storage.aicoe_vxai_wkb_key_id
}

output "vector_search_bucket_name" {
  value = module.storage.vector_search_bucket_name
}

output "aicoe_app_sa_email" {
  value = module.identities.aicoe_app_sa_email
}

output "vertex_ai_service_agent_email" {
  value = module.storage.vertex_ai_service_agent_email
}

output "env_tag_value_id" {
  value = module.base.env_tag_value_id
}
