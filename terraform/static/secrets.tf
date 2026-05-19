###########################################
### Secret Manager for Sales agent ###########
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

###########################################
### Secret Manager for Sales agent CSR###########
###########################################

resource "google_secret_manager_secret" "sales_agent_csr" {
  secret_id = "${var.project}${var.envname}-salesagent-csr"
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
### Secret Manager for Translation CSR ###########
###########################################
 
resource "google_secret_manager_secret" "translation_csr" {
  secret_id = "${var.project}${var.envname}-translation-csr"
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
### Secret Manager for Sales ILB ###########
###########################################

resource "google_secret_manager_secret" "sales_agent_ssl_cer" {
  secret_id = "${var.project}${var.envname}-salesagent-ssl-certificate"
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
### Secret Manager for Translation SSL ###########
###########################################
 
resource "google_secret_manager_secret" "translation_ssl_cer" {
  secret_id = "${var.project}${var.envname}-translation-ssl-certificate"
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
### Secret Manager for Sales private key ###########
###########################################

resource "google_secret_manager_secret" "sales_agent_ssl_key" {
  secret_id = "${var.project}${var.envname}-salesagent-ssl-private-key"
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
### Secret Manager for Translation SSL ###########
###########################################
 
resource "google_secret_manager_secret" "translation_ssl_key" {
  secret_id = "${var.project}${var.envname}-translation-ssl-private-key"
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

