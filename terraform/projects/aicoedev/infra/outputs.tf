###########################################
###                Infra                ###
###########################################
output "vector_search_service_attachment" {
  value = module.vector_search.vector_search_service_attachment_uri
}

output "vector_search_index_id" {
  value = module.vector_search.vector_search_index_id
}

output "vector_search_index_endpoint_id" {
  value = module.vector_search.vector_search_index_endpoint_id
}

output "vector_search_deployed_index_id" {
  value = module.vector_search.vector_search_deployed_index_id
}