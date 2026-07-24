module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required

  # om-focus-lane never had audit-log config or the org env tag resources -
  # keep both off so this migration is a true 0-diff moved{} exercise.
  audit_services  = []
  enable_env_tag  = false
}

module "identities" {
  source = "../../../modules/static-identities"

  gcp_project_id = local.gcp_project_id
  service_accounts = {
    app = {
      account_id   = "${local.resource_prefix}-app-sa"
      display_name = "Service Account for Application WIF"
      roles = [
        "roles/aiplatform.user",
        "roles/datastore.user",
        "roles/storage.admin",
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/run.admin",
        "roles/cloudtrace.agent",
        "roles/iap.httpsResourceAccessor",
        "roles/secretmanager.secretAccessor",
      ]
    }
    vertex = {
      account_id   = "${local.resource_prefix}-vertex-sa"
      display_name = "Service Account for Vertex AI"
      roles = [
        "roles/aiplatform.user",
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
        "roles/datastore.user",
        "roles/storage.objectAdmin",
      ]
    }
  }
}

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id = local.gcp_project_id
  region         = var.region
  resource_prefix = local.resource_prefix

  # KMS key ring/key only - no buckets exist yet in dev today (they're all
  # still commented out in the old code, see buckets.tf.disabled note below).
  enable_kms           = true
  enable_workbench_kms = false
  bucket_suffixes      = []

  bucket_kms_key_ring_name_suffix = "app-bucket-key-ring"
  bucket_kms_key_name_suffix      = "app-bucket-key"

  # Original key had no IAM bindings at all - keep it that way.
  app_sa_email                 = ""
  bind_vertex_sa_to_bucket_key = false

  labels = local.default_labels
}

module "artifact" {
  source = "../../../modules/static-artifact"

  gcp_project_id  = local.gcp_project_id
  region          = var.region
  resource_prefix = local.resource_prefix
  artifact_format = var.artifact_format
  labels          = local.default_labels
}
