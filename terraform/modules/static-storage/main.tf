data "google_project" "current" {
  project_id = var.gcp_project_id
}

locals {
  vertex_ai_service_agent = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-aiplatform.iam.gserviceaccount.com"
}

resource "google_kms_key_ring" "bucket_key_ring" {
  count    = var.enable_kms ? 1 : 0
  name     = "${var.resource_prefix}-${var.bucket_kms_key_ring_name_suffix}"
  location = var.region
  project  = var.gcp_project_id
}

resource "google_kms_crypto_key" "bucket_key" {
  count           = var.enable_kms ? 1 : 0
  name            = "${var.resource_prefix}-${var.bucket_kms_key_name_suffix}"
  key_ring        = google_kms_key_ring.bucket_key_ring[0].id
  rotation_period = "1000000s"

  lifecycle {
    prevent_destroy = true
  }

  labels = var.labels

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}


resource "google_storage_bucket" "buckets" {
  for_each                    = toset(var.bucket_suffixes)
  name                        = "${var.resource_prefix}-${each.value}"
  location                    = var.region
  project                     = var.gcp_project_id
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  dynamic "encryption" {
    for_each = var.enable_kms ? [1] : []
    content {
      default_kms_key_name = google_kms_crypto_key.bucket_key[0].id
    }
  }
 
  labels = var.labels

  lifecycle {
    ignore_changes = [ 
      encryption[0].customer_managed_encryption_enforcement_config,
      encryption[0].customer_supplied_encryption_enforcement_config,
      encryption[0].google_managed_encryption_enforcement_config,
     ]
  }
}

resource "google_kms_crypto_key_iam_member" "app_sa_bucket_key" {
  count         = var.enable_kms && var.app_sa_email != "" ? 1 : 0
  crypto_key_id = google_kms_crypto_key.bucket_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${var.app_sa_email}"
}

resource "google_kms_crypto_key_iam_member" "vertex_sa_bucket_key" {
  count         = var.enable_kms ? 1 : 0
  crypto_key_id = google_kms_crypto_key.bucket_key[0].id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = local.vertex_ai_service_agent
}
