# State migration from pre-module layout to modular layout (om-focuslane-dev).
# Mirrors projects/ai-cmo-dev/static/moved.tf. Uncomment and run
# `terraform plan` (expect 0 add / 0 change / 0 destroy) before applying.
#
###moved {
###  from = google_project_service.service
###  to   = module.base.google_project_service.service
###}
###
###moved {
###  from = google_service_account.aicoe_app_sa
###  to   = module.identities.google_service_account.this["app"]
###}
###
###moved {
###  from = google_service_account.aicoe_vertex_sa
###  to   = module.identities.google_service_account.this["vertex"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/aiplatform.user"]
###  to   = module.identities.google_project_iam_member.this["app-roles/aiplatform.user"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/datastore.user"]
###  to   = module.identities.google_project_iam_member.this["app-roles/datastore.user"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/storage.admin"]
###  to   = module.identities.google_project_iam_member.this["app-roles/storage.admin"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.dataEditor"]
###  to   = module.identities.google_project_iam_member.this["app-roles/bigquery.dataEditor"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/bigquery.jobUser"]
###  to   = module.identities.google_project_iam_member.this["app-roles/bigquery.jobUser"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/run.admin"]
###  to   = module.identities.google_project_iam_member.this["app-roles/run.admin"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/cloudtrace.agent"]
###  to   = module.identities.google_project_iam_member.this["app-roles/cloudtrace.agent"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/iap.httpsResourceAccessor"]
###  to   = module.identities.google_project_iam_member.this["app-roles/iap.httpsResourceAccessor"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_app_sa_iam["roles/secretmanager.secretAccessor"]
###  to   = module.identities.google_project_iam_member.this["app-roles/secretmanager.secretAccessor"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/aiplatform.user"]
###  to   = module.identities.google_project_iam_member.this["vertex-roles/aiplatform.user"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/bigquery.dataViewer"]
###  to   = module.identities.google_project_iam_member.this["vertex-roles/bigquery.dataViewer"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/bigquery.jobUser"]
###  to   = module.identities.google_project_iam_member.this["vertex-roles/bigquery.jobUser"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/datastore.user"]
###  to   = module.identities.google_project_iam_member.this["vertex-roles/datastore.user"]
###}
###
###moved {
###  from = google_project_iam_member.aicoe_vertex_sa_iam["roles/storage.objectAdmin"]
###  to   = module.identities.google_project_iam_member.this["vertex-roles/storage.objectAdmin"]
###}
###
###moved {
###  from = google_kms_key_ring.aicoe_app_bucket_key_ring
###  to   = module.storage.google_kms_key_ring.bucket_key_ring[0]
###}
###
###moved {
###  from = google_kms_crypto_key.aicoe_app_bucket_key
###  to   = module.storage.google_kms_crypto_key.bucket_key[0]
###}
###
###moved {
###  from = google_artifact_registry_repository.aicoe_artifact_repo
###  to   = module.artifact.google_artifact_registry_repository.repository
###}
###
#### NOTE: google_project_iam_member.aicoe_app_sa_iam / aicoe_vertex_sa_iam
#### were for_each over toset([...]) in the old code, so their instance keys
#### ARE the role strings themselves (e.g. "roles/run.admin") - matches the
#### "from" addresses above.
###
#### NOTE: the google_secret_manager_secret.* resources in secrets.tf were
#### already fully commented out in the old code (nothing ever applied), so
#### there is nothing to move for them.
