###########################################
###  GCP APIs & Services Enable ###########
###########################################

resource "google_project_service" "service" {
  count              = length(var.gcp_apis_required)
  project            = "${var.project}"
  service            = element(var.gcp_apis_required, count.index)
  disable_on_destroy = false
  lifecycle {
    ignore_changes = [ deletion_policy ]
  }
}
