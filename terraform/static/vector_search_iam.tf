resource "google_storage_bucket_iam_member" "vector_search_vertex_sa" {
  bucket = google_storage_bucket.vector_search.name
  role   = "roles/storage.objectViewer"
  member = local.vertex_ai_service_agent
}
