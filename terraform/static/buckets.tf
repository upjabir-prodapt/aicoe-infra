# ###########################################
# ###   AICOE Vertex Application Bucket   ###
# ###########################################
 
# resource "google_storage_bucket" "aicoe_app_bucket" {
#   name          = "${var.project}${var.envname}-vx-app-001"
#   location      = var.region
#   project       = "${var.project}${var.envname}"
#   storage_class = "STANDARD"
#   uniform_bucket_level_access = true
 
#   versioning {
#     enabled = true
#   }
  
#   # encryption {
#   #          default_kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
#   #       }

#   labels = {
#     env    = var.envname
#     system = "${var.project}${var.envname}"
#   }
# }

# ###########################################
# ###   AICOE Vertex AI Bootstrap Bucket   ###
# ###########################################
 
# resource "google_storage_bucket" "aicoe_vxai_bs_bucket" {
#   name          = "${var.project}${var.envname}-vxai-bs"
#   location      = var.region
#   project       = "${var.project}${var.envname}"
#   storage_class = "STANDARD"
#   uniform_bucket_level_access = true
 
#   versioning {
#     enabled = true
#   }

#   # encryption {
#   #          default_kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
#   #       }
  
#   labels = {
#     env    = var.envname
#     system = "${var.project}${var.envname}"
#   }
# }

# ###########################################
# ## AICOE Translation Application Bucket  ##
# ###########################################
 
resource "google_storage_bucket" "aicoe_trans_app_bucket" {
  name          = "${var.project}${var.envname}-vxai-translation-app-001"
  location      = var.region
  project       = "${var.project}${var.envname}"
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
 
  versioning {
    enabled = true
  }

  # encryption {
  #          default_kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
  #       }
  
  labels = {
    env    = var.envname
    system = "${var.project}${var.envname}"
  }
}

###########################################
###   AICOE Sales Application Bucket    ###
###########################################
 
resource "google_storage_bucket" "aicoe_sales_app_bucket" {
  name          = "${var.project}${var.envname}-vxai-sales-app-001"
  location      = var.region
  project       = "${var.project}${var.envname}"
  storage_class = "STANDARD"
  uniform_bucket_level_access = true
 
  versioning {
    enabled = true
  }

  # encryption {
  #          default_kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
  #       }
  
  labels = {
    env    = var.envname
    system = "${var.project}${var.envname}"
  }
}
