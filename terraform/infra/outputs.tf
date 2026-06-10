# output "vector_search_index_id" {
#   value       = element(split("/", google_vertex_ai_index.aicoe_vector_search_index.id), length(split("/", google_vertex_ai_index.aicoe_vector_search_index.id)) - 1)
#   description = "Numeric Vertex AI index ID for VECTOR_SEARCH_INDEX_ID in sales-agent-service-env"
# }

# output "vector_search_index_endpoint_id" {
#   value       = element(split("/", google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint.id), length(split("/", google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint.id)) - 1)
#   description = "Numeric Vertex AI index endpoint ID for VECTOR_SEARCH_INDEX_ENDPOINT_ID in sales-agent-service-env"
# }

# output "vector_search_deployed_index_id" {
#   value       = local.vector_search_deployed_index_id
#   description = "Deployed index string ID for VECTOR_SEARCH_DEPLOYED_INDEX_ID in sales-agent-service-env"
# }

# output "vector_search_service_attachment_uri" {
#   value       = local.vector_search_service_attachment
#   description = "PSC service attachment URI used by the vector index forwarding rule"
# }

###########################################
###       Infra                         ###
###########################################

output "vector_search_service_attachment" {
  value       = try(
    "https://www.googleapis.com/compute/v1/${google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index.private_endpoints[0].service_attachment}",
    null
    )
}