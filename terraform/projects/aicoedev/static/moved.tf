moved {
  from = google_project_service.service
  to   = module.base.google_project_service.service
}

moved {
  from = google_project_iam_audit_config.data_access
  to   = module.base.google_project_iam_audit_config.data_access
}

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
  from = google_service_account.aicoe_app_sa
  to   = module.identities.google_service_account.this["app"]
}

moved {
  from = google_service_account.aicoe_ui_sa
  to   = module.identities.google_service_account.this["ui"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/aiplatform.admin"]
  to   = module.identities.google_project_iam_member.this["app-roles/aiplatform.admin"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/aiplatform.user"]
  to   = module.identities.google_project_iam_member.this["app-roles/aiplatform.user"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/storage.admin"]
  to   = module.identities.google_project_iam_member.this["app-roles/storage.admin"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.dataEditor"]
  to   = module.identities.google_project_iam_member.this["app-roles/bigquery.dataEditor"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.jobUser"]
  to   = module.identities.google_project_iam_member.this["app-roles/bigquery.jobUser"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/run.admin"]
  to   = module.identities.google_project_iam_member.this["app-roles/run.admin"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/cloudtrace.agent"]
  to   = module.identities.google_project_iam_member.this["app-roles/cloudtrace.agent"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/iap.httpsResourceAccessor"]
  to   = module.identities.google_project_iam_member.this["app-roles/iap.httpsResourceAccessor"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/secretmanager.secretAccessor"]
  to   = module.identities.google_project_iam_member.this["app-roles/secretmanager.secretAccessor"]
}

moved {
  from = google_project_iam_member.aicoe_ui_sa_iam["roles/run.invoker"]
  to   = module.identities.google_project_iam_member.this["ui-roles/run.invoker"]
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
  from = google_kms_key_ring.aicoe_vxai_wkb_key_ring
  to   = module.storage.google_kms_key_ring.workbench_key_ring[0]
}

moved {
  from = google_kms_crypto_key.aicoe_vxai_wkb_key
  to   = module.storage.google_kms_crypto_key.workbench_key[0]
}

moved {
  from = google_kms_crypto_key_iam_member.app_sa_bucket_key
  to   = module.storage.google_kms_crypto_key_iam_member.app_sa_bucket_key[0]
}

moved {
  from = google_kms_crypto_key_iam_member.vertex_sa_bucket_key
  to   = module.storage.google_kms_crypto_key_iam_member.vertex_sa_bucket_key[0]
}

moved {
  from = google_storage_bucket.aicoe_app_bucket
  to   = module.storage.google_storage_bucket.buckets["vx-app-001"]
}

moved {
  from = google_storage_bucket.aicoe_vxai_bs_bucket
  to   = module.storage.google_storage_bucket.buckets["vxai-bs"]
}

moved {
  from = google_storage_bucket.aicoe_trans_app_bucket
  to   = module.storage.google_storage_bucket.buckets["vxai-translation-app-001"]
}

moved {
  from = google_storage_bucket.aicoe_sales_app_bucket
  to   = module.storage.google_storage_bucket.buckets["vxai-sales-app-001"]
}

moved {
  from = google_storage_bucket.vector_search
  to   = module.storage.google_storage_bucket.buckets["vector-search"]
}

moved {
  from = google_storage_bucket_iam_member.vector_search_vertex_sa
  to   = module.artifact.google_storage_bucket_iam_member.bucket_iam_members["vector_search_vertex_ai"]
}

moved {
  from = google_artifact_registry_repository.aicoe_artifact_repo
  to   = module.artifact.google_artifact_registry_repository.repository
}