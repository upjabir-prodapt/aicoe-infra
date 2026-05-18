output "aicoe_app_bucket_key_id" {
  value = google_kms_crypto_key.aicoe_app_bucket_key.id
}
output "aicoe_vxai_wkb_key_id" {
  value = google_kms_crypto_key.aicoe_vxai_wkb_key.id
}