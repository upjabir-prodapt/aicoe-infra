# State migration from pre-module layout to modular layout (om-focus-lane).
#
# google_project_service.service was a `count` resource over
# var.gcp_apis_required (same list, same order, passed straight through to
# module.base below), so the instance keys (0, 1, 2...) line up exactly.

moved {
  from = google_project_service.service
  to   = module.base.google_project_service.service
}

moved {
  from = google_service_account.aicoe_app_sa
  to   = module.identities.google_service_account.sa["app"]
}

moved {
  from = google_service_account.aicoe_vertex_sa
  to   = module.identities.google_service_account.sa["vertex"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/aiplatform.user"]
  to   = module.identities.google_project_iam_member.iam["app-roles/aiplatform.user"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/datastore.user"]
  to   = module.identities.google_project_iam_member.iam["app-roles/datastore.user"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/storage.admin"]
  to   = module.identities.google_project_iam_member.iam["app-roles/storage.admin"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.dataEditor"]
  to   = module.identities.google_project_iam_member.iam["app-roles/bigquery.dataEditor"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.jobUser"]
  to   = module.identities.google_project_iam_member.iam["app-roles/bigquery.jobUser"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/run.admin"]
  to   = module.identities.google_project_iam_member.iam["app-roles/run.admin"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/cloudtrace.agent"]
  to   = module.identities.google_project_iam_member.iam["app-roles/cloudtrace.agent"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/iap.httpsResourceAccessor"]
  to   = module.identities.google_project_iam_member.iam["app-roles/iap.httpsResourceAccessor"]
}

moved {
  from = google_project_iam_member.aicoe_app_sa_iam["roles/secretmanager.secretAccessor"]
  to   = module.identities.google_project_iam_member.iam["app-roles/secretmanager.secretAccessor"]
}

moved {
  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/aiplatform.user"]
  to   = module.identities.google_project_iam_member.iam["vertex-roles/aiplatform.user"]
}

moved {
  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/bigquery.dataViewer"]
  to   = module.identities.google_project_iam_member.iam["vertex-roles/bigquery.dataViewer"]
}

moved {
  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/bigquery.jobUser"]
  to   = module.identities.google_project_iam_member.iam["vertex-roles/bigquery.jobUser"]
}

moved {
  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/datastore.user"]
  to   = module.identities.google_project_iam_member.iam["vertex-roles/datastore.user"]
}

moved {
  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/storage.objectAdmin"]
  to   = module.identities.google_project_iam_member.iam["vertex-roles/storage.objectAdmin"]
}

moved {
  from = google_artifact_registry_repository.aicoe_artifact_repo
  to   = module.artifact.google_artifact_registry_repository.repository
}

# NOT moved (kept as plain resources - see cloud_kms.tf comment for why):
#   google_kms_key_ring.aicoe_app_bucket_key_ring
#   google_kms_crypto_key.aicoe_app_bucket_key
#
# NOT moved (no shared module exists for Secret Manager yet, and every
# secret resource in secrets.tf is currently commented out / unused anyway):
#   google_secret_manager_secret.* (all, in secrets.tf)
 