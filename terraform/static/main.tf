module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
}

module "identities" {
  source = "../../../modules/static-identities"

  gcp_project_id = local.gcp_project_id
  service_accounts = {
    app = {
      account_id   = "${local.resource_prefix}-app-sa"
      display_name = "Service Account for Application WIF"
      roles = [
        "roles/aiplatform.admin",
        "roles/aiplatform.user",
        "roles/storage.admin",
        "roles/bigquery.dataEditor",
        "roles/bigquery.jobUser",
        "roles/run.admin",
        "roles/cloudtrace.agent",
        "roles/iap.httpsResourceAccessor",
        "roles/secretmanager.secretAccessor",
      ]
    }
    ui = {
      account_id   = "${local.resource_prefix}-ui-sa"
      display_name = "Service Account for UI"
      roles = [
        "roles/run.invoker",
      ]
      # NOTE: this reproduces the existing dev behaviour exactly - the
      # "ui" role binding is actually granted to the "app" service account
      # (google_project_iam_member.aicoe_ui_sa_iam in the old code binds to
      # aicoe_app_sa.email, not aicoe_ui_sa.email). Change this to "ui" if
      # that was a bug you want fixed - doing so will show as a plan change.
      grant_roles_to_account_key = "app"
    }
  }
}

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id       = local.gcp_project_id
  region                = var.region
  resource_prefix       = local.resource_prefix
  app_sa_email          = module.identities.service_account_emails["app"]
  enable_kms            = true
  enable_workbench_kms  = true
  bucket_suffixes = [
    "vx-app-001",
    "vxai-bs",
    "vxai-translation-app-001",
    "vxai-sales-app-001",
    "vector-search",
  ]
  bucket_kms_key_ring_name_suffix    = "app-bucket-key-ring"
  bucket_kms_key_name_suffix         = "app-bucket-key"
  workbench_kms_key_ring_name_suffix = "vxai-wkb-key-ring"
  workbench_kms_key_name_suffix      = "vxai-wkb-key"
  labels                              = local.default_labels
}

module "artifact" {
  source = "../../../modules/static-artifact"

  gcp_project_id  = local.gcp_project_id
  region          = var.region
  resource_prefix = local.resource_prefix
  artifact_format = var.artifact_format
  labels          = local.default_labels
  bucket_iam_members = {
    vector_search_vertex_ai = {
      bucket = module.storage.bucket_names["vector-search"]
      role   = "roles/storage.objectViewer"
      member = "serviceAccount:${module.storage.vertex_ai_service_agent_email}"
    }
  }
}
 