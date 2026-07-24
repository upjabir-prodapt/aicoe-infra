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
  }
  depends_on = [module.base]
}

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id       = local.gcp_project_id
  region                = var.region
  resource_prefix       = local.resource_prefix
  app_sa_email          = module.identities.service_account_emails["app"]
  enable_kms            = true
  bucket_suffixes = [
    "vxai-bs",
    "vxai-sales-app-001",
    "vector-search",
  ]
  bucket_kms_key_ring_name_suffix    = "app-bucket-key-ring"
  bucket_kms_key_name_suffix         = "app-bucket-key"

  labels                              = local.default_labels

  depends_on = [module.base]
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
  depends_on = [module.base]
}

module "group_iam" {
  source               = "../../../modules/static-group-iam"
  for_each             = var.group_access
  gcp_project_id       = local.gcp_project_id
  group_email          = each.key
  roles                = each.value
}
 