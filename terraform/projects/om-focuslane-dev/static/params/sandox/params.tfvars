# NOTE: the original sandox params.tfvars had project = "aicoe", which
# looks like a stale copy-paste from the aicoedev project (om-focus-lane's
# variables.tf/dev params both use "om-focus-lane"). Fixed here for
# consistency - double check against real sandox state before applying.
project = "om-focus-lane"
envname = "sandox"
region  = "europe-west1"

# TODO: replace with om-focus-lane's real GCP project number.
project_number = "REPLACE_ME_PROJECT_NUMBER"

gcp_apis_required = [
    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "bigquery.googleapis.com",                 # BigQuery API - datasets, tables, jobs
    "bigquerystorage.googleapis.com",          # BigQuery Storage API - fast read/write (used by Workbench)
    "run.googleapis.com",                      # Cloud Run API - deploy and manage containers
    "artifactregistry.googleapis.com",         # Artifact Registry - container images, packages
    "dns.googleapis.com",                      # Cloud DNS - DNS zones and records
    "secretmanager.googleapis.com",            # Secret Manager - store and manage secrets
    "cloudkms.googleapis.com",                 # Cloud KMS - encryption keys, CMEK
    "logging.googleapis.com",                  # Cloud Logging - log ingestion, sinks, routing
    "monitoring.googleapis.com",               # Cloud Monitoring - metrics, dashboards, alerts
    "serviceusage.googleapis.com",             # Service Usage API - enable/disable APIs
    "compute.googleapis.com",                  # Compute Engine API
    
]
artifact_format = "docker"
