resource "google_artifact_registry_repository" "repository" {
  project       = var.gcp_project_id
  location      = var.region
  repository_id = "${var.resource_prefix}-${var.artifact_format}-repo"
  format        = var.artifact_format

  labels = var.labels

  docker_config {
    immutable_tags = true
  }
}

resource "google_storage_bucket_iam_member" "bucket_iam_members" {
  for_each = var.bucket_iam_members

  bucket = each.value.bucket
  role   = each.value.role
  member = each.value.member
}
