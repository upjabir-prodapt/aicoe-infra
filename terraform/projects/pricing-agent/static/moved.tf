# State migration from pre-module layout to modular layout.

moved {
  from = google_tags_tag_key.env
  to   = module.base.google_tags_tag_key.env
}

moved {
  from = google_tags_tag_value.env
  to   = module.base.google_tags_tag_value.env
}

moved {
  from = google_tags_tag_binding.env_project
  to   = module.base.google_tags_tag_binding.env_project
}

moved {
  from = google_project_service.service
  to   = module.base.google_project_service.service
}

moved {
  from = google_project_iam_audit_config.data_access
  to   = module.base.google_project_iam_audit_config.data_access
}

moved {
  from = google_kms_key_ring.aicoe_app_bucket_key_ring
  to   = module.storage.google_kms_key_ring.bucket_key_ring[0]
}

moved {
  from = google_kms_crypto_key.aicoe_app_bucket_key
  to   = module.storage.google_kms_crypto_key.bucket_key[0]
}

moved {
  from = google_storage_bucket.aicoe_app_bucket
  to   = module.storage.google_storage_bucket.buckets["billing-bucket"]
}
