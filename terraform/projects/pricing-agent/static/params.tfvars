project_name     = "pricing-agent"
project          = "pricingagent"
envname          = "sandbox"
region           = "europe-west1"
state_bucket     = "pricingagent-sandbox-bucket-tf-state"
gcp_project_id   = "pricingagent-sandbox"
resource_prefix  = "pricingagent-sandbox"
project_number   = "571016044556"
# group_email    = "gcp-pricingagent-users@colt.net"  # group does not exist; IAM commented out in main.tf
gcp_apis_required = [
  "aiplatform.googleapis.com",
  "compute.googleapis.com",
  "geminicloudassist.googleapis.com",
  "monitoring.googleapis.com",
  "storage.googleapis.com",
  "telemetry.googleapis.com",
  "cloudkms.googleapis.com",
]
