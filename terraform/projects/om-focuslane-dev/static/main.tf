###########################################
### GCP APIs & Services Enable          ###
###########################################
module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required

  # audit_services intentionally omitted - the module default
  # (storage/aiplatform/bigquery) matches what's already in state for
  # this project, so this is a 0-diff migration via the moved{} blocks
  # in moved.tf, not a new resource.
}

###########################################
### Service Accounts + project IAM      ###
###########################################
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


###########################################
### Artifact Registry                   ###
###########################################
module "artifact" {
  source = "../../../modules/static-artifact"

  gcp_project_id  = local.gcp_project_id
  region          = var.region
  resource_prefix = local.resource_prefix
  artifact_format = var.artifact_format
  labels          = local.default_labels
}