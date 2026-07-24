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

group_access = {
    "aicoesandox-view-members@colt.net" = [
    "roles/aiplatform.admin",              # Agent Platform Administrator - VERIFY exact role name
    "roles/bigquery.admin",                # BigQuery Admin
    "roles/cloudkms.admin",                # Cloud KMS Admin
    "roles/run.admin",                     # Cloud Run Admin
    "roles/compute.networkAdmin",          # Compute Network Admin
    "roles/dns.admin",                     # DNS Administrator
    "roles/editor",                        # Editor
    "roles/iap.tunnelResourceAccessor",    # IAP-secured Tunnel User
    "roles/logging.admin",                 # Logging Admin
    "roles/monitoring.admin",              # Monitoring Admin
    "roles/secretmanager.admin",           # Secret Manager Admin
    "roles/iam.serviceAccountAdmin",       # Service Account Admin
    "roles/serviceusage.serviceUsageAdmin",# Service Usage Admin
    "roles/storage.admin",                 # Storage Admin
    "roles/storage.objectAdmin"            # Storage Object Admin
    ]
}
 