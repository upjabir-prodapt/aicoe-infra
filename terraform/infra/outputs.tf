###########################################
###       Infra                         ###
###########################################

output "vector_search_service_attachment" {
  value       = try(
    "https://www.googleapis.com/compute/v1/${google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index.private_endpoints[0].service_attachment}",
    null
    )
}