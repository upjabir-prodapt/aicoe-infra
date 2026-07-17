project_name   = "aicoedev"
project        = "aicoe"
envname        = "dev"
region         = "europe-west1"
project_number = "1034474201742"
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
    "dlp.googleapis.com",                      # DLP API
    "privilegedaccessmanager.googleapis.com"   #PAM API
    "binaryauthorization.googleapis.com"       #Binary Authorization API
 
]
artifact_format = "docker"
pam_enabled = false
 
 