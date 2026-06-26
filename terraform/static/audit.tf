resource "google_project_iam_audit_config" "data_access" {
   for_each = toset([
       "aiplatform.googleapis.com",
   ])
   project       = "${var.project}"
   service       = each.value
   audit_log_config {
     log_type = "ADMIN_READ"
   }
   audit_log_config {
     log_type = "DATA_READ"
   }
   audit_log_config {
     log_type = "DATA_WRITE"
   }
}