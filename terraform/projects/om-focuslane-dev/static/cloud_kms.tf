###########################################
###  Cloud KMS for AICOE Bucket ###########
###########################################
# Kept as plain resources - see the NOTE in main.tf: modules/static-storage
# would force-add a Vertex AI service-agent KMS grant that doesn't exist
# in current state, and this key doesn't back any bucket yet anyway.

# Keyring

resource "google_kms_key_ring" "aicoe_app_bucket_key_ring" {
  name     = "${local.resource_prefix}-app-bucket-key-ring"
  location = var.region
  project  = local.gcp_project_id
}

# Key

resource "google_kms_crypto_key" "aicoe_app_bucket_key" {
  name            = "${local.resource_prefix}-app-bucket-key"
  key_ring        = google_kms_key_ring.aicoe_app_bucket_key_ring.id
  rotation_period = "1000000s"

  lifecycle {
    prevent_destroy = true
  }
  labels = local.default_labels

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}
