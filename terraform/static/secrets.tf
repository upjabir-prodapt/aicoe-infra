###########################################
### Secret Manager for Translation agent ###########
###########################################
resource "google_secret_manager_secret" "translation_service_secret" {
  secret_id = "translation-service-env"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
        replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
    }
  }
}
labels = {
    environment = var.envname
    managed_by = "terraform"
}
}

###########################################
### Secret Manager for Sales agent ###########
###########################################
import{
    to = google_secret_manager_secret.sales_agent_service_secret
    id = "projects/${var.project}${var.envname}/secrets/sales-agent-service-env"
}
 
resource "google_secret_manager_secret" "sales_agent_service_secret" {
  secret_id = "sales-agent-service-env"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}

import{
    to = google_secret_manager_secret.aicoedev_translation_ssl_private_key
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-translation-ssl-private-key"
}
 
resource "google_secret_manager_secret" "aicoedev_translation_ssl_private_key" {
  secret_id = "aicoedev-translation-ssl-private-key"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}

import{
    to = google_secret_manager_secret.aicoedev_translation_ssl_certificate
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-translation-ssl-certificate"
}
 
resource "google_secret_manager_secret" "aicoedev_translation_ssl_certificate" {
  secret_id = "aicoedev-translation-ssl-certificate"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}


import{
    to = google_secret_manager_secret.aicoedev_translation_csr
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-translation-csr"
}
 
resource "google_secret_manager_secret" "aicoedev_translation_csr" {
  secret_id = "aicoedev-translation-csr"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}

import{
    to = google_secret_manager_secret.aicoedev_salesagent_ssl_private_key
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-salesagent-ssl-private-key"
}
 
resource "google_secret_manager_secret" "aicoedev_salesagent_ssl_private_key" {
  secret_id = "aicoedev-salesagent-ssl-private-key"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}


import{
    to = google_secret_manager_secret.aicoedev_salesagent_ssl_certificate
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-salesagent-ssl-certificate"
}
 
resource "google_secret_manager_secret" "aicoedev_salesagent_ssl_certificate" {
  secret_id = "aicoedev-salesagent-ssl-certificate"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}

import{
    to = google_secret_manager_secret.aicoedev_salesagent_csr
    id = "projects/${var.project}${var.envname}/secrets/aicoedev-salesagent-csr"
}
 
resource "google_secret_manager_secret" "aicoedev_salesagent_csr" {
  secret_id = "aicoedev-salesagent-csr"
  project = "${var.project}${var.envname}"

  replication {
    user_managed {
       replicas {
            location = var.region
            customer_managed_encryption {
            kms_key_name = google_kms_crypto_key.aicoe_app_bucket_key.id
            }
       }
    }
  }
   labels = {
     environment = var.envname
     managed_by = "terraform"
 }
}
