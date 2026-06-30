locals {
  vector_search_deployed_index_id = var.deployed_index_id
  psc_project_allowlist           = length(var.psc_project_allowlist) > 0 ? var.psc_project_allowlist : [var.resource_prefix]
}

resource "google_vertex_ai_index" "vector_search_index" {
  region       = var.region
  project      = var.gcp_project_id
  display_name = var.index_display_name
  labels       = var.labels

  metadata {
    config {
      dimensions                  = var.dimensions
      approximate_neighbors_count = var.approximate_neighbors_count
      distance_measure_type       = var.distance_measure_type

      algorithm_config {
        tree_ah_config {
          leaf_node_embedding_count    = var.leaf_node_embedding_count
          leaf_nodes_to_search_percent = var.leaf_nodes_to_search_percent
        }
      }
    }
  }

  index_update_method = "BATCH_UPDATE"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [metadata]
  }
}

resource "google_vertex_ai_index_endpoint" "vector_index_endpoint" {
  region       = var.region
  project      = var.gcp_project_id
  display_name = var.endpoint_display_name
  description  = "PSC-enabled index endpoint"
  labels       = var.labels

  private_service_connect_config {
    enable_private_service_connect = true
    project_allowlist              = local.psc_project_allowlist
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_vertex_ai_index.vector_search_index,
  ]
}

resource "google_vertex_ai_index_endpoint_deployed_index" "vector_deployed_index" {
  index_endpoint    = google_vertex_ai_index_endpoint.vector_index_endpoint.id
  index             = google_vertex_ai_index.vector_search_index.id
  deployed_index_id = local.vector_search_deployed_index_id
  display_name      = var.deployed_index_display_name

  automatic_resources {
    min_replica_count = var.min_replica_count
    max_replica_count = var.max_replica_count
  }

  lifecycle {
    ignore_changes = [automatic_resources, dedicated_resources]
  }
}
