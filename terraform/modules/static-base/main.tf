###resource "google_project_service" "service" {
###  count              = length(var.gcp_apis_required)
###  project            = var.gcp_project_id
###  service            = element(var.gcp_apis_required, count.index)
###  disable_on_destroy = false
###
###  lifecycle {
###    ignore_changes = [deletion_policy]
###  }
###}
###resource "google_project_iam_audit_config" "data_access" {
###  for_each = toset(var.audit_services)
###  project  = var.gcp_project_id
###  service  = each.value
###
###  /*audit_log_config {
###    log_type = "ADMIN_READ"
###  }
###*/
###  audit_log_config {
###    log_type = "DATA_READ"
###  }
###
###  audit_log_config {
###    log_type = "DATA_WRITE"
###  }
###}
###
###resource "google_tags_tag_key" "env" {
###  parent     = "projects/${var.gcp_project_id}"
###  short_name = "environment"
###}
###
###resource "google_tags_tag_value" "env" {
###  parent     = google_tags_tag_key.env.id
###  short_name = var.environment_name
###}
###
###resource "google_tags_tag_binding" "env_project" {
###  parent    = "//cloudresourcemanager.googleapis.com/projects/${var.project_number}"
###  tag_value = google_tags_tag_value.env.id
###}
###


resource "google_project_service" "service" {
  count              = length(var.gcp_apis_required)
  project            = var.gcp_project_id
  service            = element(var.gcp_apis_required, count.index)
  disable_on_destroy = false

  lifecycle {
    ignore_changes = [deletion_policy]
  }
}

###resource "google_project_iam_audit_config" "data_access" {
###  for_each = toset([
###    "storage.googleapis.com",
###    "aiplatform.googleapis.com",
###    "bigquery.googleapis.com",
###  ])
###  project = var.gcp_project_id
###  service = each.value
###
###  /*audit_log_config {
###    log_type = "ADMIN_READ"
###  }
###*/
###  audit_log_config {
###    log_type = "DATA_READ"
###  }
###
###  audit_log_config {
###    log_type = "DATA_WRITE"
###  }
###}
resource "google_project_iam_audit_config" "data_access" {
  for_each = toset(var.audit_services)
  project  = var.gcp_project_id
  service  = each.value

  dynamic "audit_log_config" {
    for_each = var.audit_log_types
    content {
      log_type = audit_log_config.value
    }
  }
}

resource "google_tags_tag_key" "env" {
  parent     = "projects/${var.gcp_project_id}"
  short_name = "environment"
}

resource "google_tags_tag_value" "env" {
  parent     = google_tags_tag_key.env.id
  short_name = var.environment_name
}

resource "google_tags_tag_binding" "env_project" {
  parent    = coalesce(var.tag_binding_parent, "//cloudresourcemanager.googleapis.com/projects/${var.project_number}")
  tag_value = google_tags_tag_value.env.id
}
 