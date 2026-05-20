#Vertex AI Index
import {
  id = "projects/${var.project}${var.envname}/locations/${var.region}/indexes/2132951402815684608"
  to = google_vertex_ai_index.aicoe_vector_search_index
}
resource "google_vertex_ai_index" "aicoe_vector_search_index" {
  region = var.region
  project = "${var.project}${var.envname}"
  display_name = "${var.project}${var.envname}_salesagent_index"

  metadata {
    config{
        dimensions = 768
        approximate_neighbors_count = 10
        distance_measure_type = "DOT_PRODUCT_DISTANCE"

        algorithm_config{
            tree_ah_config{
                leaf_node_embedding_count = 1000
                leaf_nodes_to_search_percent = 5
            }
        }
    }
  }
  index_update_method = "BATCH_UPDATE"
   lifecycle {
    prevent_destroy = true
    ignore_changes = [ metadata ]
  }

}

#Vertex AI Index Endpoint
import {
  id = "projects/${var.project}${var.envname}/locations/${var.region}/indexEndpoints/4078260151235117056"
  to = google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint
}
# data "google_project" "project" {
#     project_id = "${var.project}${var.envname}"
# }
resource "google_vertex_ai_index_endpoint" "aicoe_vector_index_endpoint" {
  region = var.region
  project = "${var.project}${var.envname}"
  display_name = "${var.project}${var.envname}-salesagent-endpoint"
  description = "PSC-enabled index endpoint"

#   network = data.terraform_remote_state.network.outputs.aicoe_network
   # network = "projects/${data.google_project.project.number}/global/networks/${var.project}${var.envname}-vpc"
  private_service_connect_config {
    enable_private_service_connect = true
    project_allowlist = ["${var.project}${var.envname}"]
  }
   lifecycle {
    prevent_destroy = true
  }
  depends_on = [  
    google_vertex_ai_index.aicoe_vector_search_index
   ]
}

#Deployed Vector Search Index
import {
  id = "projects/${var.project}${var.envname}/locations/${var.region}/indexEndpoints/4078260151235117056/deployedIndex/aicoesandox_salesagent_index"
  to = google_vertex_ai_index_endpoint_deployed_index.aicoe_vector_deployed_index
}
resource "google_vertex_ai_index_endpoint_deployed_index" "aicoe_vector_deployed_index" {
  index_endpoint = google_vertex_ai_index_endpoint.aicoe_vector_index_endpoint.id
  index = google_vertex_ai_index.aicoe_vector_search_index.id
  deployed_index_id = "aicoesandox_salesagent_index"
  display_name = "AICOE salesagent Deployed Index"
  
  automatic_resources {
    min_replica_count = 1
    max_replica_count = 1
    }
  
  lifecycle {
    prevent_destroy = true
    ignore_changes = [ automatic_resources, display_name ]
  }
}
