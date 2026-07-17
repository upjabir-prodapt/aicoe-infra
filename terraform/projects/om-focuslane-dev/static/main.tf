###########################################
### GCP APIs & Services Enable          ###
###########################################
# NOTE: modules/static-base also unconditionally creates a
# google_project_iam_audit_config (storage/aiplatform/bigquery DATA_READ +
# DATA_WRITE logging) and a "environment" resource tag (key + value +
# binding on the project). Neither of those exist in om-focus-lane's
# current state - this is a genuine, intentional addition that comes
# bundled with the module (same shape aicoedev already carries), not a
# side effect of a pure refactor. Review/confirm before applying.
module "base" {
  source = "../../../modules/static-base"

  gcp_project_id    = local.gcp_project_id
  environment_name  = var.envname
  project_number    = var.project_number
  gcp_apis_required = var.gcp_apis_required
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

# NOTE: modules/static-storage was deliberately NOT used here. om-focus-lane's
# KMS keyring/key in cloud_kms.tf don't back any bucket today (buckets.tf is
# fully commented out), but static-storage unconditionally grants the
# Vertex AI service agent encrypt/decrypt on the key the moment enable_kms
# is true, with no flag to turn that binding off. Adopting the module here
# would silently add a new IAM grant that isn't in current state. Kept as
# plain resources in cloud_kms.tf until buckets are actually introduced -
# at that point use modules/static-storage the way aicoedev/static does.
