output "vector_search_index_id" {
  value       = element(split("/", google_vertex_ai_index.vector_search_index.id), length(split("/", google_vertex_ai_index.vector_search_index.id)) - 1)
  description = "Numeric Vertex AI index ID"
}

output "vector_search_index_endpoint_id" {
  value       = element(split("/", google_vertex_ai_index_endpoint.vector_index_endpoint.id), length(split("/", google_vertex_ai_index_endpoint.vector_index_endpoint.id)) - 1)
  description = "Numeric Vertex AI index endpoint ID"
}

output "vector_search_deployed_index_id" {
  value       = local.vector_search_deployed_index_id
  description = "Deployed index string ID"
}

output "vector_search_service_attachment_uri" {
  value       = local.vector_search_service_attachment
  description = "PSC service attachment URI"
}
