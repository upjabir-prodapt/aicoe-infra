###########################################
###   AICOE Vertex Application Bucket   ###
###########################################
 
resource "google_storage_bucket" "aicoe_app_bucket" {
  name          = "${var.project}-${var.envname}-bucket"
  location      = var.region
  project       = "${var.project}-${var.envname}-${var.project_num}"
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
 
  versioning {
    enabled = true
  }

  encryption {
           default_kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
        }
  
  labels = {
    env    = var.envname
    system = "${var.project}-${var.envname}-${var.project_num}"
  }
}
