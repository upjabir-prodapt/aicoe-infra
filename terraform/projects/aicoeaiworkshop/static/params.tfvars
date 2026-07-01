project_name     = "aicoeaiworkshop"
project          = "aicoeaiworkshop"
envname          = "sandox"
region           = "europe-west1"
gcp_project_id   = "aicoeaiworkshop"
resource_prefix  = "aicoeaiworkshop"
state_bucket     = "aicoeaiworkshopsandox-bucket-tf-state"
project_number   = "775524029915"
# group_email    = "gcp-aicoeaiworkshop-users@colt.net"  # IAM commented out in main.tf
gcp_apis_required = [
  "aiplatform.googleapis.com",
]
