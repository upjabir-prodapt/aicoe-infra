resource "google_firestore_database" "om_focus_lane_firestore" {
    project       = "${var.project}"
    name          = "om-focus-lane-firestore"
    location_id      = var.region
    type          = "FIRESTORE_NATIVE"

    deletion_policy = "ABANDON"

}
