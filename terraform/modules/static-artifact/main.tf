resource "google_artifact_registry_repository" "aicoe_artifact_repo" {
  project       = var.gcp_project_id
  location      = var.region
  repository_id = "${var.resource_prefix}-${var.artifact_format}-repo"
  format        = var.artifact_format

  labels = {
    env    = var.envname
    system = var.resource_prefix
  }

  docker_config {
    immutable_tags = true
  }
}

resource "google_storage_bucket_iam_member" "vector_search_vertex_sa" {
  count  = var.vector_search_bucket_name != "" && var.vertex_ai_service_agent != "" ? 1 : 0
  bucket = var.vector_search_bucket_name
  role   = "roles/storage.objectViewer"
  member = var.vertex_ai_service_agent
}
