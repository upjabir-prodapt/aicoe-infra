# NOTE: no shared module exists yet for Firestore (none of
# modules/infra-* cover it), so this stays a plain resource. Add
# modules/infra-firestore if/when a second project needs one.
resource "google_firestore_database" "om_focus_lane_firestore" {
  project     = local.gcp_project_id
  name        = "om-focus-lane-firestore"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  deletion_policy = "ABANDON"
}
