###########################################
###  Cloud KMS for AICOE Bucket ###########
###########################################
 
#Keyring
 
resource "google_kms_key_ring" "aicoe_app_bucket_key_ring" {
  name     = "${var.project}${var.envname}-app-bucket-key-ring"
  location = var.region
  project  = "${var.project}${var.envname}"

  depends_on = [ google_project_service.service ]
}
 
# Key
 
resource "google_kms_crypto_key" "aicoe_app_bucket_key" {
  name            = "${var.project}${var.envname}-app-bucket-key"
  key_ring        = google_kms_key_ring.aicoe_app_bucket_key_ring.id
  rotation_period = "1000000s"
 
  lifecycle {
    prevent_destroy = true
  }
  labels = {
    env             = "${var.envname}"
    system          = "${var.project}${var.envname}"
  }
 
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
  depends_on = [ google_project_service.service ]
}

###########################################
###  Cloud KMS for AICOE  disk  ###########
###########################################
 
#Keyring
 
resource "google_kms_key_ring" "aicoe_vxai_wkb_key_ring" {
  count    = var.envname == "sandox" ? 1 : 0
  name     = "${var.project}${var.envname}-vxai-wkb-key-ring"
  location = var.region
  project  = "${var.project}${var.envname}"
}
 
# Key
 
resource "google_kms_crypto_key" "aicoe_vxai_wkb_key" {
  count       = var.envname == "sandox" ? 1 : 0
  name            = "${var.project}${var.envname}-vxai-wkb-key"
  key_ring        = google_kms_key_ring.aicoe_vxai_wkb_key_ring[0].id
  rotation_period = "1000000s"
 
  lifecycle {
    prevent_destroy = true
  }
  labels = {
    env             = "${var.envname}"
    system          = "${var.project}${var.envname}"
  }
 
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}