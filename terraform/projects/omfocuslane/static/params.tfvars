project_name     = "omfocuslane"
project          = "om-focus-lane"
envname          = "dev"
region           = "europe-west1"
gcp_project_id   = "om-focus-lane"
resource_prefix  = "om-focus-lane-dev"
project_number   = "35927785065"
artifact_format  = "docker"
gcp_apis_required = [
  "aiplatform.googleapis.com",
  "bigquery.googleapis.com",
  "bigquerystorage.googleapis.com",
  "run.googleapis.com",
  "artifactregistry.googleapis.com",
  "dns.googleapis.com",
  "secretmanager.googleapis.com",
  "cloudkms.googleapis.com",
  "logging.googleapis.com",
  "monitoring.googleapis.com",
  "serviceusage.googleapis.com",
  "compute.googleapis.com",
  "cloudbuild.googleapis.com",
  "firestore.googleapis.com",
  "cloudscheduler.googleapis.com",
]
