#Vertex AI Index
resource "google_vertex_ai_index" "vector_search" {
  region = var.region
  project = "${var.project}${var.envname}"
  display_name = "${var.project}${var.envname}_vertexai_index"

  metadata {
    config{
        dimensions = 768
        approximate_neighbors_count = 10
        distance_measure_type = "DOT_PRODUCT_DISTANCE"

        algorithm_config{
            tree_ah_config{
                leaf_node_embedding_count = 500
                leaf_nodes_to_search_percent = 7
            }
        }
    }
  }
  index_update_method = "BATCH_UPDATE"

}

#Vertex AI Index Endpoint
data "google_project" "project" {
    project_id = "${var.project}${var.envname}"
}

resource "google_vertex_ai_index_endpoint" "vector_search" {
  region = var.region
  project = "${var.project}${var.envname}"
  display_name = "${var.project}${var.envname}_vertexai_endpoint"
  description = "Endpoint for Vertex AI Index"

#   network = data.terraform_remote_state.network.outputs.aicoe_network
    network = "projects/${data.google_poject.project.number}/global/networks/${var.project}${var.envname}-vpc)"

  depends_on = [  
    google_vertex_ai_index.vector_search
   ]
}