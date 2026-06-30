resource "google_firestore_database" "firestore" {
  project         = var.gcp_project_id
  name            = var.firestore_name
  location_id     = var.region
  type            = "FIRESTORE_NATIVE"
  deletion_policy = "ABANDON"
}
