project        = "ai-cmo-dev"
envname        = "dev"
region         = "europe-west1"
project_number = "32658888279"
gcp_apis_required = [
 
    "aiplatform.googleapis.com",               # Vertex AI API - models, endpoints, pipelines, training
    "notebooks.googleapis.com",                # Vertex AI Workbench - managed notebook instances
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
    "iamcredentials.googleapis.com",           # IAM API
    "cloudresourcemanager.googleapis.com",     # Cloud Resource Manager API 
    "iam.googleapis.com",                      #IAM API
    "storage.googleapis.com",                  #GCS API
  
]
artifact_format = "docker"
 