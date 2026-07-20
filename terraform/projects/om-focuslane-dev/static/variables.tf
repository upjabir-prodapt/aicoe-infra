variable "project" {}
variable "envname" {}
variable "region" {}
variable "gcp_apis_required" {}
variable "artifact_format" {}

# Required by modules/static-base for the project resource-tag binding.
# Fill this in with om-focus-lane's actual GCP project number
# (Console > IAM & Admin > Settings, or `gcloud projects describe
# om-focus-lane --format='value(projectNumber)'`).
variable "project_number" {}
