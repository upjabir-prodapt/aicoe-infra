output "aicoe_app_sa_email" {
  value       = google_service_account.aicoe_app_sa.email
  description = "Application service account used by Cloud Run and vector search APIs"
}

output "aicoe_ui_sa_email" {
  value = google_service_account.aicoe_ui_sa.email
}
