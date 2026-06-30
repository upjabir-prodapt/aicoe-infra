output "service_account_emails" {
  value       = { for key, sa in google_service_account.this : key => sa.email }
  description = "Map of service account keys to email addresses"
}
