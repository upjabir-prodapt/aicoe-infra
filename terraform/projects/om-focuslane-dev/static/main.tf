###########################################
### GCP APIs & Services Enable          ###
###########################################
module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required

  # om-focus-lane never had audit-log config - keep that off. There's no
  # flag on this module to skip the "environment" resource tag though, so
  # unlike audit_services this WILL get created (key + value + project
  # binding) the first time this applies - a real, intentional new
  # resource, not a side effect of a 0-diff migration. Revisit if/when
  # static-base gets an enable_env_tag flag.
  audit_services = []
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

# NOTE: modules/static-storage deliberately NOT used here. It force-adds a
# Vertex AI service-agent KMS grant the moment enable_kms is true, with no
# flag to turn that binding off, and the original key never had any IAM
# bindings. Kept as plain resources in cloud_kms.tf. Revisit once
# static-storage gets a bind_vertex_sa_to_bucket_key-style flag, or once
# buckets are actually introduced (bucket_suffixes is empty today anyway -
# see buckets.tf, still fully commented out).

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
 