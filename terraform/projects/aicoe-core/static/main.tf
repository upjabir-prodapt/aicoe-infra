module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  envname           = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
}

module "identities" {
  source = "../../../modules/static-identities"

  gcp_project_id  = local.gcp_project_id
  project         = var.project
  envname         = var.envname
  resource_prefix = local.resource_prefix
}

module "storage" {
  source = "../../../modules/static-storage"

  gcp_project_id       = local.gcp_project_id
  project              = var.project
  envname              = var.envname
  region               = var.region
  resource_prefix      = local.resource_prefix
  app_sa_email         = module.identities.aicoe_app_sa_email
  enable_kms           = true
  enable_workbench_kms = true
}

module "artifact" {
  source = "../../../modules/static-artifact"

  gcp_project_id            = local.gcp_project_id
  envname                   = var.envname
  region                    = var.region
  resource_prefix           = local.resource_prefix
  artifact_format           = var.artifact_format
  vector_search_bucket_name = module.storage.vector_search_bucket_name
  vertex_ai_service_agent   = "serviceAccount:${module.storage.vertex_ai_service_agent_email}"
}
