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